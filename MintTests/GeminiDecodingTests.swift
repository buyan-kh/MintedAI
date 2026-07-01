import XCTest
@testable import Mint

final class GeminiDecodingTests: XCTestCase {
    func testDecodesInteractionWithURIOutput() throws {
        let json = """
        {
          "id": "interactions/123",
          "status": "completed",
          "output": [
            { "type": "video", "uri": "https://download/video.mp4", "mime_type": "video/mp4" }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.gemini.decode(OmniInteractionResponse.self, from: json)

        XCTAssertEqual(response.id, "interactions/123")
        XCTAssertEqual(response.videoURI, "https://download/video.mp4")
    }

    func testDecodesGeminiErrorMessage() throws {
        let json = """
        { "error": { "code": 400, "message": "Uploaded video editing is not supported in this region.", "status": "FAILED_PRECONDITION" } }
        """.data(using: .utf8)!

        let error = try JSONDecoder.gemini.decode(GeminiErrorEnvelope.self, from: json)

        XCTAssertEqual(error.error.message, "Uploaded video editing is not supported in this region.")
        XCTAssertEqual(error.error.status, "FAILED_PRECONDITION")
    }
}
