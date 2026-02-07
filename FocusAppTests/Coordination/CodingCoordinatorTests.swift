@testable import FocusApp
import XCTest

final class CodingCoordinatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> CodingCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        let container = AppContainer(appStore: store)
        return CodingCoordinator(container: container)
    }

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsEditor() {
        let sut = makeSUT()
        XCTAssertEqual(sut.activeRoute, .editor)
    }

    @MainActor
    func testInitialActiveSheetIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.activeSheet)
    }

    @MainActor
    func testInitialProblemPickerIsHidden() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isProblemPickerShown)
    }

    @MainActor
    func testInitialProblemSidebarIsHidden() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isProblemSidebarShown)
    }

    @MainActor
    func testInitialDetailTabIsDescription() {
        let sut = makeSUT()
        XCTAssertEqual(sut.detailTab, .description)
    }

    @MainActor
    func testInitialBottomPanelIsExpanded() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isBottomPanelCollapsed)
    }

    // MARK: - Problem Picker

    @MainActor
    func testShowProblemPicker() {
        let sut = makeSUT()
        sut.showProblemPicker()
        XCTAssertTrue(sut.isProblemPickerShown)
    }

    @MainActor
    func testHideProblemPicker() {
        let sut = makeSUT()
        sut.showProblemPicker()
        sut.hideProblemPicker()
        XCTAssertFalse(sut.isProblemPickerShown)
    }

    @MainActor
    func testToggleProblemPicker() {
        let sut = makeSUT()
        sut.toggleProblemPicker()
        XCTAssertTrue(sut.isProblemPickerShown)
        sut.toggleProblemPicker()
        XCTAssertFalse(sut.isProblemPickerShown)
    }

    // MARK: - Problem Sidebar

    @MainActor
    func testShowProblemSidebar() {
        let sut = makeSUT()
        sut.showProblemSidebar()
        XCTAssertTrue(sut.isProblemSidebarShown)
    }

    @MainActor
    func testHideProblemSidebar() {
        let sut = makeSUT()
        sut.showProblemSidebar()
        sut.hideProblemSidebar()
        XCTAssertFalse(sut.isProblemSidebarShown)
    }

    @MainActor
    func testToggleProblemSidebar() {
        let sut = makeSUT()
        sut.toggleProblemSidebar()
        XCTAssertTrue(sut.isProblemSidebarShown)
        sut.toggleProblemSidebar()
        XCTAssertFalse(sut.isProblemSidebarShown)
    }

    // MARK: - Sheets

    @MainActor
    func testShowSubmissionTag() {
        let sut = makeSUT()
        sut.showSubmissionTag()
        XCTAssertEqual(sut.activeSheet, .submissionTag)
    }

    @MainActor
    func testShowDebugLogs() {
        let sut = makeSUT()
        sut.showDebugLogs()
        XCTAssertEqual(sut.activeSheet, .debugLogs)
    }

    @MainActor
    func testDismissSheet() {
        let sut = makeSUT()
        sut.showDebugLogs()
        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
    }

    @MainActor
    func testShowSubmissionTagReplacesDebugLogs() {
        let sut = makeSUT()
        sut.showDebugLogs()
        sut.showSubmissionTag()
        XCTAssertEqual(sut.activeSheet, .submissionTag)
    }

    // MARK: - Detail Tab

    @MainActor
    func testSelectDetailTab() {
        let sut = makeSUT()
        sut.selectDetailTab(.editorial)
        XCTAssertEqual(sut.detailTab, .editorial)
    }

    @MainActor
    func testSelectDetailTabSolution() {
        let sut = makeSUT()
        sut.selectDetailTab(.solution)
        XCTAssertEqual(sut.detailTab, .solution)
    }

    // MARK: - Bottom Panel

    @MainActor
    func testToggleBottomPanel() {
        let sut = makeSUT()
        sut.toggleBottomPanel()
        XCTAssertTrue(sut.isBottomPanelCollapsed)
        sut.toggleBottomPanel()
        XCTAssertFalse(sut.isBottomPanelCollapsed)
    }

    // MARK: - State Reset

    @MainActor
    func testResetForNewProblemClearsAllState() {
        let sut = makeSUT()

        // Set up various states
        sut.isProblemPickerShown = true
        sut.isProblemSidebarShown = true
        sut.activeSheet = .debugLogs
        sut.detailTab = .editorial
        sut.isBottomPanelCollapsed = true

        // Reset
        sut.resetForNewProblem()

        // Verify all state is cleared
        XCTAssertFalse(sut.isProblemPickerShown)
        XCTAssertFalse(sut.isProblemSidebarShown)
        XCTAssertNil(sut.activeSheet)
        XCTAssertEqual(sut.detailTab, .description)
        XCTAssertFalse(sut.isBottomPanelCollapsed)
    }

    @MainActor
    func testResetForNewProblemIsIdempotent() {
        let sut = makeSUT()

        // Call reset on default state
        sut.resetForNewProblem()

        // Should remain in default state
        XCTAssertFalse(sut.isProblemPickerShown)
        XCTAssertFalse(sut.isProblemSidebarShown)
        XCTAssertNil(sut.activeSheet)
        XCTAssertEqual(sut.detailTab, .description)
        XCTAssertFalse(sut.isBottomPanelCollapsed)
    }

    // MARK: - Stale State Prevention

    @MainActor
    func testSidebarClosedAfterReset() {
        let sut = makeSUT()

        // Simulate: user opens sidebar for problem A
        sut.showProblemSidebar()
        XCTAssertTrue(sut.isProblemSidebarShown)

        // Simulate: user switches to problem B (triggers reset)
        sut.resetForNewProblem()

        // Sidebar should be closed
        XCTAssertFalse(sut.isProblemSidebarShown)
    }

    @MainActor
    func testSheetDismissedAfterReset() {
        let sut = makeSUT()

        // Open debug logs sheet
        sut.showDebugLogs()
        XCTAssertNotNil(sut.activeSheet)

        // Switch problem
        sut.resetForNewProblem()

        // Sheet should be dismissed
        XCTAssertNil(sut.activeSheet)
    }

    @MainActor
    func testDetailTabResetToDescriptionAfterProblemSwitch() {
        let sut = makeSUT()

        // Switch to editorial tab
        sut.selectDetailTab(.editorial)
        XCTAssertEqual(sut.detailTab, .editorial)

        // Switch problem
        sut.resetForNewProblem()

        // Should reset to description
        XCTAssertEqual(sut.detailTab, .description)
    }
}
