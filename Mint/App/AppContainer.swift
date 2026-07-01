import Foundation

@MainActor
struct AppContainer {
    let editSessionViewModel: EditSessionViewModel

    static func live() -> AppContainer {
        if ProcessInfo.processInfo.arguments.contains("UITEST_MOCK_GEMINI") {
            return AppContainer(
                editSessionViewModel: EditSessionViewModel(
                    fileService: MockGeminiFileService(),
                    omniService: MockOmniInteractionService(),
                    store: VideoEditSessionStore(directory: FileManager.default.temporaryDirectory)
                )
            )
        }

        let apiKey = APIKeyProvider().geminiAPIKey()
        let client = GeminiClient(apiKey: apiKey)
        return AppContainer(
            editSessionViewModel: EditSessionViewModel(
                fileService: GeminiFileService(client: client),
                omniService: OmniInteractionService(client: client),
                store: VideoEditSessionStore()
            )
        )
    }
}

private actor MockGeminiFileService: GeminiFileServicing {
    func uploadVideo(fileURL: URL) async throws -> GeminiUploadedFile {
        GeminiUploadedFile(name: "files/mock-source", uri: "mock://source-video", state: "PROCESSING")
    }

    func waitUntilActive(fileName: String) async throws -> GeminiUploadedFile {
        GeminiUploadedFile(name: fileName, uri: "mock://source-video", state: "ACTIVE")
    }

    func downloadVideo(from remoteURI: String, to localURL: URL) async throws {
        let directory = localURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.removeItem(at: localURL)
        }
        try Data("mock video result".utf8).write(to: localURL, options: [.atomic])
    }
}

private actor MockOmniInteractionService: OmniInteracting {
    private var turnCount = 0

    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse {
        turnCount += 1
        return response(id: "mock-interaction-\(turnCount)")
    }

    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse {
        turnCount += 1
        return response(id: "mock-interaction-\(turnCount)")
    }

    private func response(id: String) -> OmniInteractionResponse {
        OmniInteractionResponse(
            id: id,
            status: "SUCCEEDED",
            output: [OmniOutput(type: "video", uri: "mock://generated-\(id).mp4", mimeType: "video/mp4")]
        )
    }
}
