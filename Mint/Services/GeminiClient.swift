import Foundation

struct GeminiErrorEnvelope: Decodable, Equatable {
    struct GeminiError: Decodable, Equatable {
        let code: String?
        let message: String
        let status: String?

        enum CodingKeys: String, CodingKey {
            case code
            case message
            case status
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let stringCode = try? container.decode(String.self, forKey: .code) {
                code = stringCode
            } else if let intCode = try? container.decode(Int.self, forKey: .code) {
                code = String(intCode)
            } else {
                code = nil
            }
            message = try container.decode(String.self, forKey: .message)
            status = try container.decodeIfPresent(String.self, forKey: .status)
        }
    }

    let error: GeminiError
}

enum GeminiClientError: LocalizedError, Equatable {
    case missingAPIKey
    case api(String)
    case invalidResponse
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Add a Gemini API key in Secrets.xcconfig before generating."
        case .api(let message):
            message
        case .invalidResponse:
            "Gemini returned an invalid response."
        case .decoding(let message):
            "Gemini response could not be read: \(message)"
        }
    }
}

extension JSONEncoder {
    static var gemini: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

extension JSONDecoder {
    static var gemini: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

struct GeminiClient: Sendable {
    let apiKey: String
    var session: URLSession = .shared
    var baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta")!

    func request<T: Decodable, Body: Encodable>(
        path: String,
        method: String = "POST",
        body: Body
    ) async throws -> T {
        guard apiKey.isEmpty == false else { throw GeminiClientError.missingAPIKey }
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.gemini.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GeminiClientError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            if let envelope = try? JSONDecoder.gemini.decode(GeminiErrorEnvelope.self, from: data) {
                throw GeminiClientError.api(envelope.error.message)
            }
            throw GeminiClientError.invalidResponse
        }
        do {
            return try JSONDecoder.gemini.decode(T.self, from: data)
        } catch {
            throw GeminiClientError.decoding(error.localizedDescription)
        }
    }
}
