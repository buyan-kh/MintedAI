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
}
