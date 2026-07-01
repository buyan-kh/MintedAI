import XCTest
@testable import Mint

final class GeminiFileServiceTests: XCTestCase {
    func testStartUploadRequestUsesGeminiUploadEndpointAndResumableHeaders() throws {
        let fileURL = URL(fileURLWithPath: "/tmp/Mirror Edit.mov")
        let request = try GeminiUploadStartRequest(
            apiKey: "test-key",
            fileURL: fileURL,
            byteCount: 42,
            mimeType: "video/quicktime",
            uploadBaseURL: URL(string: "https://generativelanguage.googleapis.com/upload/v1beta/files")!
        ).urlRequest()

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Goog-Upload-Protocol"), "resumable")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Goog-Upload-Command"), "start")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length"), "42")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type"), "video/quicktime")
        XCTAssertEqual(request.url?.query, "key=test-key")

        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(request.httpBody)) as? [String: Any])
        let file = try XCTUnwrap(object["file"] as? [String: Any])
        XCTAssertEqual(file["display_name"] as? String, "Mirror Edit.mov")
    }

    func testMapsCommonVideoMimeTypes() {
        XCTAssertEqual(GeminiFileService.mimeType(for: URL(fileURLWithPath: "/tmp/source.mov")), "video/quicktime")
        XCTAssertEqual(GeminiFileService.mimeType(for: URL(fileURLWithPath: "/tmp/source.m4v")), "video/x-m4v")
        XCTAssertEqual(GeminiFileService.mimeType(for: URL(fileURLWithPath: "/tmp/source.mp4")), "video/mp4")
    }
}
