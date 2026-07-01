import XCTest
@testable import Mint

final class VideoEditSessionStoreTests: XCTestCase {
    func testRoundTripsSessionWithMultipleTurns() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = VideoEditSessionStore(directory: directory)
        let session = VideoEditSession(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            sourceVideoURL: URL(fileURLWithPath: "/tmp/source.mov"),
            sourceFileName: "files/source",
            sourceFileURI: "https://generativelanguage.googleapis.com/v1beta/files/source",
            turns: [
                VideoEditTurn(
                    id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                    prompt: "Make the mirror ripple like liquid.",
                    interactionID: "interactions/first",
                    previousInteractionID: nil,
                    outputVideoURL: URL(fileURLWithPath: "/tmp/output-1.mp4"),
                    remoteOutputURI: "https://download/1",
                    status: .completed,
                    errorMessage: nil,
                    createdAt: Date(timeIntervalSince1970: 1)
                ),
                VideoEditTurn(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                    prompt: "Make the arm reflective too.",
                    interactionID: "interactions/second",
                    previousInteractionID: "interactions/first",
                    outputVideoURL: URL(fileURLWithPath: "/tmp/output-2.mp4"),
                    remoteOutputURI: "https://download/2",
                    status: .completed,
                    errorMessage: nil,
                    createdAt: Date(timeIntervalSince1970: 2)
                )
            ],
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 3)
        )

        try await store.save([session])
        let loaded = try await store.load()

        XCTAssertEqual(loaded, [session])
        XCTAssertEqual(loaded[0].turns[1].previousInteractionID, "interactions/first")
    }
}
