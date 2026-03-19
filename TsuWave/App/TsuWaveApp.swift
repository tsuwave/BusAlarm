import SwiftUI

@main
struct TsuWaveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        BusMonitorService.shared.startMonitoring()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BusMonitorService.shared.scheduleBackgroundRefresh()
    }
}
