import XCTest
@testable import Mint

final class GeminiRequestBuilderTests: XCTestCase {
    func testFirstEditPayloadUsesUploadedDocumentAndURIOutput() throws {
        let request = OmniInteractionRequest.firstEdit(
            fileURI: "https://generativelanguage.googleapis.com/v1beta/files/abc",
            prompt: "Make the mirror ripple beautifully like liquid."
        )

        let data = try JSONEncoder.gemini.encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["model"] as? String, "gemini-omni-flash-preview")
        XCTAssertNil(object["previous_interaction_id"])
        let format = try XCTUnwrap(object["response_format"] as? [String: Any])
        XCTAssertEqual(format["type"] as? String, "video")
        XCTAssertEqual(format["delivery"] as? String, "uri")
    }

    func testFollowUpPayloadUsesPreviousInteractionID() throws {
        let request = OmniInteractionRequest.followUp(
            previousInteractionID: "interactions/first",
            prompt: "Keep everything else the same, make the arm reflective."
        )

        let data = try JSONEncoder.gemini.encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["previous_interaction_id"] as? String, "interactions/first")
        XCTAssertEqual(object["model"] as? String, "gemini-omni-flash-preview")
    }

    func testTextToVideoPayloadUsesPromptTaskAndURIOutput() throws {
        let request = OmniInteractionRequest.textToVideo(
            prompt: "A marble rolling fast on a chain reaction style track.",
            aspectRatio: "9:16"
        )

        let data = try JSONEncoder.gemini.encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["model"] as? String, "gemini-omni-flash-preview")
        XCTAssertEqual(object["input"] as? String, "A marble rolling fast on a chain reaction style track.")
        let generationConfig = try XCTUnwrap(object["generation_config"] as? [String: Any])
        let videoConfig = try XCTUnwrap(generationConfig["video_config"] as? [String: Any])
        XCTAssertEqual(videoConfig["task"] as? String, "text_to_video")
        let responseFormat = try XCTUnwrap(object["response_format"] as? [String: Any])
        XCTAssertEqual(responseFormat["type"] as? String, "video")
        XCTAssertEqual(responseFormat["delivery"] as? String, "uri")
        XCTAssertEqual(responseFormat["aspect_ratio"] as? String, "9:16")
    }
}
