@testable import FocusApp
import XCTest

final class LeetCodeExecutionWrapperTests: XCTestCase {
    func testExecutionWrapperWrapSwiftAddsRunnerAndSupport() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "twoSum",
            params: [("head", "ListNode")],
            returnType: "integer"
        )))
        let code = "class Solution { func twoSum(_ head: ListNode?) -> Int { return 0 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
        XCTAssertTrue(wrapped.contains("final class ListNode"))
        XCTAssertTrue(wrapped.contains("#sourceLocation"))
    }

    func testExecutionWrapperSkipsWhenClassDesign() throws {
        let metaJSON = """
        {"classname":"MyQueue","methods":[{"name":"MyQueue","params":[],"return":{"type":"void"}}]}
        """
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: metaJSON))
        let code = "class MyQueue {}"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertEqual(wrapped, code)
    }

    func testExecutionWrapperWrapPythonAddsRunner() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("values", "integer[]")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, values):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
        XCTAssertTrue(wrapped.contains("def _run"))
    }

    func testExecutionWrapperAddsListNodeWhenOnlyInComment() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        )))
        let code = """
        // class ListNode {}
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("final class ListNode"))
    }

    func testExecutionWrapperSkipsListNodeSupportWhenDefined() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        )))
        let code = """
        class ListNode { var val = 0; var next: ListNode? }
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertFalse(wrapped.contains("final class ListNode"))
    }

    func testExecutionWrapperAddsSupportWhenListNodeInString() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        )))
        let code = """
        let sample = \"class ListNode {}\"
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("final class ListNode"))
    }
}
