import Foundation

struct OmniInput: Codable, Equatable {
    let type: String
    let uri: String?
    let text: String?

    static func document(uri: String) -> OmniInput {
        OmniInput(type: "document", uri: uri, text: nil)
    }

    static func text(_ text: String) -> OmniInput {
        OmniInput(type: "text", uri: nil, text: text)
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
}

struct OmniInteractionRequest: Codable, Equatable {
    let model: String
    let input: [OmniInput]
    let generationConfig: OmniGenerationConfig?
    let responseFormat: OmniResponseFormat
    let previousInteractionID: String?
    let store: Bool

    static func firstEdit(fileURI: String, prompt: String) -> OmniInteractionRequest {
        OmniInteractionRequest(
            model: "gemini-omni-flash-preview",
            input: [.document(uri: fileURI), .text(prompt)],
            generationConfig: OmniGenerationConfig(videoConfig: OmniVideoConfig(task: "edit")),
            responseFormat: OmniResponseFormat(type: "video", delivery: "uri"),
            previousInteractionID: nil,
            store: true
        )
    }

    static func followUp(previousInteractionID: String, prompt: String) -> OmniInteractionRequest {
        OmniInteractionRequest(
            model: "gemini-omni-flash-preview",
            input: [.text(prompt)],
            generationConfig: OmniGenerationConfig(videoConfig: OmniVideoConfig(task: "edit")),
            responseFormat: OmniResponseFormat(type: "video", delivery: "uri"),
            previousInteractionID: previousInteractionID,
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
    let mimeType: String?
}

struct OmniInteractionResponse: Decodable, Equatable {
    let id: String
    let status: String?
    let output: [OmniOutput]?

    var videoURI: String? {
        output?.first { $0.type == "video" }?.uri
    }
}

protocol OmniInteracting {
    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse
    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse
}

struct OmniInteractionService: OmniInteracting {
    let client: GeminiClient

    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse {
        try await client.request(path: "interactions", body: OmniInteractionRequest.firstEdit(fileURI: fileURI, prompt: prompt))
    }

    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse {
        try await client.request(path: "interactions", body: OmniInteractionRequest.followUp(previousInteractionID: previousInteractionID, prompt: prompt))
    }
}
