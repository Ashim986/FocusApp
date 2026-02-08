import SwiftUI
import WidgetKit

@main
struct FocusWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProgressWidget()
        TodayWidget()
    }
}
