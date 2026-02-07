import Foundation

protocol TestCaseAIProviding: Sendable {
    func generateTestInputs(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [String]
}

struct GeneratedTestCaseInputs: Codable, Sendable {
    let inputs: [String]
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

        return """
        Generate \(count) diverse test inputs for the LeetCode problem:
        \(problem.title) (\(problem.slug), \(problem.difficulty))
        Topics: \(problem.topics.joined(separator: ", "))

        Input format requirements:
        - Each test case is a FULL input string for one run.
        - Use newline-separated parameter values in the EXACT order:
          \(params)
        - Keep values within typical LeetCode constraints.
        - Do NOT include expected outputs or explanations.

        Example input(s) from LeetCode:
        \(exampleBlock.isEmpty ? "(none)" : exampleBlock)

        Sample input (single case):
        \(sampleBlock.isEmpty ? "(none)" : sampleBlock)

        Return ONLY JSON in this exact schema:
        {
          "inputs": ["<input-1>", "<input-2>", "..."]
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
    func generateTestInputs(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [String] {
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

        let inputs = try JSONDecoder().decode(GeneratedTestCaseInputs.self, from: jsonData)
        return sanitizeInputs(inputs.inputs, targetCount: count)
    }
}

extension GeminiSolutionProvider: TestCaseAIProviding {
    func generateTestInputs(
        for problem: ManifestProblem,
        meta: LeetCodeMetaData?,
        sampleInput: String?,
        exampleInputs: [String],
        count: Int
    ) async throws -> [String] {
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
                maxOutputTokens: 4096
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

        let inputs = try JSONDecoder().decode(GeneratedTestCaseInputs.self, from: jsonData)
        return sanitizeInputs(inputs.inputs, targetCount: count)
    }
}

private func sanitizeInputs(_ inputs: [String], targetCount: Int) -> [String] {
    let trimmed = inputs
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    var seen = Set<String>()
    let unique = trimmed.filter { seen.insert($0).inserted }
    if unique.count <= targetCount {
        return unique
    }
    return Array(unique.prefix(targetCount))
}
