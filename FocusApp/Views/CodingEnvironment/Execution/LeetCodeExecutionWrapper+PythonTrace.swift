import Foundation

extension LeetCodeExecutionWrapper {
    static func pythonTraceModule(needsListNode: Bool, needsTreeNode: Bool) -> String {
        var lines = [pythonTraceBase]

        if needsListNode {
            lines.append(pythonTraceListNode)
        }
        if needsTreeNode {
            lines.append(pythonTraceTreeNode)
        }

        lines.append(pythonTraceDoublyList)
        lines.append(pythonTraceTail)
        lines.append(pythonTraceEmitAndHelpers)

        return lines.joined(separator: "\n")
    }

    private static let pythonTraceBase = """

        class _Trace:
            _PREFIX = "__focus_trace__"
            _step_count = 0
            _STEP_LIMIT = 40
            _did_truncate = False
            _NODE_LIMIT = 25
            _SIMPLE_ARRAY_LIMIT = 50
            _COMPLEX_ARRAY_LIMIT = 8
            _SIMPLE_DICT_LIMIT = 30
            _COMPLEX_DICT_LIMIT = 10

            @classmethod
            def step(cls, label, values=None, line=None):
                if cls._step_count >= cls._STEP_LIMIT:
                    cls._did_truncate = True
                    return
                cls._step_count += 1
                if values is None:
                    values = {}
                cls._emit("step", values, line=line, label=label, structured=False)

            @classmethod
            def input(cls, param_names, args):
                if not args:
                    return
                values = {}
                for i, name in enumerate(param_names):
                    val = args[i] if i < len(args) else None
                    values[name] = cls._trace_value(val, structured=True)
                values["__trace_truncated"] = cls._did_truncate
                cls._emit("input", values, structured=True)

            @classmethod
            def output(cls, value):
                cls._emit("output", {
                    "result": cls._trace_value(value, structured=True),
                    "__trace_truncated": cls._did_truncate,
                }, structured=True)

            @classmethod
            def _is_simple(cls, value):
                return isinstance(value, (type(None), bool, int, float, str))

            @classmethod
            def _trace_value(cls, value, structured=False):
                if value is None:
                    return None
                if isinstance(value, bool):
                    return value
                if isinstance(value, int):
                    return value
                if isinstance(value, float):
                    return value
                if isinstance(value, str):
                    return value
        """

    private static let pythonTraceListNode = """
                if hasattr(value, 'val') and hasattr(value, 'next') and not hasattr(value, 'prev'):
                    if structured:
                        nodes = []
                        visited = {}
                        current = value
                        idx = 0
                        cycle_index = None
                        while current is not None and idx < cls._NODE_LIMIT:
                            nid = id(current)
                            if nid in visited:
                                cycle_index = visited[nid]
                                break
                            visited[nid] = idx
                            nodes.append({"id": str(nid), "value": cls._trace_value(current.val, structured=True)})
                            current = current.next
                            idx += 1
                        result = {"__type": "list", "nodes": nodes}
                        if cycle_index is not None:
                            result["cycleIndex"] = cycle_index
                        if current is not None and cycle_index is None:
                            result["truncated"] = True
                        return result
                    return {"__type": "listPointer", "id": str(id(value))}
        """

    private static let pythonTraceTreeNode = """
                if hasattr(value, 'val') and hasattr(value, 'left') and hasattr(value, 'right'):
                    if structured:
                        nodes = []
                        queue = [value]
                        visited = set()
                        count = 0
                        while queue and count < cls._NODE_LIMIT:
                            node = queue.pop(0)
                            nid = id(node)
                            if nid in visited:
                                continue
                            visited.add(nid)
                            payload = {
                                "id": str(nid),
                                "value": cls._trace_value(node.val, structured=True),
                            }
                            if node.left is not None:
                                payload["left"] = str(id(node.left))
                                queue.append(node.left)
                            if node.right is not None:
                                payload["right"] = str(id(node.right))
                                queue.append(node.right)
                            nodes.append(payload)
                            count += 1
                        result = {"__type": "tree", "nodes": nodes}
                        if nodes:
                            result["rootId"] = str(id(value))
                        if queue:
                            result["truncated"] = True
                        return result
                    return {"__type": "treePointer", "id": str(id(value))}
        """

    private static let pythonTraceDoublyList = """
                if hasattr(value, 'val') and hasattr(value, 'next') and hasattr(value, 'prev'):
                    if structured:
                        nodes = []
                        visited = {}
                        current = value
                        idx = 0
                        cycle_index = None
                        while current is not None and idx < cls._NODE_LIMIT:
                            nid = id(current)
                            if nid in visited:
                                cycle_index = visited[nid]
                                break
                            visited[nid] = idx
                            nodes.append({"id": str(nid), "value": cls._trace_value(current.val, structured=True)})
                            current = current.next
                            idx += 1
                        result = {"__type": "doublyList", "nodes": nodes}
                        if cycle_index is not None:
                            result["cycleIndex"] = cycle_index
                        if current is not None and cycle_index is None:
                            result["truncated"] = True
                        return result
                    return {"__type": "listPointer", "id": str(id(value))}
        """

    private static let pythonTraceTail = """
                if isinstance(value, set):
                    items = list(value)
                    if structured:
                        lim = (
                            cls._SIMPLE_ARRAY_LIMIT
                            if all(cls._is_simple(v) for v in items)
                            else cls._COMPLEX_ARRAY_LIMIT
                        )
                        if len(items) > lim:
                            cls._did_truncate = True
                        items = items[:lim]
                    return {"__type": "set", "value": [cls._trace_value(v, structured=structured) for v in items]}
                if isinstance(value, dict):
                    keys = sorted(value.keys(), key=str)
                    if structured:
                        lim = cls._SIMPLE_DICT_LIMIT if all(
                            cls._is_simple(value[k]) for k in keys
                        ) else cls._COMPLEX_DICT_LIMIT
                        if len(keys) > lim:
                            cls._did_truncate = True
                        keys = keys[:lim]
                    return {str(k): cls._trace_value(value[k], structured=structured) for k in keys}
                if isinstance(value, (list, tuple)):
                    items = list(value)
                    if structured:
                        lim = (
                            cls._SIMPLE_ARRAY_LIMIT
                            if all(cls._is_simple(v) for v in items)
                            else cls._COMPLEX_ARRAY_LIMIT
                        )
                        if len(items) > lim:
                            cls._did_truncate = True
                        items = items[:lim]
                    return [cls._trace_value(v, structured=structured) for v in items]
                return str(value)
        """

    private static let pythonTraceEmitAndHelpers = """

            @classmethod
            def _emit(cls, kind, values, line=None, label=None, structured=False):
                mapped = {}
                for k, v in values.items():
                    if structured:
                        mapped[k] = v
                    else:
                        mapped[k] = cls._trace_value(v, structured=False) if v is not None else None
                payload = {"kind": kind, "values": mapped}
                if line is not None:
                    payload["line"] = line
                if label is not None:
                    payload["label"] = label
                try:
                    json_str = json.dumps(payload, default=str)
                    print(cls._PREFIX + json_str, flush=True)
                except Exception:
                    pass
        """
}
