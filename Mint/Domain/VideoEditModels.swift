import Foundation

enum VideoEditTurnStatus: String, Codable, Equatable, CaseIterable {
    case queued
    case uploading
    case processingInput
    case generating
    case downloading
    case completed
    case failed
}

struct VideoEditTurn: Identifiable, Codable, Equatable {
    var id: UUID
    var prompt: String
    var interactionID: String?
    var previousInteractionID: String?
    var outputVideoURL: URL?
    var remoteOutputURI: String?
    var status: VideoEditTurnStatus
    var errorMessage: String?
    var createdAt: Date
}

struct VideoEditSession: Identifiable, Codable, Equatable {
    var id: UUID
    var sourceVideoURL: URL
    var sourceFileName: String?
    var sourceFileURI: String?
    var turns: [VideoEditTurn]
    var createdAt: Date
    var updatedAt: Date
}
