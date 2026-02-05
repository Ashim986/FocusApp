import Foundation

extension LeetCodeExecutionWrapper {
    static func pythonRunnerPrelude(paramNamesLiteral: String) -> String {
        """
        # FocusApp LeetCode Runner
        import json
        import sys
        from typing import List, Optional
        PARAM_NAMES = [\(paramNamesLiteral)]

        def _parse_kv_input(raw, param_names):
            import re
            if not param_names:
                return {}
            matches = list(re.finditer(r"\\b([A-Za-z_][A-Za-z0-9_]*)\\b\\s*=", raw))
            if not matches:
                return {}
            results = {}
            for idx, match in enumerate(matches):
                name = match.group(1)
                start = match.end()
                end = matches[idx + 1].start() if idx + 1 < len(matches) else len(raw)
                value = raw[start:end].strip().strip(",")
                if not value:
                    continue
                try:
                    results[name] = json.loads(value)
                except json.JSONDecodeError:
                    results[name] = value
            return {name: results[name] for name in param_names if name in results}

        def _parse_args(raw, expected_count):
            raw = raw.strip()
            if not raw:
                return []
            kv = _parse_kv_input(raw, PARAM_NAMES)
            if kv:
                return [kv[name] for name in PARAM_NAMES if name in kv]
            try:
                data = json.loads(raw)
                if expected_count == 1:
                    return [data]
                if isinstance(data, list):
                    return data
                return [data]
            except json.JSONDecodeError:
                lines = [line for line in raw.splitlines() if line.strip()]
                values = []
                for line in lines:
                    try:
                        values.append(json.loads(line))
                    except json.JSONDecodeError:
                        values.append(line)
                if expected_count == 1:
                    if len(values) == 1:
                        return [values[0]]
                    if not values:
                        return []
                    return [values]
                if expected_count and len(values) > expected_count:
                    return values[:expected_count]
                return values
        """
    }

    static func pythonRunnerConversions(listNodeHelpers: String, treeNodeHelpers: String) -> String {
        """

        def _to_int(value):
            if isinstance(value, bool):
                return int(value)
            if isinstance(value, (int, float)):
                return int(value)
            try:
                return int(str(value).strip())
            except ValueError:
                return 0

        def _to_float(value):
            if isinstance(value, (int, float)):
                return float(value)
            try:
                return float(str(value).strip())
            except ValueError:
                return 0.0

        def _to_bool(value):
            if isinstance(value, bool):
                return value
            if isinstance(value, (int, float)):
                return value != 0
            return str(value).strip().lower() in {"true", "1"}

        def _to_str(value):
            return str(value)

        def _to_list(value, transform):
            if not isinstance(value, list):
                return []
            return [transform(item) for item in value]

        def _to_dict(value, key_transform, value_transform):
            if not isinstance(value, dict):
                return {}
            return {key_transform(k): value_transform(v) for k, v in value.items()}
        \(listNodeHelpers)
        \(treeNodeHelpers)
        """
    }

    static func pythonRunnerMain(
        paramsCount: Int,
        arguments: [String],
        callLine: String,
        outputExpression: String
    ) -> String {
        let argumentsString = arguments.joined(separator: "\n")
        return """

        def _serialize_output(value):
            return value

        def _run():
            raw = sys.stdin.read()
            args = _parse_args(raw, \(paramsCount))
            solution = Solution()
        \(argumentsString)
        \(callLine)
            output = \(outputExpression)
            print(json.dumps(output))

        if __name__ == "__main__":
            _run()
        """
    }
}
