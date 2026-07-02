import Foundation

struct OmniInput: Codable, Equatable {
    let type: String
    let uri: String?
    let text: String?
    let data: String?
    let mimeType: String?

    static func document(uri: String) -> OmniInput {
        OmniInput(type: "document", uri: uri, text: nil, data: nil, mimeType: nil)
    }

    static func text(_ text: String) -> OmniInput {
        OmniInput(type: "text", uri: nil, text: text, data: nil, mimeType: nil)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case uri
        case text
        case data
        case mimeType = "mime_type"
    }
}

struct OmniVideoConfig: Codable, Equatable {
    let task: String
}

struct OmniGenerationConfig: Codable, Equatable {
    let videoConfig: OmniVideoConfig
}

struct OmniResponseFormat: Codable, Equatable {
    let type: String
    let delivery: String
    let aspectRatio: String?

    init(type: String, delivery: String, aspectRatio: String? = nil) {
        self.type = type
        self.delivery = delivery
        self.aspectRatio = aspectRatio
    }
}

enum OmniRequestInput: Codable, Equatable {
    case prompt(String)
    case parts([OmniInput])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let prompt = try? container.decode(String.self) {
            self = .prompt(prompt)
        } else {
            self = .parts(try container.decode([OmniInput].self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .prompt(let prompt):
            try container.encode(prompt)
        case .parts(let parts):
            try container.encode(parts)
        }
    }
}

struct OmniInteractionRequest: Codable, Equatable {
    let model: String
    let input: OmniRequestInput
    let generationConfig: OmniGenerationConfig?
    let responseFormat: OmniResponseFormat
    let previousInteractionID: String?
    let store: Bool

    static func firstEdit(fileURI: String, prompt: String) -> OmniInteractionRequest {
        OmniInteractionRequest(
            model: "gemini-omni-flash-preview",
            input: .parts([.document(uri: fileURI), .text(prompt)]),
            generationConfig: OmniGenerationConfig(videoConfig: OmniVideoConfig(task: "edit")),
            responseFormat: OmniResponseFormat(type: "video", delivery: "uri"),
            previousInteractionID: nil,
            store: true
        )
    }

    static func followUp(previousInteractionID: String, prompt: String) -> OmniInteractionRequest {
        OmniInteractionRequest(
            model: "gemini-omni-flash-preview",
            input: .parts([.text(prompt)]),
            generationConfig: OmniGenerationConfig(videoConfig: OmniVideoConfig(task: "edit")),
            responseFormat: OmniResponseFormat(type: "video", delivery: "uri"),
            previousInteractionID: previousInteractionID,
            store: true
        )
    }

    static func textToVideo(prompt: String, aspectRatio: String = "9:16") -> OmniInteractionRequest {
        OmniInteractionRequest(
            model: "gemini-omni-flash-preview",
            input: .prompt(prompt),
            generationConfig: OmniGenerationConfig(videoConfig: OmniVideoConfig(task: "text_to_video")),
            responseFormat: OmniResponseFormat(type: "video", delivery: "uri", aspectRatio: aspectRatio),
            previousInteractionID: nil,
            store: true
        )
    }

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case generationConfig = "generation_config"
        case responseFormat = "response_format"
        case previousInteractionID = "previous_interaction_id"
        case store
    }
}

struct OmniOutput: Decodable, Equatable {
    let type: String
    let uri: String?
    let data: String?
    let mimeType: String?
}

struct OmniStep: Decodable, Equatable {
    let type: String
    let content: [OmniOutput]?
}

struct OmniInteractionResponse: Decodable, Equatable {
    let id: String
    let status: String?
    let output: [OmniOutput]?
    let outputVideo: OmniOutput?
    let steps: [OmniStep]?

    var videoURI: String? {
        outputVideo?.uri
            ?? output?.first { $0.type == "video" }?.uri
            ?? steps?.flatMap { $0.content ?? [] }.first { $0.type == "video" }?.uri
    }

    var videoData: String? {
        outputVideo?.data
            ?? output?.first { $0.type == "video" }?.data
            ?? steps?.flatMap { $0.content ?? [] }.first { $0.type == "video" }?.data
    }
}

protocol OmniInteracting: Sendable {
    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse
    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse
    func createTextToVideo(prompt: String, aspectRatio: String) async throws -> OmniInteractionResponse
}

struct OmniInteractionService: OmniInteracting {
    let client: GeminiClient

    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse {
        try await client.request(path: "interactions", body: OmniInteractionRequest.firstEdit(fileURI: fileURI, prompt: prompt))
    }

    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse {
        try await client.request(path: "interactions", body: OmniInteractionRequest.followUp(previousInteractionID: previousInteractionID, prompt: prompt))
    }

    func createTextToVideo(prompt: String, aspectRatio: String = "9:16") async throws -> OmniInteractionResponse {
        try await client.request(path: "interactions", body: OmniInteractionRequest.textToVideo(prompt: prompt, aspectRatio: aspectRatio))
    }
}

struct GeneratedVideo: Equatable {
    let interactionID: String
    let localURL: URL
    let remoteURI: String?
}

protocol TextToVideoGenerating: Sendable {
    func generateVideo(prompt: String, aspectRatio: String) async throws -> GeneratedVideo
}

struct GeminiTextToVideoService: TextToVideoGenerating {
    let omniService: OmniInteracting
    let fileService: GeminiFileServicing

    func generateVideo(prompt: String, aspectRatio: String = "9:16") async throws -> GeneratedVideo {
        let response = try await omniService.createTextToVideo(prompt: prompt, aspectRatio: aspectRatio)
        let outputURL = Self.outputURL(for: response.id)

        if let videoData = response.videoData, let data = Data(base64Encoded: videoData) {
            try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: outputURL, options: [.atomic])
            return GeneratedVideo(interactionID: response.id, localURL: outputURL, remoteURI: nil)
        }

        guard let remoteURI = response.videoURI else {
            throw GeminiClientError.api("Gemini completed generation without a downloadable video.")
        }
        try await fileService.downloadVideo(from: remoteURI, to: outputURL)
        return GeneratedVideo(interactionID: response.id, localURL: outputURL, remoteURI: remoteURI)
    }

    private static func outputURL(for interactionID: String) -> URL {
        let fileName = interactionID
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GeneratedVideos", isDirectory: true)
            .appendingPathComponent(fileName)
            .appendingPathExtension("mp4")
    }
}
