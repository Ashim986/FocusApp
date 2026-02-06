import Foundation

// MARK: - AI Response Models

/// Intermediate model for AI-generated solutions before mapping to app types.
struct GeneratedSolution: Codable, Sendable {
    let summary: String
    let approaches: [GeneratedApproach]
    let relatedProblems: [String]?
}

/// Intermediate approach from AI response.
struct GeneratedApproach: Codable, Sendable {
    let name: String
    let intuition: String
    let approach: String
    let explanation: String
    let code: String
    let complexity: ComplexityAnalysis
    let testCases: [GeneratedTestCase]
}

/// Intermediate test case from AI response.
struct GeneratedTestCase: Codable, Sendable {
    let input: String
    let expectedOutput: String
    let explanation: String?
}

// MARK: - Provider Kind

/// Supported AI provider types for solution generation.
enum AIProviderKind: String, CaseIterable, Sendable {
    case groq
    case gemini

    var displayName: String {
        switch self {
        case .groq: return "Groq"
        case .gemini: return "Gemini"
        }
    }

    var defaultModel: String {
        switch self {
        case .groq: return "llama-3.3-70b-versatile"
        case .gemini: return "gemini-2.5-flash-lite"
        }
    }

    var modelOptions: [String] {
        switch self {
        case .groq:
            return [
                "llama-3.3-70b-versatile",
                "llama-3.1-8b-instant",
                "mixtral-8x7b-32768"
            ]
        case .gemini:
            return [
                "gemini-2.5-flash-lite",
                "gemini-2.0-flash",
                "gemini-2.0-flash-lite"
            ]
        }
    }
}

// MARK: - Provider Factory

/// Creates AI solution providers from app settings.
enum SolutionAIServiceFactory {
    /// Creates a provider from the stored configuration.
    /// Returns nil if API key is empty.
    static func makeProvider(
        kind: AIProviderKind,
        apiKey: String,
        model: String
    ) -> (any SolutionAIProviding)? {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return nil }

        let resolvedModel = model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? kind.defaultModel
            : model.trimmingCharacters(in: .whitespacesAndNewlines)

        switch kind {
        case .groq:
            guard let groqURL = URL(
                string: "https://api.groq.com/openai/v1/chat/completions"
            ) else { return nil }
            return OpenAISolutionProvider(
                apiKey: trimmedKey,
                model: resolvedModel,
                baseURL: groqURL
            )
        case .gemini:
            return GeminiSolutionProvider(
                apiKey: trimmedKey,
                model: resolvedModel
            )
        }
    }

    /// Creates a provider from stored AppData fields.
    static func makeProvider(from data: AppData) -> (any SolutionAIProviding)? {
        let kind = AIProviderKind(rawValue: data.aiProviderKind) ?? .groq
        return makeProvider(kind: kind, apiKey: data.aiProviderApiKey, model: data.aiProviderModel)
    }
}

// MARK: - Provider Protocol

/// Abstraction for AI-powered solution generation.
/// Compatible with Groq, Gemini, and other OpenAI-compatible endpoints.
protocol SolutionAIProviding: Sendable {
    func generateSolution(
        for problem: ManifestProblem
    ) async throws -> GeneratedSolution
}

// MARK: - OpenAI Provider

/// Generates solutions via OpenAI-compatible APIs (also works with Groq, OpenRouter).
struct OpenAISolutionProvider: SolutionAIProviding {
    let apiKey: String
    let model: String
    let baseURL: URL

    func generateSolution(
        for problem: ManifestProblem
    ) async throws -> GeneratedSolution {
        let prompt = SolutionPromptBuilder.build(for: problem)
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
            throw SolutionGenerationError.network("OpenAI HTTP \(status): \(snippet)")
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw SolutionGenerationError.invalidResponse("Missing content")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: content)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SolutionGenerationError.invalidResponse("JSON encoding failed")
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - OpenAI DTOs

struct OpenAIResponseFormat: Encodable, Sendable {
    let type: String

    static let json = OpenAIResponseFormat(type: "json_object")
}

struct OpenAIRequest: Encodable, Sendable {
    let model: String
    let messages: [OpenAIMessage]
    let responseFormat: OpenAIResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model, messages
        case responseFormat = "response_format"
    }

    init(
        model: String,
        messages: [OpenAIMessage],
        responseFormat: OpenAIResponseFormat? = nil
    ) {
        self.model = model
        self.messages = messages
        self.responseFormat = responseFormat
    }
}

struct OpenAIMessage: Encodable, Sendable {
    let role: String
    let content: String

    static func system(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "system", content: content)
    }

    static func user(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "user", content: content)
    }
}

struct OpenAIResponse: Decodable, Sendable {
    struct Choice: Decodable, Sendable {
        struct Message: Decodable, Sendable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - Gemini Provider

/// Generates solutions via the Google Gemini API.
struct GeminiSolutionProvider: SolutionAIProviding {
    let apiKey: String
    let model: String

    func generateSolution(
        for problem: ManifestProblem
    ) async throws -> GeneratedSolution {
        let prompt = SolutionPromptBuilder.build(for: problem)
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/"
            + "\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw SolutionGenerationError.invalidResponse("Gemini URL is invalid")
        }

        let systemInstruction = "You output only valid JSON. No markdown fences. "
            + "No explanation outside the JSON object."
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
            throw SolutionGenerationError.network("Gemini: no HTTP response")
        }

        if http.statusCode == 429 {
            throw SolutionGenerationError.network("Gemini: rate limited (429)")
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw SolutionGenerationError.network(
                "Gemini HTTP \(http.statusCode): \(body.prefix(200))"
            )
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw SolutionGenerationError.invalidResponse(
                "Gemini: no text in response"
            )
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: text)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SolutionGenerationError.invalidResponse(
                "Gemini: JSON encoding failed"
            )
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - Gemini DTOs

struct GeminiRequest: Encodable, Sendable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiContent
    let generationConfig: GeminiGenerationConfig

