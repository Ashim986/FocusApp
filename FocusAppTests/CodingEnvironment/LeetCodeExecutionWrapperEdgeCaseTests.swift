@testable import FocusApp
import XCTest

// MARK: - Generated Swift Code Compilation Tests

// swiftlint:disable file_length type_body_length
final class LeetCodeExecutionWrapperEdgeCaseTests: XCTestCase {

    // MARK: - Prelude Escape Sequence Tests

    /// Verifies the prelude body contains correctly escaped quote characters
    /// for the `parseQuotedString` function. This was the root cause of the
    /// compilation bug where `"""` multiline strings consumed escape sequences.
    func testPreludeContainsValidQuoteEscapes() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The generated code must contain the literal escape sequence case "\"":
        // which means the Swift source text must read: case "\"":
        let quoteCase = "case \"\\\"\":" // case "\"":
        XCTAssertTrue(
            prelude.contains(quoteCase),
            "Prelude must contain escaped quote case for parseQuotedString"
        )
    }

    func testPreludeContainsValidBackslashEscapes() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The generated code must contain case "\\":
        let backslashCase = "case \"\\\\\":" // case "\\":
        XCTAssertTrue(
            prelude.contains(backslashCase),
            "Prelude must contain escaped backslash case for parseQuotedString"
        )
    }

    func testPreludeContainsValidNewlineEscapes() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The generated code must contain result.append("\n")
        XCTAssertTrue(
            prelude.contains(#"result.append("\n")"#),
            "Prelude must contain \\n escape in parseQuotedString"
        )
    }

    func testPreludeContainsValidTabEscapes() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The generated code must contain result.append("\t")
        XCTAssertTrue(
            prelude.contains(#"result.append("\t")"#),
            "Prelude must contain \\t escape in parseQuotedString"
        )
    }

    func testPreludeContainsValidCarriageReturnEscapes() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The generated code must contain result.append("\r")
        XCTAssertTrue(
            prelude.contains(#"result.append("\r")"#),
            "Prelude must contain \\r escape in parseQuotedString"
        )
    }

    func testPreludeContainsValidRegexWordBoundary() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The regex pattern must contain \\b for NSRegularExpression word boundary
        XCTAssertTrue(
            prelude.contains(#"\\b"#),
            "Prelude must contain \\\\b word boundary for regex patterns"
        )
    }

    func testPreludeContainsValidRegexWhitespace() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // The regex pattern must contain \\s for NSRegularExpression whitespace
        XCTAssertTrue(
            prelude.contains(#"\\s*="#),
            "Prelude must contain \\\\s whitespace regex pattern"
        )
    }

    /// Verifies the prelude body does NOT contain broken string literals
    /// like `case """:` (three quotes) which would be a syntax error.
    func testPreludeDoesNotContainBrokenQuoteLiterals() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // If escape sequences were consumed, we'd see `case """:` instead of `case "\"":
        XCTAssertFalse(
            prelude.contains("case \"\"\":"),
            "Prelude must NOT contain broken triple-quote pattern from escape consumption"
        )
    }

    func testPreludeEscapeCheckCharEqualsBackslash() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")
        // Must contain: } else if char == "\\" {
        let charCheck = "char == \"\\\\\"" // char == "\\"
        XCTAssertTrue(
            prelude.contains(charCheck),
            "Prelude must contain backslash character comparison"
        )
    }

    // MARK: - Integer Type Wrapping

    func testWrapSwiftSingleIntParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "singleNumber",
            params: [("nums", "integer[]")],
            returnType: "integer"
        )))
        let code = "class Solution { func singleNumber(_ nums: [Int]) -> Int { return 0 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toArray"))
        XCTAssertTrue(wrapped.contains("toInt"))
        XCTAssertTrue(wrapped.contains("parseArgs"))
    }

    func testWrapSwiftTwoIntParams() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "twoSum",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer[]"
        )))
        let code = "class Solution { func twoSum(_ nums: [Int], _ target: Int) -> [Int] { return [] } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("expectedCount: 2"))
        XCTAssertTrue(wrapped.contains("valueAt(args, 0)"))
        XCTAssertTrue(wrapped.contains("valueAt(args, 1)"))
    }

    // MARK: - String Type Wrapping

    func testWrapSwiftStringParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "isPalindrome",
            params: [("s", "string")],
            returnType: "boolean"
        )))
        let code = "class Solution { func isPalindrome(_ s: String) -> Bool { return true } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toString"))
    }

    func testWrapSwiftStringArrayParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "groupAnagrams",
            params: [("strs", "string[]")],
            returnType: "string[][]"
        )))
        let code = "class Solution { func groupAnagrams(_ strs: [String]) -> [[String]] { return [] } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toArray"))
        XCTAssertTrue(wrapped.contains("toString"))
    }

    // MARK: - Boolean Type Wrapping

    func testWrapSwiftBoolReturnType() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "isValid",
            params: [("s", "string")],
            returnType: "boolean"
        )))
        let code = "class Solution { func isValid(_ s: String) -> Bool { return true } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toString"))
        XCTAssertFalse(wrapped.contains("listNodeToArray"))
    }

    // MARK: - Double/Float Type Wrapping

    func testWrapSwiftDoubleParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "findMedian",
            params: [("nums1", "integer[]"), ("nums2", "integer[]")],
            returnType: "double"
        )))
        let code = """
        class Solution {
            func findMedian(_ nums1: [Int], _ nums2: [Int]) -> Double { return 0.0 }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toArray"))
    }

    // MARK: - Character Type Wrapping

    func testWrapSwiftCharacterParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "nextGreatestLetter",
            params: [("letters", "character[]"), ("target", "character")],
            returnType: "character"
        )))
        let code = """
        class Solution {
            func nextGreatestLetter(_ letters: [Character], _ target: Character) -> Character { return "a" }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toCharacter"))
    }

    // MARK: - ListNode Type Wrapping

    func testWrapSwiftListNodeParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        )))
        let code = "class Solution { func reverseList(_ head: ListNode?) -> ListNode? { return head } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toListNode"))
        XCTAssertTrue(wrapped.contains("listNodeToArray"))
        XCTAssertTrue(wrapped.contains("final class ListNode"))
    }

    func testWrapSwiftListNodeWithCycleDetection() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "hasCycle",
            params: [("head", "ListNode")],
            returnType: "boolean"
        )))
        let code = "class Solution { func hasCycle(_ head: ListNode?) -> Bool { return false } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        // Single ListNode param should trigger cycle position parsing
        XCTAssertTrue(wrapped.contains("parseCyclePos"))
        XCTAssertTrue(wrapped.contains("cyclePos"))
    }

    func testWrapSwiftTwoListNodeParamsNoCycleParsing() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "mergeTwoLists",
            params: [("list1", "ListNode"), ("list2", "ListNode")],
            returnType: "ListNode"
        )))
        let code = """
        class Solution {
            func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? { return nil }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        // Multiple ListNode params should NOT invoke cycle position parsing
        XCTAssertFalse(wrapped.contains("let cyclePos = parseCyclePos"))
    }

    // MARK: - TreeNode Type Wrapping

    func testWrapSwiftTreeNodeParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = "class Solution { func maxDepth(_ root: TreeNode?) -> Int { return 0 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toTreeNode"))
        XCTAssertTrue(wrapped.contains("final class TreeNode"))
    }

    func testWrapSwiftTreeNodeReturnType() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "invertTree",
            params: [("root", "TreeNode")],
            returnType: "TreeNode"
        )))
        let code = "class Solution { func invertTree(_ root: TreeNode?) -> TreeNode? { return root } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("treeNodeToArray(result)"))
    }

    // MARK: - Dictionary Type Wrapping

    func testWrapSwiftDictionaryParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "findOrder",
            params: [("dict", "map<string,string[]>")],
            returnType: "string"
        )))
        let code = """
        class Solution {
            func findOrder(_ dict: [String: [String]]) -> String { return "" }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toDictionary"))
    }

    // MARK: - Nested Array Types

    func testWrapSwiftNestedArrayParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "pacificAtlantic",
            params: [("heights", "integer[][]")],
            returnType: "integer[][]"
        )))
        let code = """
        class Solution {
            func pacificAtlantic(_ heights: [[Int]]) -> [[Int]] { return [] }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        // Should have nested toArray calls
        XCTAssertTrue(wrapped.contains("toArray"))
        XCTAssertTrue(wrapped.contains("toInt"))
    }

    // MARK: - Void Return Type

    func testWrapSwiftVoidReturnType() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "rotate",
            params: [("nums", "integer[]"), ("k", "integer")],
            returnType: "void"
        )))
        let code = """
        class Solution {
            func rotate(_ nums: inout [Int], _ k: Int) {}
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("NSNull()"))
    }

    // MARK: - No Params

    func testWrapSwiftNoParams() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [],
            returnType: "integer"
        )))
        let code = "class Solution { func solve() -> Int { return 42 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("expectedCount: 0"))
    }

    // MARK: - Class Design (should not wrap)

    func testWrapSwiftClassDesignSkipped() throws {
        let metaJSON = """
        {"classname":"MinStack","methods":[{"name":"MinStack","params":[],"return":{"type":"void"}},\
        {"name":"push","params":[{"name":"val","type":"integer"}],"return":{"type":"void"}}]}
        """
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: metaJSON))
        let code = "class MinStack { func push(_ val: Int) {} }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertEqual(wrapped, code, "Class design problems should not be wrapped")
    }

    // MARK: - Python Wrapping

    func testWrapPythonSingleIntParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "singleNumber",
            params: [("nums", "integer[]")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def singleNumber(self, nums):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_list"))
        XCTAssertTrue(wrapped.contains("_to_int"))
        XCTAssertTrue(wrapped.contains("_parse_args"))
    }

    func testWrapPythonListNodeWithCycle() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "hasCycle",
            params: [("head", "ListNode")],
            returnType: "boolean"
        )))
        let code = "class Solution:\n    def hasCycle(self, head):\n        return False"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_parse_cycle_pos"))
        XCTAssertTrue(wrapped.contains("_to_listnode"))
    }

    func testWrapPythonTreeNode() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def maxDepth(self, root):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_treenode"))
        XCTAssertTrue(wrapped.contains("class TreeNode"))
    }

    func testWrapPythonStringParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "isPalindrome",
            params: [("s", "string")],
            returnType: "boolean"
        )))
        let code = "class Solution:\n    def isPalindrome(self, s):\n        return True"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_str"))
    }

    func testWrapPythonDictionaryParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("graph", "map<string,string[]>")],
            returnType: "string[]"
        )))
        let code = "class Solution:\n    def solve(self, graph):\n        return []"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_dict"))
    }

    // MARK: - Param Names Literal Escaping

    func testParamNamesIncludedInPrelude() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "\"nums\", \"target\"")

        XCTAssertTrue(prelude.contains("let paramNames = [\"nums\", \"target\"]"))
    }

    func testParamNamesEmptyArray() {
        let prelude = LeetCodeExecutionWrapper.swiftRunnerPrelude(paramNamesLiteral: "")

        XCTAssertTrue(prelude.contains("let paramNames = []"))
    }

    // MARK: - Generated Code Structure Tests

    func testWrappedSwiftContainsSourceLocation() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution { func solve(_ x: Int) -> Int { return x } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("#sourceLocation(file: \"Solution.swift\", line: 1)"))
        XCTAssertTrue(wrapped.contains("#sourceLocation()"))
    }

    func testWrappedSwiftContainsImportFoundation() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution { func solve(_ x: Int) -> Int { return x } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("import Foundation"))
    }

    func testWrappedSwiftContainsTraceStruct() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution { func solve(_ x: Int) -> Int { return x } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("struct Trace"))
        XCTAssertTrue(wrapped.contains("static func step"))
    }

    func testWrappedSwiftContainsJsonStringHelper() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution { func solve(_ x: Int) -> Int { return x } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("func jsonString(from value: Any) -> String"))
    }

    // MARK: - Conversion Expression Tests

    func testSwiftConversionExpressionInt() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.int, valueExpr: "val")
        XCTAssertEqual(expr, "toInt(val)")
    }

    func testSwiftConversionExpressionDouble() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.double, valueExpr: "val")
        XCTAssertEqual(expr, "toDouble(val)")
    }

    func testSwiftConversionExpressionBool() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.bool, valueExpr: "val")
        XCTAssertEqual(expr, "toBool(val)")
    }

    func testSwiftConversionExpressionString() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.string, valueExpr: "val")
        XCTAssertEqual(expr, "toString(val)")
    }

    func testSwiftConversionExpressionCharacter() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.character, valueExpr: "val")
        XCTAssertEqual(expr, "toCharacter(val)")
    }

    func testSwiftConversionExpressionListOfInt() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.list(.int), valueExpr: "val")
        XCTAssertEqual(expr, "toArray(val) { toInt($0) }")
    }

    func testSwiftConversionExpressionListOfListOfInt() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.list(.list(.int)), valueExpr: "val")
        XCTAssertEqual(expr, "toArray(val) { toArray($0) { toInt($0) } }")
    }

    func testSwiftConversionExpressionDictStringToInt() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(
            .dictionary(.string, .int),
            valueExpr: "val"
        )
        XCTAssertTrue(expr.contains("toDictionary"))
        XCTAssertTrue(expr.contains("toString"))
        XCTAssertTrue(expr.contains("toInt"))
    }

    func testSwiftConversionExpressionListNode() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.listNode, valueExpr: "val")
        XCTAssertEqual(expr, "toListNode(val)")
    }

    func testSwiftConversionExpressionTreeNode() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.treeNode, valueExpr: "val")
        XCTAssertEqual(expr, "toTreeNode(val)")
    }

    func testSwiftConversionExpressionVoid() {
        let expr = LeetCodeExecutionWrapper.swiftConversionExpression(.void, valueExpr: "val")
        XCTAssertEqual(expr, "val")
    }

    // MARK: - Output Expression Tests

    func testSwiftOutputExpressionVoid() {
        let expr = LeetCodeExecutionWrapper.swiftOutputExpression(for: .void)
        XCTAssertEqual(expr, "NSNull()")
    }

    func testSwiftOutputExpressionListNode() {
        let expr = LeetCodeExecutionWrapper.swiftOutputExpression(for: .listNode)
        XCTAssertEqual(expr, "listNodeToArray(result)")
    }

    func testSwiftOutputExpressionTreeNode() {
        let expr = LeetCodeExecutionWrapper.swiftOutputExpression(for: .treeNode)
        XCTAssertEqual(expr, "treeNodeToArray(result)")
    }

    func testSwiftOutputExpressionDefault() {
        let expr = LeetCodeExecutionWrapper.swiftOutputExpression(for: .int)
        XCTAssertEqual(expr, "result")
    }

    // MARK: - Runner Conversions Structure

    func testSwiftRunnerConversionsContainsToInt() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toInt(_ value: Any) -> Int"))
    }

    func testSwiftRunnerConversionsContainsToDouble() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toDouble(_ value: Any) -> Double"))
    }

    func testSwiftRunnerConversionsContainsToBool() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toBool(_ value: Any) -> Bool"))
    }

    func testSwiftRunnerConversionsContainsToString() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toString(_ value: Any) -> String"))
    }

    func testSwiftRunnerConversionsContainsToCharacter() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toCharacter(_ value: Any) -> Character"))
    }

    func testSwiftRunnerConversionsContainsToArray() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toArray<T>"))
    }

    func testSwiftRunnerConversionsContainsToDictionary() {
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains("func toDictionary"))
    }

    func testSwiftRunnerConversionsIncludesListNodeHelpers() {
        let helper = "func toListNode(_ value: Any) -> ListNode?"
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: helper,
            treeNodeHelpers: ""
        )
        XCTAssertTrue(conversions.contains(helper))
    }

    func testSwiftRunnerConversionsIncludesTreeNodeHelpers() {
        let helper = "func toTreeNode(_ value: Any) -> TreeNode?"
        let conversions = LeetCodeExecutionWrapper.swiftRunnerConversions(
            listNodeHelpers: "",
            treeNodeHelpers: helper
        )
        XCTAssertTrue(conversions.contains(helper))
    }

    // MARK: - Runner Main Structure

    func testSwiftRunnerMainReadsStdin() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 1,
            arguments: ["let arg0 = toInt(valueAt(args, 0))"],
            callLine: "let result = solution.solve(arg0)",
            outputExpression: "result",
            traceOutputExpression: "output"
        )
        XCTAssertTrue(main.contains("FileHandle.standardInput.readDataToEndOfFile()"))
    }

    func testSwiftRunnerMainCallsSolution() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 1,
            arguments: ["let arg0 = toInt(valueAt(args, 0))"],
            callLine: "let result = solution.solve(arg0)",
            outputExpression: "result",
            traceOutputExpression: "output"
        )
        XCTAssertTrue(main.contains("let solution = Solution()"))
        XCTAssertTrue(main.contains("let result = solution.solve(arg0)"))
    }

    func testSwiftRunnerMainPrintsJsonOutput() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 1,
            arguments: ["let arg0 = toInt(valueAt(args, 0))"],
            callLine: "let result = solution.solve(arg0)",
            outputExpression: "result",
            traceOutputExpression: "output"
        )
        XCTAssertTrue(main.contains("print(jsonString(from: output))"))
    }

    func testSwiftRunnerMainIncludesSetupLines() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 1,
            arguments: ["let arg0 = toListNode(valueAt(args, 0), pos: cyclePos)"],
            callLine: "let result = solution.hasCycle(arg0)",
            outputExpression: "result",
            traceOutputExpression: "output",
            setupLines: ["let cyclePos = parseCyclePos(from: input)"]
        )
        XCTAssertTrue(main.contains("let cyclePos = parseCyclePos(from: input)"))
    }

    func testSwiftRunnerMainIncludesTraceInput() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 2,
            arguments: [
                "let arg0 = toInt(valueAt(args, 0))",
                "let arg1 = toInt(valueAt(args, 1))"
            ],
            callLine: "let result = solution.solve(arg0, arg1)",
            outputExpression: "result",
            traceOutputExpression: "output"
        )
        XCTAssertTrue(main.contains("Trace.input(paramNames: paramNames, args: traceArgs)"))
    }

    func testSwiftRunnerMainNoTraceInputWhenNoParams() {
        let main = LeetCodeExecutionWrapper.swiftRunnerMain(
            paramsCount: 0,
            arguments: [],
            callLine: "let result = solution.solve()",
            outputExpression: "result",
            traceOutputExpression: "output"
        )
        XCTAssertFalse(main.contains("Trace.input"))
    }

    // MARK: - Trace Structure Tests

    func testSwiftRunnerTraceContainsTraceStruct() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: false, needsTreeNode: false)
        XCTAssertTrue(trace.contains("struct Trace"))
    }

    func testSwiftRunnerTraceIncludesListNodeWhenNeeded() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: true, needsTreeNode: false)
        XCTAssertTrue(trace.contains("ListNode"))
        XCTAssertTrue(trace.contains("traceListNodeStructure"))
    }

    func testSwiftRunnerTraceExcludesListNodeWhenNotNeeded() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: false, needsTreeNode: false)
        XCTAssertFalse(trace.contains("traceListNodeStructure"))
    }

    func testSwiftRunnerTraceIncludesTreeNodeWhenNeeded() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: false, needsTreeNode: true)
        XCTAssertTrue(trace.contains("TreeNode"))
        XCTAssertTrue(trace.contains("traceTreeStructure"))
    }

    func testSwiftRunnerTraceExcludesTreeNodeWhenNotNeeded() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: false, needsTreeNode: false)
        XCTAssertFalse(trace.contains("traceTreeStructure"))
    }

    func testSwiftRunnerTraceContainsJsonStringHelper() {
        let trace = LeetCodeExecutionWrapper.swiftRunnerTrace(needsListNode: false, needsTreeNode: false)
        XCTAssertTrue(trace.contains("func jsonString(from value: Any) -> String"))
    }

    // MARK: - Full End-to-End Wrapping (Complex Types)

    func testWrapSwiftMixedParamsIntAndString() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "numDecodings",
            params: [("s", "string")],
            returnType: "integer"
        )))
        let code = "class Solution { func numDecodings(_ s: String) -> Int { return 0 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
        XCTAssertTrue(wrapped.contains("toString"))
        XCTAssertTrue(wrapped.contains("let result = solution.numDecodings"))
    }

    func testWrapSwiftListOfStringsReturnListOfListOfStrings() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "partition",
            params: [("s", "string")],
            returnType: "string[][]"
        )))
        let code = """
        class Solution {
            func partition(_ s: String) -> [[String]] { return [] }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toString"))
        XCTAssertTrue(wrapped.contains("solution.partition"))
    }

    func testWrapSwiftListNodeAndIntParams() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "removeNthFromEnd",
            params: [("head", "ListNode"), ("n", "integer")],
            returnType: "ListNode"
        )))
        let code = """
        class Solution {
            func removeNthFromEnd(_ head: ListNode?, _ n: Int) -> ListNode? { return head }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toListNode"))
        XCTAssertTrue(wrapped.contains("toInt"))
        XCTAssertTrue(wrapped.contains("listNodeToArray(result)"))
        // Two params: no cycle parsing invocation
        XCTAssertFalse(wrapped.contains("let cyclePos = parseCyclePos"))
    }

    func testWrapSwiftBooleanMatrix() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("board", "character[][]")],
            returnType: "void"
        )))
        let code = """
        class Solution {
            func solve(_ board: inout [[Character]]) {}
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("toCharacter"))
        XCTAssertTrue(wrapped.contains("toArray"))
    }

    // MARK: - Support Class Detection Edge Cases

    func testWrapSwiftSkipsTreeNodeSupportWhenDefined() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = """
        class TreeNode { var val = 0; var left: TreeNode?; var right: TreeNode? }
        class Solution { func maxDepth(_ root: TreeNode?) -> Int { return 0 } }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertFalse(wrapped.contains("final class TreeNode"))
    }

    func testWrapSwiftAddsTreeNodeWhenOnlyInComment() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = """
        // class TreeNode {}
        class Solution { func maxDepth(_ root: TreeNode?) -> Int { return 0 } }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("final class TreeNode"))
    }

    func testWrapSwiftAddsTreeNodeWhenInString() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = """
        let text = "class TreeNode {}"
        class Solution { func maxDepth(_ root: TreeNode?) -> Int { return 0 } }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("final class TreeNode"))
    }

    // MARK: - Python Edge Cases

    func testWrapPythonClassDesignSkipped() throws {
        let metaJSON = """
        {"classname":"MinStack","methods":[{"name":"MinStack","params":[],"return":{"type":"void"}}]}
        """
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: metaJSON))
        let code = "class MinStack:\n    pass"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertEqual(wrapped, code)
    }

    func testWrapPythonTwoListNodeParamsNoCycleParsing() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "mergeTwoLists",
            params: [("list1", "ListNode"), ("list2", "ListNode")],
            returnType: "ListNode"
        )))
        let code = "class Solution:\n    def mergeTwoLists(self, list1, list2):\n        return None"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        // Multiple ListNode params should NOT invoke cycle pos parsing
        XCTAssertFalse(wrapped.contains("cycle_pos = _parse_cycle_pos"))
    }

    func testWrapPythonNestedArrayParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("matrix", "integer[][]")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, matrix):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_list"))
        XCTAssertTrue(wrapped.contains("_to_int"))
    }

    func testWrapPythonBoolParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("flag", "boolean")],
            returnType: "boolean"
        )))
        let code = "class Solution:\n    def solve(self, flag):\n        return flag"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_bool"))
    }

    func testWrapPythonCharParam() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("c", "character")],
            returnType: "character"
        )))
        let code = "class Solution:\n    def solve(self, c):\n        return c"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(wrapped.contains("_to_str"))
    }

    // MARK: - Python Prelude Escape Sequences

    func testPythonPreludeContainsRegexWordBoundary() {
        let prelude = LeetCodeExecutionWrapper.pythonRunnerPrelude(paramNamesLiteral: "")
        // Python regex uses r"..." raw strings, so \b should appear literally
        XCTAssertTrue(
            prelude.contains(#"\b"#),
            "Python prelude must contain \\b word boundary in regex"
        )
    }

    func testPythonPreludeContainsRegexWhitespace() {
        let prelude = LeetCodeExecutionWrapper.pythonRunnerPrelude(paramNamesLiteral: "")
        XCTAssertTrue(
            prelude.contains(#"\s*="#),
            "Python prelude must contain \\s whitespace in regex"
        )
    }

    // MARK: - Signature Parsing Integration

    func testWrapSwiftUsesActualSignatureFromCode() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "twoSum",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer[]"
        )))
        // Actual code has different param labels than meta
        let code = """
        class Solution {
            func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
                return []
            }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("solution.twoSum"))
    }

    func testWrapSwiftHandlesBacktickIdentifiers() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "class",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = """
        class Solution {
            func `class`(_ x: Int) -> Int { return x }
        }
        """
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
    }

    // MARK: - Auto Instrumentation

    func testPythonAutoInstrumentationUsesSafeLookupCapture() {
        let code = """
        class Solution:
            def reverseList(self, head):
                prev = None
                curr = head
                while curr:
                    nxt = curr.next
                    curr.next = prev
                    prev = curr
                    curr = nxt
                return prev
        """

        let instrumented = AutoInstrumenter.instrument(
            code: code,
            language: .python,
            paramNames: ["head"]
        )

        XCTAssertTrue(instrumented.contains("_Trace.step(\"loop\", {"))
        XCTAssertTrue(instrumented.contains("\"curr\": (locals().get(\"curr\")"))
        XCTAssertTrue(instrumented.contains("\"nxt\": (locals().get(\"nxt\")"))
        XCTAssertFalse(instrumented.contains("\"curr\": curr"))
    }

    func testPythonAutoInstrumentationCapturesCustomLoopBindings() {
        let code = """
        class Solution:
            def solve(self, nums):
                total = 0
                for node_value in nums:
                    total += node_value
                return total
        """

        let instrumented = AutoInstrumenter.instrument(
            code: code,
            language: .python,
            paramNames: ["nums"]
        )

        XCTAssertTrue(instrumented.contains("\"node_value\": (locals().get(\"node_value\")"))
    }

    func testSwiftAutoInstrumentationCapturesCustomFunctionVariables() {
        let code = """
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? {
                var current = head
                while current != nil {
                    current = current?.next
                }
                return current
            }
        }
        """

        let instrumented = AutoInstrumenter.instrument(
            code: code,
            language: .swift,
            paramNames: ["head"]
        )

        XCTAssertTrue(instrumented.contains("Trace.step(\"loop\", ["))
        XCTAssertTrue(instrumented.contains("\"current\": current as Any"))
    }

    func testSwiftAutoInstrumentationInstrumentsInlineReturnsInEntryPointOnly() {
        let code = """
        class Solution {
            func helper(_ x: Int) -> Int { return x }

            func solve(_ x: Int) -> Int {
                if x > 0 { return helper(x) }
                return 0
            }
        }
        """

        let instrumented = AutoInstrumenter.instrument(
            code: code,
            language: .swift,
            paramNames: ["x"],
            entryPointName: "solve"
        )

        XCTAssertTrue(instrumented.contains("func helper(_ x: Int) -> Int { return x }"))
        XCTAssertTrue(instrumented.contains("if x > 0 { Trace.step(\"return\", [\"x\": x as Any]); return helper(x) }"))
        XCTAssertTrue(instrumented.contains("Trace.step(\"return\", [\"x\": x as Any]); return 0"))
    }

    func testPythonAutoInstrumentationInstrumentsInlineReturnsInEntryPointOnly() {
        let code = """
        class Solution:
            def helper(self, x):
                return x

            def solve(self, x):
                if x > 0: return self.helper(x)
                return 0
        """

        let instrumented = AutoInstrumenter.instrument(
            code: code,
            language: .python,
            paramNames: ["x"],
            entryPointName: "solve"
        )

        XCTAssertTrue(instrumented.contains("    def helper(self, x):\n        return x"))
        XCTAssertTrue(instrumented.contains("if x > 0: _Trace.step(\"return\", {"))
        XCTAssertTrue(instrumented.contains("}); return self.helper(x)"))
        XCTAssertTrue(instrumented.contains("_Trace.step(\"return\", {"))
        XCTAssertTrue(instrumented.contains("}); return 0"))
    }
}
// swiftlint:enable type_body_length
