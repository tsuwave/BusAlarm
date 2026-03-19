import ActivityKit
import SwiftUI

// MARK: - Live Activity Attributes

struct BusArrivalWidgetAttributes: ActivityAttributes {
    public typealias BusArrivalStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var minutesUntilArrival: Int
        var serviceNo: String
        var busStopCode: String
    }
}

// MARK: - Live Activity View

@available(iOS 16.1, *)
struct BusArrivalLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusArrivalWidgetAttributes.self) { context in
            // Lock Screen / Notification Center
            LockScreenView(
                minutes: context.state.minutesUntilArrival,
                serviceNo: context.state.serviceNo,
                busStopCode: context.state.busStopCode
            )
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    BusIcon()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TimeDisplay(minutes: context.state.minutesUntilArrival)
                }
                DynamicIslandExpandedRegion(.center) {
                    ServiceInfo(serviceNo: context.state.serviceNo)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    StopInfo(busStopCode: context.state.busStopCode)
                }
            } compactLeading: {
                BusIcon()
            } compactTrailing: {
                Text("\(context.state.minutesUntilArrival)m")
                    .font(.caption2)
                    .foregroundColor(.white)
            } minimal: {
                Text("\(context.state.minutesUntilArrival)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Subviews

struct LockScreenView: View {
    let minutes: Int
    let serviceNo: String
    let busStopCode: String
    
    var body: some View {
        HStack(spacing: 16) {
            BusIcon(size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bus \(serviceNo)")
                    .font(.headline)
                
                Text("Stop \(busStopCode)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(minutes)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct BusIcon: View {
    var size: CGFloat = 24
    
    var body: some View {
        Image(systemName: "bus.fill")
            .font(.system(size: size * 0.5))
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.blue.opacity(0.2))
            )
            .foregroundColor(.blue)
    }
}

struct TimeDisplay: View {
    let minutes: Int
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("\(minutes)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("minutes")
                .font(.caption)
        }
        .foregroundColor(.white)
    }
}

struct ServiceInfo: View {
    let serviceNo: String
    
    var body: some View {
        Text("Bus \(serviceNo)")
            .font(.headline)
            .foregroundColor(.white)
    }
}

struct StopInfo: View {
    let busStopCode: String
    
    var body: some View {
        Text("Stop \(busStopCode)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