    enum CodingKeys: String, CodingKey {
        case contents
        case systemInstruction = "system_instruction"
        case generationConfig = "generation_config"
    }
}

struct GeminiContent: Encodable, Sendable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable, Sendable {
    let text: String
}

struct GeminiGenerationConfig: Encodable, Sendable {
    let responseMimeType: String
    let maxOutputTokens: Int

    enum CodingKeys: String, CodingKey {
        case responseMimeType = "response_mime_type"
        case maxOutputTokens = "max_output_tokens"
    }
}

struct GeminiResponse: Decodable, Sendable {
    struct Candidate: Decodable, Sendable {
        struct Content: Decodable, Sendable {
            let parts: [GeminiPart]
        }
        let content: Content
    }
    let candidates: [Candidate]?
}

// MARK: - Prompt Builder

/// Constructs the LLM prompt for generating a LeetCode solution.
enum SolutionPromptBuilder {
    static func build(for problem: ManifestProblem) -> String {
        """
        Generate a LeetCode solution for: \(problem.title) (\(problem.slug), \(problem.difficulty)).
        Topics: \(problem.topics.joined(separator: ", "))

        Return ONLY a JSON object matching this EXACT schema (all values are strings unless noted):
        {
          "summary": "<1-2 sentence string describing the problem and key insight>",
          "approaches": [
            {
              "name": "<string: approach name>",
              "intuition": "<string: why this works>",
              "approach": "<string: step-by-step algorithm>",
              "explanation": "<string: detailed walkthrough>",
              "code": "<string: complete Swift solution>",
              "complexity": {
                "time": "<string: e.g. O(n)>",
                "space": "<string: e.g. O(1)>",
                "timeExplanation": "<string>",
                "spaceExplanation": "<string>"
              },
              "testCases": [
                {
                  "input": "<string: e.g. nums = [2,7,11,15], target = 9>",
                  "expectedOutput": "<string: e.g. [0,1]>",
                  "explanation": "<string>"
                }
              ]
            }
          ],
          "relatedProblems": ["<slug-1>", "<slug-2>"]
        }

        CRITICAL RULES:
        - "summary" MUST be a plain string, NOT an object.
        - Include exactly 2 approaches: one brute-force/baseline, one optimized.
        - "code" must be complete, compilable Swift.
        - Each approach must have at least 2 testCases.
        - "relatedProblems" is an array of slug strings.
        """
    }
}

// MARK: - JSON Helpers

/// Utilities for extracting and sanitizing JSON from LLM output.
enum JSONExtractor {
    /// Strips markdown code fences and extracts the JSON object from raw text.
    static func extractJSONObject(from content: String) -> String {
        var text = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```swift", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}"),
           start <= end {
            text = String(text[start...end])
        }
        return text
    }

    /// Fixes unescaped control characters inside JSON string values.
    /// Some LLMs emit real newlines/tabs inside strings instead of `\n` `\t`.
    static func sanitizeJSON(_ raw: String) -> String {
        var result = ""
        var inString = false
        var prevChar: Character = " "
        for char in raw {
            if char == "\"" && prevChar != "\\" {
                inString.toggle()
            }
            if inString {
                switch char {
                case "\n": result += "\\n"
                case "\r": result += "\\r"
                case "\t": result += "\\t"
                default: result.append(char)
                }
            } else {
                result.append(char)
            }
            prevChar = char
        }
        return result
    }
}

// MARK: - Errors

/// Errors that can occur during AI solution generation.
enum SolutionGenerationError: Error, CustomStringConvertible {
    case invalidResponse(String)
    case validationFailed(String)
    case network(String)
    case missingApiKey

    var description: String {
        switch self {
        case .invalidResponse(let message),
             .validationFailed(let message),
             .network(let message):
            return message
        case .missingApiKey:
            return "AI provider API key is not configured. Set it in Settings."
        }
    }
}

// MARK: - Mapping & Validation

/// Converts AI-generated solutions to app data models and validates output quality.
enum SolutionMapper {
    /// Validates that an AI-generated solution meets quality requirements.
    static func validate(
        _ solution: GeneratedSolution,
        slug: String
    ) throws {
        guard !solution.summary
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SolutionGenerationError.validationFailed(
                "\(slug): summary is empty"
            )
        }
        guard solution.approaches.count >= 2 else {
            throw SolutionGenerationError.validationFailed(
                "\(slug): need at least 2 approaches"
            )
        }
        for (index, approach) in solution.approaches.enumerated() {
            if approach.name
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw SolutionGenerationError.validationFailed(
                    "\(slug): approach \(index) missing name"
                )
            }
            if approach.code
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw SolutionGenerationError.validationFailed(
                    "\(slug): approach \(index) missing code"
                )
            }
        }
    }

    /// Maps an AI-generated solution to the app's `ProblemSolution` model.
    static func mapToSolution(
        _ generated: GeneratedSolution,
        slug: String
    ) -> ProblemSolution {
        let approaches = generated.approaches.enumerated().map { index, item in
            SolutionApproach(
                name: item.name,
                order: index + 1,
                intuition: item.intuition,
                approach: item.approach,
                explanation: item.explanation,
                code: item.code,
                complexity: item.complexity,
                testCases: item.testCases.map {
                    SolutionTestCase(
                        input: $0.input,
                        expectedOutput: $0.expectedOutput,
                        explanation: $0.explanation
                    )
                }
            )
        }

        return ProblemSolution(
            problemSlug: slug,
            summary: generated.summary,
            approaches: approaches,
            relatedProblems: generated.relatedProblems
        )
    }
}
