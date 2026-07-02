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

    func testDecodesInteractionWithSDKStyleOutputVideoURI() throws {
        let json = """
        {
          "id": "interactions/456",
          "status": "completed",
          "output_video": {
            "type": "video",
            "uri": "https://download/generated.mp4",
            "mime_type": "video/mp4"
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.gemini.decode(OmniInteractionResponse.self, from: json)

        XCTAssertEqual(response.videoURI, "https://download/generated.mp4")
    }

    func testDecodesInteractionWithRawRESTStepsURI() throws {
        let json = """
        {
          "id": "interactions/789",
          "status": "completed",
          "steps": [
            { "type": "user_input", "content": [{ "type": "text", "text": "prompt" }] },
            {
              "type": "model_output",
              "content": [
                { "type": "video", "mime_type": "video/mp4", "uri": "https://download/from-steps.mp4" }
              ]
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.gemini.decode(OmniInteractionResponse.self, from: json)

        XCTAssertEqual(response.videoURI, "https://download/from-steps.mp4")
    }

    func testDecodesInteractionWithInlineVideoData() throws {
        let json = """
        {
          "id": "interactions/inline",
          "status": "completed",
          "output_video": {
            "type": "video",
            "data": "AAAA",
            "mime_type": "video/mp4"
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.gemini.decode(OmniInteractionResponse.self, from: json)

        XCTAssertEqual(response.videoData, "AAAA")
    }

    func testDecodesGeminiErrorMessage() throws {
        let json = """
        { "error": { "code": 400, "message": "Uploaded video editing is not supported in this region.", "status": "FAILED_PRECONDITION" } }
        """.data(using: .utf8)!

        let error = try JSONDecoder.gemini.decode(GeminiErrorEnvelope.self, from: json)

        XCTAssertEqual(error.error.message, "Uploaded video editing is not supported in this region.")
        XCTAssertEqual(error.error.status, "FAILED_PRECONDITION")
    }

    func testDecodesOmniStringCodeErrorMessage() throws {
        let json = """
        { "error": { "message": "Exactly one input video is required for edit task.", "code": "invalid_request" } }
        """.data(using: .utf8)!

        let error = try JSONDecoder.gemini.decode(GeminiErrorEnvelope.self, from: json)

        XCTAssertEqual(error.error.message, "Exactly one input video is required for edit task.")
    }
}
