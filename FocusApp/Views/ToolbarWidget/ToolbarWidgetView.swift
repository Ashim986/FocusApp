import AppKit
import SwiftUI

struct ToolbarWidgetView: View {
    @ObservedObject var presenter: ToolbarWidgetPresenter
    @State var showTomorrow: Bool = false
    @State var showSettings: Bool = false
    private let panelWidth: CGFloat = 350

    var body: some View {
        VStack(spacing: 14) {
            WidgetCard(fill: Color.white.opacity(0.06)) {
                header
            }

            if showSettings {
                WidgetCard(fill: Color.blue.opacity(0.12)) {
                    settingsSection
                }
            }

            WidgetCard {
                daySummary
            }

            WidgetCard {
                VStack(spacing: 10) {
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
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.07, green: 0.08, blue: 0.12),
                            Color(red: 0.12, green: 0.11, blue: 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(10)
    }
}
