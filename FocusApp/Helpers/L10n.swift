import Foundation

enum L10n {
    private static func tr(_ key: String, _ args: [CVarArg] = []) -> String {
        let format = NSLocalizedString(key, comment: "")
        if args.isEmpty {
            return format
        }
        return String(format: format, locale: .current, arguments: args)
    }


    enum Coding {
        static var codeTitle: String {
            tr("coding.code_title")
        }
        static var consoleCollapse: String {
            tr("coding.console_collapse")
        }
        static var consoleExpand: String {
            tr("coding.console_expand")
        }
        static var consoleTitle: String {
            tr("coding.console_title")
        }
        static var descriptionEmpty: String {
            tr("coding.description_empty")
        }
        static var editorialApproachBody: String {
            tr("coding.editorial_approach_body")
        }
        static var editorialApproachTitle: String {
            tr("coding.editorial_approach_title")
        }
        static var editorialBigOPlaceholder: String {
            tr("coding.editorial_big_o_placeholder")
        }
        static var editorialBigOTitle: String {
            tr("coding.editorial_big_o_title")
        }
        static var editorialIntuitionBody: String {
            tr("coding.editorial_intuition_body")
        }
        static var editorialIntuitionTitle: String {
            tr("coding.editorial_intuition_title")
        }
        static var editorialVisualPlaceholder: String {
            tr("coding.editorial_visual_placeholder")
        }
        static var editorialVisualTitle: String {
            tr("coding.editorial_visual_title")
        }
        static var editorialWalkthroughTitle: String {
            tr("coding.editorial_walkthrough_title")
        }
        static var exitHelp: String {
            tr("coding.exit_help")
        }
        static var hideProblems: String {
            tr("coding.hide_problems")
        }
        static var leetcodeLink: String {
            tr("coding.leetcode_link")
        }
        static var loadingProblem: String {
            tr("coding.loading_problem")
        }
        static func problemPickerDayTopic(_ args: CVarArg...) -> String {
            tr("coding.problem_picker_day_topic", args)
        }
        static func problemPickerPendingLeft(_ args: CVarArg...) -> String {
            tr("coding.problem_picker_pending_left", args)
        }
        static var problemPickerSelect: String {
            tr("coding.problem_picker_select")
        }
        static var problemPickerTitle: String {
            tr("coding.problem_picker_title")
        }
        static var run: String {
            tr("coding.run")
        }
        static func sectionBacklog(_ args: CVarArg...) -> String {
            tr("coding.section_backlog", args)
        }
        static func sectionToday(_ args: CVarArg...) -> String {
            tr("coding.section_today", args)
        }
        static var showProblems: String {
            tr("coding.show_problems")
        }
        static func sidebarDayBadge(_ args: CVarArg...) -> String {
            tr("coding.sidebar_day_badge", args)
        }
        static func sidebarDayTopic(_ args: CVarArg...) -> String {
            tr("coding.sidebar_day_topic", args)
        }
        static func sidebarPendingLeft(_ args: CVarArg...) -> String {
            tr("coding.sidebar_pending_left", args)
        }
        static var sidebarSelectPrompt: String {
            tr("coding.sidebar_select_prompt")
        }
        static var sidebarTitle: String {
            tr("coding.sidebar_title")
        }
        static func solutionFilename(_ args: CVarArg...) -> String {
            tr("coding.solution_filename", args)
        }
        static var statusSolved: String {
            tr("coding.status_solved")
        }
        static var statusUnsolved: String {
            tr("coding.status_unsolved")
        }
        static var stop: String {
            tr("coding.stop")
        }
        static func submitAiGenerationFailed(_ args: CVarArg...) -> String {
            tr("coding.submit_ai_generation_failed", args)
        }
        static func submitAiTestsFailed(_ args: CVarArg...) -> String {
            tr("coding.submit_ai_tests_failed", args)
        }
        static func submitFailed(_ args: CVarArg...) -> String {
            tr("coding.submit_failed", args)
        }
        static var submitGeneratingTests: String {
            tr("coding.submit_generating_tests")
        }
        static var submitMissingAIProvider: String {
            tr("coding.submit_missing_ai_provider")
        }
        static var submitMissingAuth: String {
            tr("coding.submit_missing_auth")
        }
        static var submitMissingManifest: String {
            tr("coding.submit_missing_manifest")
        }
        static var submitMissingProblem: String {
            tr("coding.submit_missing_problem")
        }
        static var submitMissingQuestionId: String {
            tr("coding.submit_missing_question_id")
        }
        static var submitMissingReferenceSolution: String {
            tr("coding.submit_missing_reference_solution")
        }
        static func submitResult(_ args: CVarArg...) -> String {
            tr("coding.submit_result", args)
        }
        static func submitResultWithCounts(_ args: CVarArg...) -> String {
            tr("coding.submit_result_with_counts", args)
        }
        static func submitRunningAiTests(_ args: CVarArg...) -> String {
            tr("coding.submit_running_ai_tests", args)
        }
        static var submissionTagBody: String {
            tr("coding.submission_tag_body")
        }
        static var submissionTagTitle: String {
            tr("coding.submission_tag_title")
        }
        static var submissionsEmpty: String {
            tr("coding.submissions_empty")
        }
        static var submissionsSelectPrompt: String {
            tr("coding.submissions_select_prompt")
        }
        static var submit: String {
            tr("coding.submit")
        }
        static var tabDescription: String {
            tr("coding.tab_description")
        }
        static var tabEditorial: String {
            tr("coding.tab_editorial")
        }
        static var tabSolution: String {
            tr("coding.tab_solution")
        }
        static var tabSubmissions: String {
            tr("coding.tab_submissions")
        }
        static var tabDebug: String {
            tr("coding.tab_debug")
        }

