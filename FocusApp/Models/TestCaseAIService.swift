import Foundation

protocol TestCaseAIProviding: Sendable {
    func generateTestCases(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [SolutionTestCase]
}

struct GeneratedTestCaseInputs: Codable, Sendable {
    let inputs: [String]
}

struct GeneratedTestCaseComplete: Codable, Sendable {
    let testCases: [GeneratedTestCaseItem]
}

struct GeneratedTestCaseItem: Codable, Sendable {
    let input: String
    let expectedOutput: String
    /// AI indicates whether output order matters. Nil means AI didn't specify (default to true).
    let orderMatters: Bool?
}

enum TestCaseGenerationError: Error, CustomStringConvertible {
    case invalidResponse(String)
    case missingApiKey

    var description: String {
        switch self {
        case .invalidResponse(let message):
            return message
        case .missingApiKey:
            return "AI provider API key is not configured. Set it in Settings."
        }
    }
}

enum TestCasePromptBuilder {
    static func build(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) -> String {
        let params = meta?.primaryParams
            .map { "\($0.name ?? "param"):\($0.type)" }
            .joined(separator: ", ") ?? "unknown"
        let exampleBlock = exampleInputs.prefix(2).joined(separator: "\n---\n")
        let sampleBlock = sampleInput?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let returnType = meta?.returnType?.type ?? "unknown"

        return """
        Generate \(count) diverse test cases for the LeetCode problem:
        \(problem.title) (\(problem.slug), \(problem.difficulty))
        Topics: \(problem.topics.joined(separator: ", "))
        Return type: \(returnType)

        Requirements:
        - Each test case has "input", "expectedOutput", and "orderMatters" (boolean).
        - "input" uses newline-separated parameter values in the EXACT order:
          \(params)
        - "expectedOutput" is the correct result as a string (e.g. "[0,1]", "true", "5").
        - "orderMatters": set to false ONLY when the problem explicitly says the answer \
        can be returned in any order (e.g. "return in any order", "order does not matter"). \
        Set to true for sorted outputs, sequences, traversals, or when order is significant.
        - Keep values within typical LeetCode constraints.
        - Include edge cases: empty inputs, single elements, duplicates, negatives, etc.
        - Ensure all expected outputs are CORRECT.

        Example input(s) from LeetCode:
        \(exampleBlock.isEmpty ? "(none)" : exampleBlock)

        Sample input (single case):
        \(sampleBlock.isEmpty ? "(none)" : sampleBlock)

        Return ONLY JSON in this exact schema:
        {
          "testCases": [
            {"input": "<val>", "expectedOutput": "<val>", "orderMatters": true},
            {"input": "<val>", "expectedOutput": "<val>", "orderMatters": false}
          ]
        }
        """
    }
}

extension SolutionAIServiceFactory {
    static func makeTestCaseProvider(from data: AppData) -> (any TestCaseAIProviding)? {
        let kind = AIProviderKind(rawValue: data.aiProviderKind) ?? .groq
        return makeProvider(kind: kind, apiKey: data.aiProviderApiKey, model: data.aiProviderModel)
            as? TestCaseAIProviding
    }
}

extension OpenAISolutionProvider: TestCaseAIProviding {
    func generateTestCases(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [SolutionTestCase] {
        let prompt = TestCasePromptBuilder.build(
            for: problem,
            meta: meta,
            sampleInput: sampleInput,
            exampleInputs: exampleInputs,
            count: count
        )
        let request = OpenAIRequest(
            model: model,
            messages: [
                .system("You output only valid JSON. No markdown."),
                .user(prompt)
            ],
            responseFormat: .json
        )
        let payload = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            let snippet = body.prefix(200)
            throw TestCaseGenerationError.invalidResponse(
                "OpenAI HTTP \(status): \(snippet)"
            )
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw TestCaseGenerationError.invalidResponse("Missing content")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: content)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw TestCaseGenerationError.invalidResponse("JSON encoding failed")
        }

        let generated = try JSONDecoder().decode(GeneratedTestCaseComplete.self, from: jsonData)
        return sanitizeTestCases(generated.testCases, targetCount: count)
    }
}

extension GeminiSolutionProvider: TestCaseAIProviding {
    func generateTestCases(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [SolutionTestCase] {
        let prompt = TestCasePromptBuilder.build(
            for: problem,
            meta: meta,
            sampleInput: sampleInput,
            exampleInputs: exampleInputs,
            count: count
        )
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/"
            + "\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw TestCaseGenerationError.invalidResponse("Gemini URL is invalid")
        }

        let systemInstruction = "You output only valid JSON. No markdown fences. " +
            "No explanation outside the JSON object."
        let request = GeminiRequest(
            contents: [GeminiContent(
                parts: [GeminiPart(text: prompt)]
            )],
            systemInstruction: GeminiContent(
                parts: [GeminiPart(text: systemInstruction)]
            ),
            generationConfig: GeminiGenerationConfig(
                responseMimeType: "application/json",
                maxOutputTokens: 8192
            )
        )
        let payload = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw TestCaseGenerationError.invalidResponse("Gemini: no HTTP response")
        }

        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw TestCaseGenerationError.invalidResponse(
                "Gemini HTTP \(http.statusCode): \(body.prefix(200))"
            )
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw TestCaseGenerationError.invalidResponse("Gemini: no text in response")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: text)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw TestCaseGenerationError.invalidResponse("Gemini: JSON encoding failed")
        }

        let generated = try JSONDecoder().decode(GeneratedTestCaseComplete.self, from: jsonData)
        return sanitizeTestCases(generated.testCases, targetCount: count)
    }
}

private func sanitizeTestCases(
    _ items: [GeneratedTestCaseItem],
    targetCount: Int
) -> [SolutionTestCase] {
    let valid = items
        .filter {
            !$0.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !$0.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    var seen = Set<String>()
    let unique = valid.filter { seen.insert($0.input).inserted }
    return Array(unique.prefix(targetCount)).map {
        SolutionTestCase(
            input: $0.input.trimmingCharacters(in: .whitespacesAndNewlines),
            expectedOutput: $0.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines),
            orderMatters: $0.orderMatters ?? true
        )
    }
}
