import Foundation
import Observation

@MainActor
@Observable
final class EditSessionViewModel {
    private let fileService: GeminiFileServicing
    private let omniService: OmniInteracting
    private let store: VideoEditSessionStore

    private(set) var session: VideoEditSession?
    private(set) var isProcessing = false
    private(set) var stage = "Ready"
    var errorMessage: String?

    init(fileService: GeminiFileServicing, omniService: OmniInteracting, store: VideoEditSessionStore) {
        self.fileService = fileService
        self.omniService = omniService
        self.store = store
    }

    func startSession(sourceVideoURL: URL) {
        let now = Date()
        session = VideoEditSession(
            id: UUID(),
            sourceVideoURL: sourceVideoURL,
            sourceFileName: nil,
            sourceFileURI: nil,
            turns: [],
            createdAt: now,
            updatedAt: now
        )
        stage = "Ready"
        errorMessage = nil
    }

    func submitPrompt(_ prompt: String) async {
        guard var currentSession = session else { return }
        let cleanPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanPrompt.isEmpty == false else { return }

        isProcessing = true
        errorMessage = nil

        var turn = VideoEditTurn(
            id: UUID(),
            prompt: cleanPrompt,
            interactionID: nil,
            previousInteractionID: currentSession.turns.last?.interactionID,
            outputVideoURL: nil,
            remoteOutputURI: nil,
            status: .queued,
            errorMessage: nil,
            createdAt: Date()
        )
        currentSession.turns.append(turn)
        currentSession.updatedAt = Date()
        session = currentSession

        do {
            let response: OmniInteractionResponse
            if let previousID = turn.previousInteractionID {
                stage = "Generating follow-up edit"
                turn.status = .generating
                updateLastTurn(turn, in: &currentSession)
                response = try await omniService.createFollowUp(previousInteractionID: previousID, prompt: cleanPrompt)
            } else {
                stage = "Uploading video"
                turn.status = .uploading
                updateLastTurn(turn, in: &currentSession)
                let uploaded = try await fileService.uploadVideo(fileURL: currentSession.sourceVideoURL)

                stage = "Processing video"
                turn.status = .processingInput
                updateLastTurn(turn, in: &currentSession)
                let activeFile = try await fileService.waitUntilActive(fileName: uploaded.name)
                currentSession.sourceFileName = activeFile.name
                currentSession.sourceFileURI = activeFile.uri

                stage = "Generating edit"
                turn.status = .generating
                updateLastTurn(turn, in: &currentSession)
                response = try await omniService.createFirstEdit(fileURI: activeFile.uri, prompt: cleanPrompt)
            }

            guard let remoteURI = response.videoURI else {
                throw GeminiClientError.api("Gemini completed the edit without a downloadable video.")
            }

            stage = "Downloading result"
            turn.status = .downloading
            updateLastTurn(turn, in: &currentSession)
            let outputURL = outputURL(for: turn.id)
            try await fileService.downloadVideo(from: remoteURI, to: outputURL)

            turn.status = .completed
            turn.interactionID = response.id
            turn.remoteOutputURI = remoteURI
            turn.outputVideoURL = outputURL
            updateLastTurn(turn, in: &currentSession)
            try await store.save([currentSession])
            stage = "Done"
        } catch {
            turn.status = .failed
            turn.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            updateLastTurn(turn, in: &currentSession)
            errorMessage = turn.errorMessage
            stage = "Failed"
        }

        isProcessing = false
    }

    private func updateLastTurn(_ turn: VideoEditTurn, in currentSession: inout VideoEditSession) {
        guard currentSession.turns.isEmpty == false else { return }
        currentSession.turns[currentSession.turns.count - 1] = turn
        currentSession.updatedAt = Date()
        session = currentSession
    }

    private func outputURL(for turnID: UUID) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GeneratedVideos", isDirectory: true)
            .appendingPathComponent(turnID.uuidString)
            .appendingPathExtension("mp4")
    }
}
