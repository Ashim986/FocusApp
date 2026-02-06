@testable import FocusApp
import XCTest

final class LeetCodeTemplateBuilderTests: XCTestCase {
    func testTemplateBuilderSwiftFunctionTemplateIncludesSupportTypes() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "merge",
            params: [("list", "ListNode"), ("tree", "TreeNode")],
            returnType: "ListNode"
        )))
        let template = LeetCodeTemplateBuilder.template(for: meta, language: .swift)

        XCTAssertNotNil(template)
        XCTAssertTrue(template?.contains("class ListNode") == true)
        XCTAssertTrue(template?.contains("class TreeNode") == true)
        XCTAssertTrue(template?.contains("func merge") == true)
    }

    func testTemplateBuilderPythonFunctionTemplateIncludesImports() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("nums", "integer[]"), ("node", "ListNode")],
            returnType: "Foo"
        )))
        let template = LeetCodeTemplateBuilder.template(for: meta, language: .python)

        XCTAssertNotNil(template)
        XCTAssertTrue(template?.contains("from typing import") == true)
        XCTAssertTrue(template?.contains("List") == true)
        XCTAssertTrue(template?.contains("Optional") == true)
        XCTAssertTrue(template?.contains("Any") == true)
    }

    func testTemplateBuilderClassDesignTemplates() throws {
        let metaJSON = """
        {"classname":"LRUCache","methods":[\
        {"name":"LRUCache","params":[{"name":"capacity","type":"integer"}],\
        "return":{"type":"void"}},\
        {"name":"get","params":[{"name":"key","type":"integer"}],\
        "return":{"type":"integer"}}]}
        """
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: metaJSON))
        let swiftTemplate = LeetCodeTemplateBuilder.template(for: meta, language: .swift)
        let pythonTemplate = LeetCodeTemplateBuilder.template(for: meta, language: .python)

        XCTAssertTrue(swiftTemplate?.contains("class LRUCache") == true)
        XCTAssertTrue(swiftTemplate?.contains("init") == true)
        XCTAssertTrue(pythonTemplate?.contains("class LRUCache") == true)
        XCTAssertTrue(pythonTemplate?.contains("def __init__") == true)
    }

    func testSafeIdentifiersEscapeKeywords() {
        XCTAssertEqual(LeetCodeTemplateBuilder.swiftSafeIdentifier("class", index: 0), "`class`")
        XCTAssertEqual(LeetCodeTemplateBuilder.pythonSafeIdentifier("class", index: 0), "class_")
    }
}
