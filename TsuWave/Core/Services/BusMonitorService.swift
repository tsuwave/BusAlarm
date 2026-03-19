import Foundation
import CoreLocation
import UserNotifications
import ActivityKit

// MARK: - Enhanced Bus Monitor with AlarmKit Support

class BusMonitorService: NSObject, ObservableObject {
    static let shared = BusMonitorService()
    
    @Published var monitoredBuses: [MonitoredBus] = []
    @Published var currentAlerts: [BusAlert] = []
    
    private let locationManager = CLLocationManager()
    private let client = LTABusClient.shared
    private var timer: Timer?
    private var liveActivity: Activity<BusArrivalWidgetAttributes>?
    
    // AlarmKit reference (iOS 26+)
    private var alarmKitAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        loadMonitoredBuses()
        requestPermissions()
    }
    
    // MARK: - Permissions
    
    private func requestPermissions() {
        // Location (for background execution)
        locationManager.requestAlwaysAuthorization()
        
        // Notifications (fallback for pre-iOS26)
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            print("Notification permission: \(granted)")
        }
        
        // AlarmKit authorization is handled by AlarmKitService
        if #available(iOS 26.0, *) {
            // AlarmKitService.shared will request auth on init
        }
    }
    
    // MARK: - Monitoring Control
    
    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task {
                await self?.checkAllBuses()
            }
        }
        
        // Start location updates for background execution
        locationManager.startMonitoringSignificantLocationChanges()
        
        Task {
            await checkAllBuses()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        locationManager.stopMonitoringSignificantLocationChanges()
        endLiveActivity()
        
        // Cancel all AlarmKit alarms
        if #available(iOS 26.0, *) {
            AlarmKitService.shared.cancelAllAlarms()
        }
    }
    
    func scheduleBackgroundRefresh() {
        // BGTaskScheduler implementation for background refresh
        // This supplements location-based background execution
    }
    
    // MARK: - Bus Management
    
    func addBus(busStopCode: String, serviceNo: String, targetMinutes: Int = 5) {
        let bus = MonitoredBus(
            busStopCode: busStopCode,
            serviceNo: serviceNo,
            targetMinutes: targetMinutes
        )
        monitoredBuses.append(bus)
        saveMonitoredBuses()
        
        // Immediate check and alarm scheduling
        Task {
            await checkBus(bus, scheduleAlarm: true)
        }
    }
    
    func removeBus(id: UUID) {
        if let bus = monitoredBuses.first(where: { $0.id == id }) {
            // Cancel any scheduled alarms for this bus
            let alarmId = "\(bus.busStopCode)-\(bus.serviceNo)"
            if #available(iOS 26.0, *) {
                AlarmKitService.shared.cancelAlarm(identifier: alarmId)
            }
        }
        
        monitoredBuses.removeAll { $0.id == id }
        saveMonitoredBuses()
    }
    
    // MARK: - Checking Logic
    
    private func checkAllBuses() async {
        for bus in monitoredBuses where bus.isActive {
            await checkBus(bus, scheduleAlarm: false)
        }
    }
    
    private func checkBus(_ bus: MonitoredBus, scheduleAlarm: Bool = false) async {
        do {
            let arrival = try await client.fetchBusArrival(
                busStopCode: bus.busStopCode,
                serviceNo: bus.serviceNo
            )
            
            guard let service = arrival.services.first,
                  let minutes = await client.getMinutesUntilArrival(busInfo: service.nextBus) else {
                return
            }
            
            // Update Live Activity
            await updateLiveActivity(
                serviceNo: bus.serviceNo,
                minutes: minutes,
                busStopCode: bus.busStopCode
            )
            
            // Schedule or update AlarmKit alarm
            if scheduleAlarm && alarmKitAvailable {
                await scheduleAlarmKitAlarm(bus: bus, minutes: minutes)
            }
            
            // Trigger immediate alert if within target window
            if minutes <= bus.targetMinutes && minutes > 0 {
                await triggerAlert(bus: bus, minutes: minutes)
            }
            
        } catch {
            print("Error checking bus: \(error)")
        }
    }
    
    // MARK: - AlarmKit Integration
    
    @available(iOS 26.0, *)
    private func scheduleAlarmKitAlarm(bus: MonitoredBus, minutes: Int) async {
        let alarmId = "\(bus.busStopCode)-\(bus.serviceNo)"
        
        // Calculate fire time based on bus ETA
        let fireDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        
        // Schedule the alarm
        _ = AlarmKitService.shared.scheduleBusAlarm(
            identifier: alarmId,
            serviceNo: bus.serviceNo,
            busStopCode: bus.busStopCode,
            fireDate: fireDate
        )
    }
    
    // MARK: - Alerts (Fallback for pre-iOS26)
    
    private func triggerAlert(bus: MonitoredBus, minutes: Int) async {
        // Check if we already alerted recently
        let recentAlert = currentAlerts.contains {
            $0.busStopCode == bus.busStopCode &&
            $0.serviceNo == bus.serviceNo &&
            $0.triggeredAt.timeIntervalSinceNow > -60
        }
        
        guard !recentAlert else { return }
        
        let alert = BusAlert(
            busStopCode: bus.busStopCode,
            serviceNo: bus.serviceNo,
            minutesUntilArrival: minutes,
            triggeredAt: Date()
        )
        
        await MainActor.run {
            currentAlerts.append(alert)
        }
        
        // Show notification (fallback for pre-iOS26 or if AlarmKit fails)
        let content = UNMutableNotificationContent()
        content.title = "🚌 Bus \(bus.serviceNo) Arriving!"
        content.body = "Your bus is \(minutes) minute(s) away from stop \(bus.busStopCode)"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Live Activity
    
    @available(iOS 16.1, *)
    private func updateLiveActivity(serviceNo: String, minutes: Int, busStopCode: String) async {
        let state = BusArrivalWidgetAttributes.ContentState(
            minutesUntilArrival: minutes,
            serviceNo: serviceNo,
            busStopCode: busStopCode
        )
        
        if Activity<BusArrivalWidgetAttributes>.activities.isEmpty {
            let attributes = BusArrivalWidgetAttributes()
            do {
                liveActivity = try Activity.request(
                    attributes: attributes,
                    contentState: state,
                    pushType: nil
                )
            } catch {
                print("Failed to start Live Activity: \(error)")
            }
        } else {
            await liveActivity?.update(using: state)
        }
    }
    
    private func endLiveActivity() {
        Task {
            await liveActivity?.end(nil, dismissalPolicy: .immediate)
        }
    }
    
    // MARK: - Persistence
    
    private func loadMonitoredBuses() {
        if let data = UserDefaults.standard.data(forKey: "monitoredBuses"),
           let buses = try? JSONDecoder().decode([MonitoredBus].self, from: data) {
            monitoredBuses = buses
        }
    }
    
    private func saveMonitoredBuses() {
        if let data = try? JSONEncoder().encode(monitoredBuses) {
            UserDefaults.standard.set(data, forKey: "monitoredBuses")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension BusMonitorService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            await checkAllBuses()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
