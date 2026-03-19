import WidgetKit
import SwiftUI

@main
struct TsuWaveWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            BusArrivalLiveActivity()
        }
    }
}