        enum Solution {
            static var approachTitle: String {
                tr("coding.solution.approach_title")
            }
            static var codeTitle: String {
                tr("coding.solution.code_title")
            }
            static var complexityTitle: String {
                tr("coding.solution.complexity_title")
            }
            static var copyCode: String {
                tr("coding.solution.copy_code")
            }
            static var empty: String {
                tr("coding.solution.empty")
            }
            static var emptyHint: String {
                tr("coding.solution.empty_hint")
            }
            static var explanationTitle: String {
                tr("coding.solution.explanation_title")
            }
            static var inputLabel: String {
                tr("coding.solution.input_label")
            }
            static var intuitionTitle: String {
                tr("coding.solution.intuition_title")
            }
            static var outputLabel: String {
                tr("coding.solution.output_label")
            }
            static var spaceComplexity: String {
                tr("coding.solution.space_complexity")
            }
            static var summaryTitle: String {
                tr("coding.solution.summary_title")
            }
            static func testCaseLabel(_ args: CVarArg...) -> String {
                tr("coding.solution.test_case_label", args)
            }
            static var testCasesTitle: String {
                tr("coding.solution.test_cases_title")
            }
            static var timeComplexity: String {
                tr("coding.solution.time_complexity")
            }
        }
        static var timerDone: String {
            tr("coding.timer_done")
        }
        static var timerRestartHelp: String {
            tr("coding.timer_restart_help")
        }
        static func walkthroughCaseLabel(_ args: CVarArg...) -> String {
            tr("coding.walkthrough_case_label", args)
        }
        static var walkthroughEmpty: String {
            tr("coding.walkthrough_empty")
        }
        static func walkthroughExpectedFormat(_ args: CVarArg...) -> String {
            tr("coding.walkthrough_expected_format", args)
        }
        static func walkthroughInputFormat(_ args: CVarArg...) -> String {
            tr("coding.walkthrough_input_format", args)
        }

        enum Output {
            static var accepted: String {
                tr("coding.output.accepted")
            }
            static var compilationError: String {
                tr("coding.output.compilation_error")
            }
            static var empty: String {
                tr("coding.output.empty")
            }
            static var expectedLabel: String {
                tr("coding.output.expected_label")
            }
            static var failed: String {
                tr("coding.output.failed")
            }
            static var inputLabel: String {
                tr("coding.output.input_label")
            }
            static var noDebug: String {
                tr("coding.output.no_debug")
            }
            static var noOutput: String {
                tr("coding.output.no_output")
            }
            static var outputLabel: String {
                tr("coding.output.output_label")
            }
            static var passed: String {
                tr("coding.output.passed")
            }
            static var running: String {
                tr("coding.output.running")
            }
            static var stderrLabel: String {
                tr("coding.output.stderr_label")
            }
            static var tabDebug: String {
                tr("coding.output.tab_debug")
            }
            static var tabOutput: String {
                tr("coding.output.tab_output")
            }
            static var tabResult: String {
                tr("coding.output.tab_result")
            }
            static func testFormat(_ args: CVarArg...) -> String {
                tr("coding.output.test_format", args)
            }
            static func testsPassedFormat(_ args: CVarArg...) -> String {
                tr("coding.output.tests_passed_format", args)
            }
            static var wrongAnswer: String {
                tr("coding.output.wrong_answer")
            }
        }

