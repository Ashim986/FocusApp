#if os(macOS)
import AppKit
import FocusDesignSystem
import SwiftUI

struct ToolbarWidgetView: View {
    @ObservedObject var presenter: ToolbarWidgetPresenter
    @State var showTomorrow: Bool = false
    @State var showSettings: Bool = false
    private let panelWidth: CGFloat = 350
    @Environment(\.dsTheme) var theme

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                theme.colors.background,
                theme.colors.surfaceElevated
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: DSLayout.spacing(14)) {
            WidgetCard(fill: theme.colors.surfaceElevated.opacity(0.55)) {
                header
            }

            if showSettings {
                WidgetCard(fill: theme.colors.primary.opacity(0.12)) {
                    settingsSection
                }
            }

            WidgetCard {
                daySummary
            }

            WidgetCard {
                VStack(spacing: DSLayout.spacing(10)) {
                    todaysProblemsSection
                    if presenter.allTodaysSolved && presenter.hasTomorrow {
                        nextDaySection
                    }
                }
            }

            WidgetCard {
                habitsSection
            }

            if presenter.hasTomorrow || !presenter.carryoverProblems.isEmpty {
                WidgetCard {
                    tomorrowSection
                }
            }
        }
        .frame(minWidth: panelWidth, maxWidth: panelWidth)
        .fixedSize(horizontal: true, vertical: false)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(backgroundGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.colors.border.opacity(0.5), lineWidth: 1)
        )
        .padding(DSLayout.spacing(10))
    }
}
#endif
