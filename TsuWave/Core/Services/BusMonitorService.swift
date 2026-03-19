import Foundation
import CoreLocation
import UserNotifications
import ActivityKit

class BusMonitorService: NSObject, ObservableObject {
    static let shared = BusMonitorService()
    
    @Published var monitoredBuses: [MonitoredBus] = []
    @Published var currentAlerts: [BusAlert] = []
    
    private let locationManager = CLLocationManager()
    private let client = LTABusClient.shared
    private var timer: Timer?
    private var liveActivity: Activity<BusArrivalWidgetAttributes>?
    
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
        
        // Notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            print("Notification permission: \(granted)")
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
        
        // Also start location updates for background execution
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
    }
    
    func scheduleBackgroundRefresh() {
        // Register background task
        // BGTaskScheduler will be implemented here
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
        
        // Immediate check
        Task {
            await checkBus(bus)
        }
    }
    
    func removeBus(id: UUID) {
        monitoredBuses.removeAll { $0.id == id }
        saveMonitoredBuses()
    }
    
    // MARK: - Checking Logic
    
    private func checkAllBuses() async {
        for bus in monitoredBuses where bus.isActive {
            await checkBus(bus)
        }
    }
    
    private func checkBus(_ bus: MonitoredBus) async {
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
            
            // Trigger alert if within target window
            if minutes <= bus.targetMinutes && minutes > 0 {
                await triggerAlert(bus: bus, minutes: minutes)
            }
            
        } catch {
            print("Error checking bus: \(error)")
        }
    }
    
    // MARK: - Alerts
    
    private func triggerAlert(bus: MonitoredBus, minutes: Int) async {
        // Check if we already alerted recently (avoid spam)
        let recentAlert = currentAlerts.contains {
            $0.busStopCode == bus.busStopCode &&
            $0.serviceNo == bus.serviceNo &&
            $0.triggeredAt.timeIntervalSinceNow > -60 // Within last minute
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
        
        // Show notification
        let content = UNMutableNotificationContent()
        content.title = "🚌 Bus \(bus.serviceNo) Arriving!"
        content.body = "Your bus is \(minutes) minute(s) away from stop \(bus.busStopCode)"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil // Immediate
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
            // Start new activity
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
            // Update existing
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
        // Location updates trigger bus checks in background
        Task {
            await checkAllBuses()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
