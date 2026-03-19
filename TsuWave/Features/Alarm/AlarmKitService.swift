import Foundation

// MARK: - AlarmKit Service (iOS 26+)
// This file contains stubs for AlarmKit integration
// To be implemented when iOS 26 APIs are available

@available(iOS 26.0, *)
class AlarmKitService {
    static let shared = AlarmKitService()
    
    private init() {}
    
    // TODO: Implement AlarmKit integration
    // Requires: NSAlarmKitUsageDescription in Info.plist
    // AlarmKit provides system-level alarms that bypass Silent/Focus modes
    
    /// Schedules a system alarm that will fire even if the app is killed
    func scheduleAlarm(title: String, body: String, fireDate: Date) {
        // STUB: Implement using AlarmKit API
        // - Import AlarmKit framework
        // - Create AlarmRequest
        // - Set trigger time
        // - Request user consent
        // - Alarm fires even in Silent/Focus mode
        
        print("[AlarmKit] Would schedule alarm for \(fireDate)")
        print("[AlarmKit] Title: \(title)")
        print("[AlarmKit] Body: \(body)")
        print("[AlarmKit] ⚠️  Stub implementation - replace with actual AlarmKit API")
    }
    
    /// Cancels a scheduled alarm
    func cancelAlarm(identifier: String) {
        // STUB: Implement alarm cancellation
        print("[AlarmKit] Would cancel alarm: \(identifier)")
    }
    
    /// Lists all scheduled alarms
    func getScheduledAlarms() -> [String] {
        // STUB: Return list of scheduled alarm identifiers
        return []
    }
}

// MARK: - Info.plist additions needed for AlarmKit:
/*
 Add to Info.plist:
 
 <key>NSAlarmKitUsageDescription</key>
 <string>Swell uses AlarmKit to ensure you never miss your bus, even when your phone is in Silent mode or a Focus is active.</string>
 
 Required entitlements:
 - None! (Unlike Critical Alerts, AlarmKit doesn't require special Apple approval)
 */
