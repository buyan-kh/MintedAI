import XCTest
@testable import Mint

final class EditSessionViewModelTests: XCTestCase {
    func testFirstPromptUploadsCreatesInteractionDownloadsAndStoresTurn() async throws {
        let fileService = MockGeminiFileService()
        let omni = MockOmniInteractionService()
        let store = VideoEditSessionStore(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let viewModel = await EditSessionViewModel(fileService: fileService, omniService: omni, store: store)
        let sourceURL = URL(fileURLWithPath: "/tmp/source.mov")

        await viewModel.startSession(sourceVideoURL: sourceURL)
        await viewModel.submitPrompt("Make the mirror ripple beautifully like liquid.")

        let session = await viewModel.session
        XCTAssertEqual(session?.turns.count, 1)
        XCTAssertEqual(session?.turns[0].interactionID, "interactions/first")
        XCTAssertEqual(session?.turns[0].remoteOutputURI, "https://download/output.mp4")
        XCTAssertEqual(session?.turns[0].status, .completed)
        let firstEditFileURI = await omni.firstEditFileURI
        let downloadedRemoteURI = await fileService.downloadedRemoteURI
        XCTAssertEqual(firstEditFileURI, "files/source-uri")
        XCTAssertEqual(downloadedRemoteURI, "https://download/output.mp4")
    }

    func testFollowUpUsesPreviousInteractionID() async throws {
        let fileService = MockGeminiFileService()
        let omni = MockOmniInteractionService()
        let store = VideoEditSessionStore(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let viewModel = await EditSessionViewModel(fileService: fileService, omniService: omni, store: store)

        await viewModel.startSession(sourceVideoURL: URL(fileURLWithPath: "/tmp/source.mov"))
        await viewModel.submitPrompt("First prompt")
        await viewModel.submitPrompt("Make the arm reflective too.")

        let followUpPreviousID = await omni.followUpPreviousID
        XCTAssertEqual(followUpPreviousID, "interactions/first")
        let session = await viewModel.session
        XCTAssertEqual(session?.turns.count, 2)
        XCTAssertEqual(session?.turns[1].previousInteractionID, "interactions/first")
        XCTAssertEqual(session?.turns[1].interactionID, "interactions/second")
    }
}

private actor MockGeminiFileService: GeminiFileServicing {
    var downloadedRemoteURI: String?

    func uploadVideo(fileURL: URL) async throws -> GeminiUploadedFile {
        GeminiUploadedFile(name: "files/source", uri: "files/source-uri", state: "PROCESSING")
    }

    func waitUntilActive(fileName: String) async throws -> GeminiUploadedFile {
        GeminiUploadedFile(name: fileName, uri: "files/source-uri", state: "ACTIVE")
    }

    func downloadVideo(from remoteURI: String, to localURL: URL) async throws {
        downloadedRemoteURI = remoteURI
        try FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("video".utf8).write(to: localURL)
    }
}

private actor MockOmniInteractionService: OmniInteracting {
    var firstEditFileURI: String?
    var followUpPreviousID: String?

    func createFirstEdit(fileURI: String, prompt: String) async throws -> OmniInteractionResponse {
        firstEditFileURI = fileURI
        return OmniInteractionResponse(
            id: "interactions/first",
            status: "completed",
            output: [OmniOutput(type: "video", uri: "https://download/output.mp4", data: nil, mimeType: "video/mp4")],
            outputVideo: nil,
            steps: nil
        )
    }

    func createFollowUp(previousInteractionID: String, prompt: String) async throws -> OmniInteractionResponse {
        followUpPreviousID = previousInteractionID
        return OmniInteractionResponse(
            id: "interactions/second",
            status: "completed",
            output: [OmniOutput(type: "video", uri: "https://download/output-2.mp4", data: nil, mimeType: "video/mp4")],
            outputVideo: nil,
            steps: nil
        )
    }

    func createTextToVideo(prompt: String, aspectRatio: String) async throws -> OmniInteractionResponse {
        OmniInteractionResponse(
            id: "interactions/generated",
            status: "completed",
            output: [OmniOutput(type: "video", uri: "https://download/generated.mp4", data: nil, mimeType: "video/mp4")],
            outputVideo: nil,
            steps: nil
        )
    }
}