        enum TestEditor {
            static var add: String {
                tr("coding.test_editor.add")
            }
            static var empty: String {
                tr("coding.test_editor.empty")
            }
            static var expectedLabel: String {
                tr("coding.test_editor.expected_label")
            }
            static var inputLabel: String {
                tr("coding.test_editor.input_label")
            }
            static func testFormat(_ args: CVarArg...) -> String {
                tr("coding.test_editor.test_format", args)
            }
            static var title: String {
                tr("coding.test_editor.title")
            }
        }

        enum Testcase {
            static var add: String {
                tr("coding.testcase.add")
            }
            static func caseFormat(_ args: CVarArg...) -> String {
                tr("coding.testcase.case_format", args)
            }
            static var empty: String {
                tr("coding.testcase.empty")
            }
            static var expectedLabel: String {
                tr("coding.testcase.expected_label")
            }
            static var inputLabel: String {
                tr("coding.testcase.input_label")
            }
            static var title: String {
                tr("coding.testcase.title")
            }
        }
    }

    enum Debug {
        static var header: String {
            tr("debug.header")
        }
        static var footer: String {
            tr("debug.footer")
        }
        static var logsTitle: String {
            tr("debug.logs_title")
        }
        static var logsSubtitle: String {
            tr("debug.logs_subtitle")
        }
        static var openLogs: String {
            tr("debug.open_logs")
        }
        static var clearLogs: String {
            tr("debug.clear_logs")
        }
        static var copyLogs: String {
            tr("debug.copy_logs")
        }
        static var levelLabel: String {
            tr("debug.level_label")
        }
        static var categoryLabel: String {
            tr("debug.category_label")
        }
        static var levelAll: String {
            tr("debug.level_all")
        }
        static var categoryAll: String {
            tr("debug.category_all")
        }
        static var searchPlaceholder: String {
            tr("debug.search_placeholder")
        }
        static var emptyTitle: String {
            tr("debug.empty_title")
        }
        static var emptyBody: String {
            tr("debug.empty_body")
        }
        static var showDetails: String {
            tr("debug.show_details")
        }
        static var hideDetails: String {
            tr("debug.hide_details")
        }
    }

    enum Content {
        static var appTitle: String {
            tr("content.app_title")
        }
        static var problemsSolved: String {
            tr("content.problems_solved")
        }
        static func progressCount(_ args: CVarArg...) -> String {
            tr("content.progress_count", args)
        }
        static var subtitle: String {
            tr("content.subtitle")
        }
    }

    enum Error {
        static var compilationErrorPrefix: String {
            tr("error.compilation_error_prefix")
        }
        static var executionStopped: String {
            tr("error.execution_stopped")
        }
        static func failedToRunProcessFormat(_ args: CVarArg...) -> String {
            tr("error.failed_to_run_process_format", args)
        }
        static func failedToWriteSourceFormat(_ args: CVarArg...) -> String {
            tr("error.failed_to_write_source_format", args)
        }
        static var outputLimitExceeded: String {
            tr("error.output_limit_exceeded")
        }
        static func unsupportedLanguageFormat(_ args: CVarArg...) -> String {
            tr("error.unsupported_language_format", args)
        }
    }

    enum Focus {
        static var completeDone: String {
            tr("focus.complete_done")
        }
        static var completeMinutesLabel: String {
            tr("focus.complete_minutes_label")
        }
        static var completeSubtitle: String {
            tr("focus.complete_subtitle")
        }
        static var completeTitle: String {
            tr("focus.complete_title")
        }
        static func durationButtonFormat(_ args: CVarArg...) -> String {
            tr("focus.duration_button_format", args)
        }
        static var durationCancel: String {
            tr("focus.duration_cancel")
        }
        static var durationCustomLabel: String {
            tr("focus.duration_custom_label")
        }
        static var durationMinutesLabel: String {
            tr("focus.duration_minutes_label")
        }
        static var durationPrompt: String {
            tr("focus.duration_prompt")
        }
        static var durationStartButton: String {
            tr("focus.duration_start_button")
        }
        static var durationTitle: String {
            tr("focus.duration_title")
        }
        static var timerEndSession: String {
            tr("focus.timer_end_session")
        }
        static var timerPause: String {
            tr("focus.timer_pause")
        }
        static var timerPaused: String {
            tr("focus.timer_paused")
        }
        static var timerPrompt: String {
            tr("focus.timer_prompt")
        }
        static var timerRemaining: String {
            tr("focus.timer_remaining")
        }
        static var timerResume: String {
            tr("focus.timer_resume")
        }
    }

