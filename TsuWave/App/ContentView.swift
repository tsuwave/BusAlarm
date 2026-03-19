import SwiftUI

struct ContentView: View {
    @StateObject private var monitorService = BusMonitorService.shared
    @State private var busStopCode = ""
    @State private var serviceNo = ""
    @State private var targetMinutes = 5
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Add New Bus
                Section("Add Bus to Monitor") {
                    TextField("Bus Stop Code (e.g., 59009)", text: $busStopCode)
                        .keyboardType(.numberPad)
                    
                    TextField("Service No (e.g., 14)", text: $serviceNo)
                        .keyboardType(.numberPad)
                    
                    Stepper("Alert when \(targetMinutes) min away", value: $targetMinutes, in: 1...15)
                    
                    Button("Start Monitoring") {
                        guard !busStopCode.isEmpty, !serviceNo.isEmpty else { return }
                        monitorService.addBus(
                            busStopCode: busStopCode,
                            serviceNo: serviceNo,
                            targetMinutes: targetMinutes
                        )
                        busStopCode = ""
                        serviceNo = ""
                    }
                    .disabled(busStopCode.isEmpty || serviceNo.isEmpty)
                }
                
                // MARK: - Active Monitors
                Section("Active Monitors") {
                    if monitorService.monitoredBuses.isEmpty {
                        Text("No buses being monitored")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(monitorService.monitoredBuses) { bus in
                            BusMonitorRow(bus: bus)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let bus = monitorService.monitoredBuses[index]
                                monitorService.removeBus(id: bus.id)
                            }
                        }
                    }
                }
                
                // MARK: - Recent Alerts
                Section("Recent Alerts") {
                    if monitorService.currentAlerts.isEmpty {
                        Text("No alerts yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(monitorService.currentAlerts.suffix(5).reversed()) { alert in
                            AlertRow(alert: alert)
                        }
                    }
                }
                
                // MARK: - Quick Presets
                Section("Quick Presets") {
                    Button("Orchard → Bus 14") {
                        monitorService.addBus(busStopCode: "59009", serviceNo: "14", targetMinutes: 5)
                    }
                    Button("Tampines → Bus 31") {
                        monitorService.addBus(busStopCode: "75009", serviceNo: "31", targetMinutes: 5)
                    }
                }
            }
            .navigationTitle("🌊 Swell")
        }
    }
}

struct BusMonitorRow: View {
    let bus: MonitoredBus
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bus \(bus.serviceNo)")
                    .font(.headline)
                Text("Stop: \(bus.busStopCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "bell.fill")
                    .font(.caption)
                Text("\(bus.targetMinutes)m")
                    .font(.caption)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .padding(.vertical, 4)
    }
}

struct AlertRow: View {
    let alert: BusAlert
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bus \(alert.serviceNo) arriving!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(alert.minutesUntilArrival) min away • Stop \(alert.busStopCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(timeAgo(alert.triggeredAt))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
