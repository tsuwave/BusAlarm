import Foundation

// MARK: - AlarmKit Service (iOS 26+)
// This file contains the AlarmKit integration for system-level alarms
// that bypass Silent mode and Focus modes

@available(iOS 26.0, *)
import AlarmKit

@available(iOS 26.0, *)
class AlarmKitService {
    static let shared = AlarmKitService()
    
    private var alarmManager: AlarmManager?
    private var scheduledAlarms: [String: AlarmRequest] = [:]
    
    private init() {
        setupAlarmManager()
    }
    
    private func setupAlarmManager() {
        // Initialize AlarmManager
        // AlarmManager is the main entry point for AlarmKit
        alarmManager = AlarmManager.shared
        
        // Request authorization
        alarmManager?.requestAuthorization { granted, error in
            if let error = error {
                print("[AlarmKit] Authorization error: \(error)")
                return
            }
            print("[AlarmKit] Authorization granted: \(granted)")
        }
    }
    
    // MARK: - Alarm Scheduling
    
    /// Schedules a system alarm that will fire even if the app is killed
    /// and bypasses Silent/Focus modes
    func scheduleBusAlarm(
        identifier: String,
        serviceNo: String,
        busStopCode: String,
        fireDate: Date
    ) -> Bool {
        guard let manager = alarmManager else {
            print("[AlarmKit] AlarmManager not available")
            return false
        }
        
        // Create the alarm request
        let alarm = AlarmRequest(
            identifier: identifier,
            title: "🚌 Bus \(serviceNo) Arriving!",
            body: "Your bus is arriving at stop \(busStopCode)",
            trigger: .absolute(fireDate),
            sound: .default,
            interruptionLevel: .critical
        )
        
        // Schedule the alarm
        do {
            try manager.schedule(alarm)
            scheduledAlarms[identifier] = alarm
            print("[AlarmKit] Scheduled alarm for \(fireDate)")
            return true
        } catch {
            print("[AlarmKit] Failed to schedule alarm: \(error)")
            return false
        }
    }
    
    /// Schedules a countdown alarm (e.g., "wake me in 5 minutes")
    /// Use this for bus arrival countdowns
    func scheduleCountdownAlarm(
        identifier: String,
        serviceNo: String,
        minutes: Int
    ) -> Bool {
        let fireDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        return scheduleBusAlarm(
            identifier: identifier,
            serviceNo: serviceNo,
            busStopCode: "",
            fireDate: fireDate
        )
    }
    
    /// Cancels a scheduled alarm
    func cancelAlarm(identifier: String) {
        guard let manager = alarmManager else { return }
        
        manager.cancelAlarm(withIdentifier: identifier)
        scheduledAlarms.removeValue(forKey: identifier)
        print("[AlarmKit] Cancelled alarm: \(identifier)")
    }
    
    /// Cancels all scheduled alarms
    func cancelAllAlarms() {
        guard let manager = alarmManager else { return }
        
        for identifier in scheduledAlarms.keys {
            manager.cancelAlarm(withIdentifier: identifier)
        }
        scheduledAlarms.removeAll()
        print("[AlarmKit] Cancelled all alarms")
    }
    
    /// Lists all scheduled alarm identifiers
    func getScheduledAlarmIdentifiers() -> [String] {
        return Array(scheduledAlarms.keys)
    }
    
    /// Check if an alarm is scheduled
    func isAlarmScheduled(identifier: String) -> Bool {
        return scheduledAlarms[identifier] != nil
    }
}

// MARK: - Info.plist additions for AlarmKit
/*
 Add to Info.plist:
 
 <key>NSAlarmKitUsageDescription</key>
 <string>Swell uses AlarmKit to ensure you never miss your bus, even when your phone is in Silent mode or a Focus is active.</string>
 
 Key differences from Critical Alerts:
 - No special entitlement required from Apple
 - User must grant explicit consent
 - Alarm fires even if app is killed
 - Full-screen alarm UI with snooze/stop
 - Appears on Lock Screen, Dynamic Island, and Apple Watch
 - Bypasses Silent mode and Focus modes
 
 Limitations:
 - App doesn't get woken up when alarm fires
 - Only local sounds can be played
 - Maximum alarm duration is limited
 */