    enum Habit {

        enum Label {
            static var dsa: String {
                tr("habit.label.dsa")
            }
            static var exercise: String {
                tr("habit.label.exercise")
            }
            static var other: String {
                tr("habit.label.other")
            }
        }
    }

    enum Notification {

        enum Habits {
            static var body: String {
                tr("notification.habits.body")
            }
            static var title: String {
                tr("notification.habits.title")
            }
        }

        enum HabitsComplete {
            static var body: String {
                tr("notification.habits_complete.body")
            }
            static var title: String {
                tr("notification.habits_complete.title")
            }
        }

        enum Study {
            static var body: String {
                tr("notification.study.body")
            }
            static var title: String {
                tr("notification.study.title")
            }
        }

        enum TopicComplete {
            static func bodyFormat(_ args: CVarArg...) -> String {
                tr("notification.topic_complete.body_format", args)
            }
            static var title: String {
                tr("notification.topic_complete.title")
            }
        }
    }

    enum Output {
        static var actual: String {
            tr("output.actual")
        }
        static var consoleOutput: String {
            tr("output.console_output")
        }
        static var emptyState: String {
            tr("output.empty_state")
        }
        static var errorOutput: String {
            tr("output.error_output")
        }
        static var expected: String {
            tr("output.expected")
        }
        static var failed: String {
            tr("output.failed")
        }
        static func lineCountPlural(_ args: CVarArg...) -> String {
            tr("output.line_count_plural", args)
        }
        static var lineCountSingle: String {
            tr("output.line_count_single")
        }
        static var passed: String {
            tr("output.passed")
        }
        static var running: String {
            tr("output.running")
        }
        static func testCaseLabel(_ args: CVarArg...) -> String {
            tr("output.test_case_label", args)
        }
        static var testResults: String {
            tr("output.test_results")
        }
        static var title: String {
            tr("output.title")
        }
    }

    enum Plan {
        static var bufferBody: String {
            tr("plan.buffer_body")
        }
        static var bufferTitle: String {
            tr("plan.buffer_title")
        }
        static func precompletedCountFormat(_ args: CVarArg...) -> String {
            tr("plan.precompleted_count_format", args)
        }
        static var precompletedTitle: String {
            tr("plan.precompleted_title")
        }
        static var syncDefaultStatus: String {
            tr("plan.sync_default_status")
        }
        static var syncNow: String {
            tr("plan.sync_now")
        }
        static var syncTitle: String {
            tr("plan.sync_title")
        }
    }

    enum ProblemSelection {
        static var backToTimer: String {
            tr("problem_selection.back_to_timer")
        }
        static func sectionBacklog(_ args: CVarArg...) -> String {
            tr("problem_selection.section_backlog", args)
        }
        static func sectionToday(_ args: CVarArg...) -> String {
            tr("problem_selection.section_today", args)
        }
        static var solved: String {
            tr("problem_selection.solved")
        }
        static var subtitle: String {
            tr("problem_selection.subtitle")
        }
        static var title: String {
            tr("problem_selection.title")
        }
    }

