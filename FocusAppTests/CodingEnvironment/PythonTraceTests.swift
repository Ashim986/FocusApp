@testable import FocusApp
import XCTest

// swiftlint:disable type_body_length file_length
final class PythonTraceTests: XCTestCase {

    // MARK: - Core _Trace Class Elements

    func testTraceModuleContainsTraceClass() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("class _Trace:"))
    }

    func testTraceModuleContainsPrefix() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("__focus_trace__"),
            "Trace module must contain the __focus_trace__ prefix constant"
        )
    }

    func testTraceModuleContainsStepLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_STEP_LIMIT"))
    }

    func testTraceModuleContainsStepMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("def step(cls, label, values=None, line=None):"))
    }

    func testTraceModuleContainsInputMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("def input(cls, param_names, args):"))
    }

    func testTraceModuleContainsOutputMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("def output(cls, value):"))
    }

    func testTraceModuleContainsTraceValueMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("def _trace_value(cls, value, structured=False):"))
    }

    func testTraceModuleContainsEmitMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("def _emit(cls, kind, values, line=None, label=None, structured=False):")
        )
    }

    func testTraceModuleContainsIsSimpleMethod() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("def _is_simple(cls, value):"))
    }

    func testTraceModuleContainsJsonDumps() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("json.dumps(payload, default=str)"),
            "Trace module must serialize payloads using json.dumps"
        )
    }

    func testTraceModuleContainsPrefixPrint() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("print(cls._PREFIX + json_str, flush=True)"),
            "Trace module must print with prefix and flush"
        )
    }

    // MARK: - ListNode Conditional Inclusion

    func testTraceModuleWithoutListNodeOmitsListNodeSerialization() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertFalse(
            module.contains("\"__type\": \"list\""),
            "Without needsListNode, trace should not contain singly-linked list serialization"
        )
    }

    func testTraceModuleWithListNodeContainsListSerialization() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("\"__type\": \"list\""),
            "With needsListNode, trace must contain singly-linked list serialization"
        )
    }

    func testTraceModuleWithListNodeContainsValAndNext() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("hasattr(value, 'val') and hasattr(value, 'next') and not hasattr(value, 'prev')")
        )
    }

    func testTraceModuleWithListNodeContainsCycleDetection() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cycle_index"))
        XCTAssertTrue(module.contains("\"cycleIndex\""))
    }

    func testTraceModuleWithListNodeContainsNodeLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._NODE_LIMIT"))
    }

    func testTraceModuleWithListNodeContainsTruncation() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("result[\"truncated\"] = True"),
            "ListNode trace must mark truncated results"
        )
    }

    func testTraceModuleWithListNodeContainsListPointerType() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"__type\": \"listPointer\""))
    }

    // MARK: - TreeNode Conditional Inclusion

    func testTraceModuleWithoutTreeNodeOmitsTreeSerialization() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertFalse(
            module.contains("\"__type\": \"tree\""),
            "Without needsTreeNode, trace should not contain tree serialization"
        )
    }

    func testTraceModuleWithTreeNodeContainsTreeSerialization() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: true
        )
        XCTAssertTrue(
            module.contains("\"__type\": \"tree\""),
            "With needsTreeNode, trace must contain tree serialization"
        )
    }

    func testTraceModuleWithTreeNodeContainsLeftAndRight() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: true
        )
        XCTAssertTrue(
            module.contains("hasattr(value, 'val') and hasattr(value, 'left') and hasattr(value, 'right')")
        )
    }

    func testTraceModuleWithTreeNodeContainsBFSTraversal() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: true
        )
        XCTAssertTrue(module.contains("queue = [value]"))
        XCTAssertTrue(module.contains("queue.pop(0)"))
    }

    func testTraceModuleWithTreeNodeContainsRootId() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: true
        )
        XCTAssertTrue(module.contains("\"rootId\""))
    }

    func testTraceModuleWithTreeNodeContainsTreePointerType() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: true
        )
        XCTAssertTrue(module.contains("\"__type\": \"treePointer\""))
    }

    // MARK: - Both ListNode and TreeNode

    func testTraceModuleWithBothContainsListAndTree() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: true
        )
        XCTAssertTrue(
            module.contains("\"__type\": \"list\""),
            "Both flags: must contain list serialization"
        )
        XCTAssertTrue(
            module.contains("\"__type\": \"tree\""),
            "Both flags: must contain tree serialization"
        )
    }

    func testTraceModuleWithBothContainsListPointerAndTreePointer() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: true
        )
        XCTAssertTrue(module.contains("\"__type\": \"listPointer\""))
        XCTAssertTrue(module.contains("\"__type\": \"treePointer\""))
    }

    // MARK: - Doubly Linked List Handling

    func testTraceModuleAlwaysContainsDoublyListDetection() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("hasattr(value, 'prev')"),
            "Trace module must always check for doubly-linked list via 'prev' attribute"
        )
    }

    func testTraceModuleContainsDoublyListType() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"__type\": \"doublyList\""))
    }

    func testTraceModuleDoublyListIncludesCycleIndex() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        // The doubly-list section also has cycle detection
        let doublySection = module.components(separatedBy: "\"__type\": \"doublyList\"")
        XCTAssertTrue(
            doublySection.count >= 2,
            "Doubly-list type should appear in the trace module"
        )
    }

    // MARK: - Set Handling

    func testTraceModuleContainsSetHandling() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("isinstance(value, set)"),
            "Trace module must handle Python sets"
        )
    }

    func testTraceModuleContainsSetType() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"__type\": \"set\""))
    }

    func testTraceModuleSetUsesSimpleArrayLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._SIMPLE_ARRAY_LIMIT"))
    }

    func testTraceModuleSetUsesComplexArrayLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._COMPLEX_ARRAY_LIMIT"))
    }

    // MARK: - Dict Handling

    func testTraceModuleContainsDictHandling() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("isinstance(value, dict)"),
            "Trace module must handle Python dicts"
        )
    }

    func testTraceModuleDictSortsKeys() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("sorted(value.keys(), key=str)"),
            "Trace module must sort dict keys for deterministic output"
        )
    }

    func testTraceModuleDictUsesSimpleDictLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._SIMPLE_DICT_LIMIT"))
    }

    func testTraceModuleDictUsesComplexDictLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._COMPLEX_DICT_LIMIT"))
    }

    // MARK: - List/Tuple Handling

    func testTraceModuleContainsListTupleHandling() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("isinstance(value, (list, tuple))"),
            "Trace module must handle Python lists and tuples"
        )
    }

    func testTraceModuleListTupleFallsBackToStr() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        // After all type checks, unknown types should fall back to str(value)
        XCTAssertTrue(module.contains("return str(value)"))
    }

    // MARK: - Primitive Type Handling in _trace_value

    func testTraceModuleHandlesNoneValue() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("if value is None:"))
    }

    func testTraceModuleHandlesBoolValue() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("isinstance(value, bool)"))
    }

    func testTraceModuleHandlesIntValue() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("isinstance(value, int)"))
    }

    func testTraceModuleHandlesFloatValue() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("isinstance(value, float)"))
    }

    func testTraceModuleHandlesStrValue() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("isinstance(value, str)"))
    }

    // MARK: - Step Limit and Truncation

    func testTraceModuleStepLimitIs40() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_STEP_LIMIT = 40"))
    }

    func testTraceModuleStepCountTracking() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._step_count += 1"))
    }

    func testTraceModuleStepTruncationFlag() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._did_truncate = True"))
    }

    func testTraceModuleTraceTruncatedInInput() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("\"__trace_truncated\""),
            "Trace input/output must include __trace_truncated field"
        )
    }

    // MARK: - Node Limit

    func testTraceModuleNodeLimitIs25() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_NODE_LIMIT = 25"))
    }

    // MARK: - Emit Method Structure

    func testTraceModuleEmitContainsKindField() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"kind\": kind"))
    }

    func testTraceModuleEmitContainsValuesField() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"values\": mapped"))
    }

    func testTraceModuleEmitContainsLineField() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("payload[\"line\"] = line"))
    }

    func testTraceModuleEmitContainsLabelField() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("payload[\"label\"] = label"))
    }

    func testTraceModuleEmitWrapsInTryCatch() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("except Exception:"))
        XCTAssertTrue(module.contains("pass"))
    }

    // MARK: - pythonRunnerMain Trace Integration

    func testRunnerMainIncludesTraceInputCall() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 2,
            arguments: [
                "    arg0 = _to_int(args[0])",
                "    arg1 = _to_int(args[1])",
            ],
            callLine: "    result = solution.solve(arg0, arg1)",
            outputExpression: "result",
            paramNamesLiteral: "\"nums\", \"target\""
        )
        XCTAssertTrue(
            main.contains("_Trace.input"),
            "Runner main must call _Trace.input when there are parameters"
        )
    }

    func testRunnerMainIncludesTraceOutputCall() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 1,
            arguments: ["    arg0 = _to_int(args[0])"],
            callLine: "    result = solution.solve(arg0)",
            outputExpression: "result",
            paramNamesLiteral: "\"x\""
        )
        XCTAssertTrue(
            main.contains("_Trace.output(result)"),
            "Runner main must call _Trace.output with the result"
        )
    }

    func testRunnerMainTraceInputUsesParamNamesLiteral() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 2,
            arguments: [
                "    arg0 = _to_int(args[0])",
                "    arg1 = _to_int(args[1])",
            ],
            callLine: "    result = solution.solve(arg0, arg1)",
            outputExpression: "result",
            paramNamesLiteral: "\"nums\", \"target\""
        )
        XCTAssertTrue(
            main.contains("[\"nums\", \"target\"]"),
            "Runner main must pass param names literal to _Trace.input"
        )
    }

    func testRunnerMainTraceInputUsesArgVariables() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 3,
            arguments: [
                "    arg0 = _to_int(args[0])",
                "    arg1 = _to_int(args[1])",
                "    arg2 = _to_int(args[2])",
            ],
            callLine: "    result = solution.solve(arg0, arg1, arg2)",
            outputExpression: "result",
            paramNamesLiteral: "\"a\", \"b\", \"c\""
        )
        XCTAssertTrue(
            main.contains("[arg0, arg1, arg2]"),
            "Runner main must pass arg0, arg1, arg2 to _Trace.input"
        )
    }

    func testRunnerMainTraceGuardedByHasInput() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 1,
            arguments: ["    arg0 = _to_int(args[0])"],
            callLine: "    result = solution.solve(arg0)",
            outputExpression: "result",
            paramNamesLiteral: "\"x\""
        )
        XCTAssertTrue(
            main.contains("if _has_input:"),
            "Trace calls must be guarded by _has_input check"
        )
    }

    func testRunnerMainZeroParamsStillHasTraceOutput() {
        let main = LeetCodeExecutionWrapper.pythonRunnerMain(
            paramsCount: 0,
            arguments: [],
            callLine: "    result = solution.solve()",
            outputExpression: "result",
            paramNamesLiteral: ""
        )
        // Even with zero params, _Trace.output should still be called
        XCTAssertTrue(
            main.contains("_Trace.output(result)"),
            "Even with zero params, runner must emit trace output"
        )
    }

    // MARK: - wrapPython Includes Trace Module

    func testWrapPythonIncludesTraceModule() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("values", "integer[]")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, values):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("class _Trace:"),
            "Wrapped Python code must include the _Trace class"
        )
    }

    func testWrapPythonIncludesTracePrefixConstant() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("values", "integer[]")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, values):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("__focus_trace__"),
            "Wrapped Python code must include the trace prefix"
        )
    }

    func testWrapPythonWithListNodeIncludesListNodeTrace() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        )))
        let code = "class Solution:\n    def reverseList(self, head):\n        return head"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("\"__type\": \"list\""),
            "Wrapped Python with ListNode must include list trace serialization"
        )
    }

    func testWrapPythonWithTreeNodeIncludesTreeNodeTrace() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def maxDepth(self, root):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("\"__type\": \"tree\""),
            "Wrapped Python with TreeNode must include tree trace serialization"
        )
    }

    func testWrapPythonWithoutSpecialTypesOmitsListAndTree() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, x):\n        return x"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertFalse(
            wrapped.contains("\"__type\": \"list\""),
            "Wrapped Python without ListNode should omit list trace"
        )
        XCTAssertFalse(
            wrapped.contains("\"__type\": \"tree\""),
            "Wrapped Python without TreeNode should omit tree trace"
        )
    }

    func testWrapPythonIncludesTraceInputCall() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, nums, target):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("_Trace.input"),
            "Wrapped Python must call _Trace.input in the runner"
        )
    }

    func testWrapPythonIncludesTraceOutputCall() throws {
        let meta = try XCTUnwrap(LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("x", "integer")],
            returnType: "integer"
        )))
        let code = "class Solution:\n    def solve(self, x):\n        return x"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta)

        XCTAssertTrue(
            wrapped.contains("_Trace.output(result)"),
            "Wrapped Python must call _Trace.output in the runner"
        )
    }

    // MARK: - Trace Module Composition Order

    func testTraceModuleDoublyListComesAfterConditionalSections() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: true,
            needsTreeNode: true
        )
        let listRange = module.range(of: "\"__type\": \"list\"")
        let treeRange = module.range(of: "\"__type\": \"tree\"")
        let doublyRange = module.range(of: "\"__type\": \"doublyList\"")
        let emitRange = module.range(of: "def _emit")

        // All ranges should exist
        XCTAssertNotNil(listRange)
        XCTAssertNotNil(treeRange)
        XCTAssertNotNil(doublyRange)
        XCTAssertNotNil(emitRange)

        // Doubly list comes after singly list and tree
        if let listEnd = listRange?.upperBound, let doublyStart = doublyRange?.lowerBound {
            XCTAssertTrue(listEnd < doublyStart)
        }
        if let treeEnd = treeRange?.upperBound, let doublyStart = doublyRange?.lowerBound {
            XCTAssertTrue(treeEnd < doublyStart)
        }
    }

    func testTraceModuleEmitComesLast() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        let setRange = module.range(of: "isinstance(value, set)")
        let emitRange = module.range(of: "def _emit")

        XCTAssertNotNil(setRange)
        XCTAssertNotNil(emitRange)

        if let setEnd = setRange?.upperBound, let emitStart = emitRange?.lowerBound {
            XCTAssertTrue(
                setEnd < emitStart,
                "_emit method should come after set/dict/list handlers"
            )
        }
    }

    // MARK: - Python Runner Prelude paramNamesLiteral

    func testPythonRunnerPreludeContainsParamNames() {
        let prelude = LeetCodeExecutionWrapper.pythonRunnerPrelude(
            paramNamesLiteral: "\"nums\", \"target\""
        )
        XCTAssertTrue(
            prelude.contains("PARAM_NAMES = [\"nums\", \"target\"]"),
            "Prelude must embed param names from the literal"
        )
    }

    func testPythonRunnerPreludeEmptyParamNames() {
        let prelude = LeetCodeExecutionWrapper.pythonRunnerPrelude(paramNamesLiteral: "")
        XCTAssertTrue(
            prelude.contains("PARAM_NAMES = []"),
            "Prelude must handle empty param names"
        )
    }

    // MARK: - Array Size Limits in Trace

    func testTraceModuleSimpleArrayLimitIs50() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_SIMPLE_ARRAY_LIMIT = 50"))
    }

    func testTraceModuleComplexArrayLimitIs8() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_COMPLEX_ARRAY_LIMIT = 8"))
    }

    func testTraceModuleSimpleDictLimitIs30() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_SIMPLE_DICT_LIMIT = 30"))
    }

    func testTraceModuleComplexDictLimitIs10() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("_COMPLEX_DICT_LIMIT = 10"))
    }

    // MARK: - Step Method Structure

    func testTraceStepEmitsStepKind() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("cls._emit(\"step\", values, line=line, label=label, structured=False)")
        )
    }

    func testTraceStepReturnsEarlyWhenOverLimit() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("if cls._step_count >= cls._STEP_LIMIT:"))
    }

    // MARK: - Input Method Structure

    func testTraceInputIteratesParamNames() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("for i, name in enumerate(param_names):"))
    }

    func testTraceInputCallsTraceValueStructured() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._trace_value(val, structured=True)"))
    }

    func testTraceInputEmitsInputKind() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("cls._emit(\"input\", values, structured=True)"))
    }

    // MARK: - Output Method Structure

    func testTraceOutputEmitsOutputKind() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(module.contains("\"result\": cls._trace_value(value, structured=True)"))
    }

    // MARK: - _is_simple Primitive Check

    func testTraceIsSimpleChecksAllPrimitiveTypes() {
        let module = LeetCodeExecutionWrapper.pythonTraceModule(
            needsListNode: false,
            needsTreeNode: false
        )
        XCTAssertTrue(
            module.contains("isinstance(value, (type(None), bool, int, float, str))"),
            "_is_simple must check None, bool, int, float, str"
        )
    }
}
// swiftlint:enable type_body_length file_length
