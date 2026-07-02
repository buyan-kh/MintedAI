import Foundation

@MainActor
struct AppContainer {
    let editSessionViewModel: EditSessionViewModel
    let textToVideoService: TextToVideoGenerating

    static func live() -> AppContainer {
        if ProcessInfo.processInfo.arguments.contains("UITEST_MOCK_GEMINI") {
            let fileService = MockGeminiFileService()
            let omniService = MockOmniInteractionService()
            return AppContainer(
                editSessionViewModel: EditSessionViewModel(
                    fileService: fileService,
                    omniService: omniService,
                    store: VideoEditSessionStore(directory: FileManager.default.temporaryDirectory)
                ),
                textToVideoService: MockTextToVideoService()
            )
        }

        let apiKey = APIKeyProvider().geminiAPIKey()
        let client = GeminiClient(apiKey: apiKey)
        let fileService = GeminiFileService(client: client)
        let omniService = OmniInteractionService(client: client)
        return AppContainer(
            editSessionViewModel: EditSessionViewModel(
                fileService: fileService,
                omniService: omniService,
                store: VideoEditSessionStore()
            ),
            textToVideoService: GeminiTextToVideoService(omniService: omniService, fileService: fileService)
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
        try await Task.sleep(nanoseconds: 2_500_000_000)
        turnCount += 1
        return response(id: "mock-interaction-\(turnCount)")
    }

    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse {
        try await Task.sleep(nanoseconds: 2_500_000_000)
        turnCount += 1
        return response(id: "mock-interaction-\(turnCount)")
    }

    func createTextToVideo(prompt: String, aspectRatio: String) async throws -> OmniInteractionResponse {
        turnCount += 1
        return response(id: "mock-generation-\(turnCount)")
    }

    private func response(id: String) -> OmniInteractionResponse {
        OmniInteractionResponse(
            id: id,
            status: "SUCCEEDED",
            output: [OmniOutput(type: "video", uri: "mock://generated-\(id).mp4", data: nil, mimeType: "video/mp4")],
            outputVideo: nil,
            steps: nil
        )
    }
}

private struct MockTextToVideoService: TextToVideoGenerating {
    func generateVideo(prompt: String, aspectRatio: String) async throws -> GeneratedVideo {
        try await Task.sleep(nanoseconds: 2_200_000_000)
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mock-text-to-video")
            .appendingPathExtension("mp4")
        try Data("mock generated video".utf8).write(to: outputURL, options: [.atomic])
        return GeneratedVideo(interactionID: "mock-generation", localURL: outputURL, remoteURI: "mock://generated.mp4")
    }
}