    enum Settings {
        static var aboutHeader: String {
            tr("settings.about_header")
        }
        static var aiApiKeyLabel: String {
            tr("settings.ai_api_key_label")
        }
        static var aiApiKeyPlaceholder: String {
            tr("settings.ai_api_key_placeholder")
        }
        static var aiFooter: String {
            tr("settings.ai_footer")
        }
        static var aiHeader: String {
            tr("settings.ai_header")
        }
        static var aiModelLabel: String {
            tr("settings.ai_model_label")
        }
        static var aiProviderLabel: String {
            tr("settings.ai_provider_label")
        }
        static var aiTestCasesExport: String {
            tr("settings.ai_test_cases_export")
        }
        static var aiTestCasesFooter: String {
            tr("settings.ai_test_cases_footer")
        }
        static var aiTestCasesHeader: String {
            tr("settings.ai_test_cases_header")
        }
        static var aiTestCasesEmpty: String {
            tr("settings.ai_test_cases_empty")
        }
        static func aiTestCasesPath(_ args: CVarArg...) -> String {
            tr("settings.ai_test_cases_path", args)
        }
        static func aiTestCasesSummary(_ args: CVarArg...) -> String {
            tr("settings.ai_test_cases_summary", args)
        }
        static var aiTestCasesTitle: String {
            tr("settings.ai_test_cases_title")
        }
        static func aiTestCasesUpdated(_ args: CVarArg...) -> String {
            tr("settings.ai_test_cases_updated", args)
        }
        static var aiTestCasesView: String {
            tr("settings.ai_test_cases_view")
        }
        static var allHabitsDone: String {
            tr("settings.all_habits_done")
        }
        static var allHabitsDoneBody: String {
            tr("settings.all_habits_done_body")
        }
        static var appName: String {
            tr("settings.app_name")
        }
        static var celebrationFooter: String {
            tr("settings.celebration_footer")
        }
        static var celebrationHeader: String {
            tr("settings.celebration_header")
        }
        static var dailyHabitReminderToggle: String {
            tr("settings.daily_habit_reminder_toggle")
        }
        static var dailyStudyReminderToggle: String {
            tr("settings.daily_study_reminder_toggle")
        }
        static var enableNotifications: String {
            tr("settings.enable_notifications")
        }
        static var habitRemindersFooter: String {
            tr("settings.habit_reminders_footer")
        }
        static var habitRemindersHeader: String {
            tr("settings.habit_reminders_header")
        }
        static var close: String {
            tr("settings.close")
        }
        static var leetcodeFooter: String {
            tr("settings.leetcode_footer")
        }
        static var leetcodeHeader: String {
            tr("settings.leetcode_header")
        }
        static var leetcodeLoginBody: String {
            tr("settings.leetcode_login_body")
        }
        static var leetcodeLoginButton: String {
            tr("settings.leetcode_login_button")
        }
        static var leetcodeLoginSheetBody: String {
            tr("settings.leetcode_login_sheet_body")
        }
        static var leetcodeLoginSheetTitle: String {
            tr("settings.leetcode_login_sheet_title")
        }
        static var leetcodeLoginStatusConnected: String {
            tr("settings.leetcode_login_status_connected")
        }
        static var leetcodeLoginStatusDisconnected: String {
            tr("settings.leetcode_login_status_disconnected")
        }
        static var leetcodeLoginTitle: String {
            tr("settings.leetcode_login_title")
        }
        static var leetcodeLogoutButton: String {
            tr("settings.leetcode_logout_button")
        }
        static var leetcodeUsername: String {
            tr("settings.leetcode_username")
        }
        static var notificationStatus: String {
            tr("settings.notification_status")
        }
        static var notificationsDisabledBody: String {
            tr("settings.notifications_disabled_body")
        }
        static var notificationsDisabledTitle: String {
            tr("settings.notifications_disabled_title")
        }
        static var planStartDateTitle: String {
            tr("settings.plan_start_date_title")
        }
        static var planStartFooter: String {
            tr("settings.plan_start_footer")
        }
        static var planStartHeader: String {
            tr("settings.plan_start_header")
        }
        static var planStartReset: String {
            tr("settings.plan_start_reset")
        }
        static var reminderTime: String {
            tr("settings.reminder_time")
        }
        static var studyRemindersFooter: String {
            tr("settings.study_reminders_footer")
        }
        static var studyRemindersHeader: String {
            tr("settings.study_reminders_header")
        }
        static var topicCompletion: String {
            tr("settings.topic_completion")
        }
        static var topicCompletionBody: String {
            tr("settings.topic_completion_body")
        }
        static var usernamePlaceholder: String {
            tr("settings.username_placeholder")
        }
        static var validateSync: String {
            tr("settings.validate_sync")
        }
        static var validationNotFound: String {
            tr("settings.validation_not_found")
        }
        static var validationValid: String {
            tr("settings.validation_valid")
        }
        static var versionLabel: String {
            tr("settings.version_label")
        }
    }

    enum Stats {
        static var cardDaysLeft: String {
            tr("stats.card_days_left")
        }
        static var cardHabitsToday: String {
            tr("stats.card_habits_today")
        }
        static var cardProblemsSolved: String {
            tr("stats.card_problems_solved")
        }
        static var cardTopicsDone: String {
            tr("stats.card_topics_done")
        }
        static var focusReminderBody: String {
            tr("stats.focus_reminder_body")
        }
        static var focusReminderTitle: String {
            tr("stats.focus_reminder_title")
        }
        static func precompletedBonusFormat(_ args: CVarArg...) -> String {
            tr("stats.precompleted_bonus_format", args)
        }
        static var precompletedTitle: String {
            tr("stats.precompleted_title")
        }
        static var topicBreakdownTitle: String {
            tr("stats.topic_breakdown_title")
        }
    }

    enum Tab {
        static var plan: String {
            tr("tab.plan")
        }
        static var stats: String {
            tr("tab.stats")
        }
        static var today: String {
            tr("tab.today")
        }
    }

    enum Today {
        static var ctaButton: String {
            tr("today.cta_button")
        }
        static var ctaFooter: String {
            tr("today.cta_footer")
        }
        static var ctaSubtitle: String {
            tr("today.cta_subtitle")
        }
        static var ctaTitle: String {
            tr("today.cta_title")
        }
        static func dayBadge(_ args: CVarArg...) -> String {
            tr("today.day_badge", args)
        }
        static func dayCompletedFormat(_ args: CVarArg...) -> String {
            tr("today.day_completed_format", args)
        }
        static func dayTitleBacklog(_ args: CVarArg...) -> String {
            tr("today.day_title_backlog", args)
        }
        static func dayTitleToday(_ args: CVarArg...) -> String {
            tr("today.day_title_today", args)
        }
        static func habitsCompletedFormat(_ args: CVarArg...) -> String {
            tr("today.habits_completed_format", args)
        }
        static var habitsTitle: String {
            tr("today.habits_title")
        }
        static var syncDefaultStatus: String {
            tr("today.sync_default_status")
        }
        static var syncNow: String {
            tr("today.sync_now")
        }
        static var syncTitle: String {
            tr("today.sync_title")
        }
    }

    enum Widget {
        static var checking: String {
            tr("widget.checking")
        }
        static var habitsTitle: String {
            tr("widget.habits_title")
        }
        static var headerReady: String {
            tr("widget.header_ready")
        }
        static var headerSettingsHelp: String {
            tr("widget.header_settings_help")
        }
        static var headerSyncHelp: String {
            tr("widget.header_sync_help")
        }
        static var headerTitle: String {
            tr("widget.header_title")
        }
        static var leetcodePublicNotice: String {
            tr("widget.leetcode_public_notice")
        }
        static var leetcodeUsername: String {
            tr("widget.leetcode_username")
        }
        static var problemsAllDone: String {
            tr("widget.problems_all_done")
        }
        static func problemsStartDayFormat(_ args: CVarArg...) -> String {
            tr("widget.problems_start_day_format", args)
        }
        static var problemsTitle: String {
            tr("widget.problems_title")
        }
        static var saveSync: String {
            tr("widget.save_sync")
        }
        static func summaryDayFormat(_ args: CVarArg...) -> String {
            tr("widget.summary_day_format", args)
        }
        static var summaryHabitsTitle: String {
            tr("widget.summary_habits_title")
        }
        static func summaryOfTotalFormat(_ args: CVarArg...) -> String {
            tr("widget.summary_of_total_format", args)
        }
        static var summaryTopicTitle: String {
            tr("widget.summary_topic_title")
        }
        static func tomorrowCarryoverCountFormat(_ args: CVarArg...) -> String {
            tr("widget.tomorrow_carryover_count_format", args)
        }
        static var tomorrowCarryoverTitle: String {
            tr("widget.tomorrow_carryover_title")
        }
        static func tomorrowDayFormat(_ args: CVarArg...) -> String {
            tr("widget.tomorrow_day_format", args)
        }
        static func tomorrowProblemCountFormat(_ args: CVarArg...) -> String {
            tr("widget.tomorrow_problem_count_format", args)
        }
        static var tomorrowTitle: String {
            tr("widget.tomorrow_title")
        }
        static var usernamePlaceholder: String {
            tr("widget.username_placeholder")
        }
        static var validationNotFound: String {
            tr("widget.validation_not_found")
        }
        static var validationValid: String {
            tr("widget.validation_valid")
        }
    }
}
