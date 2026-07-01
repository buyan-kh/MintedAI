import XCTest
@testable import Mint

final class APIKeyProviderTests: XCTestCase {
    func testReadsAPIKeyFromInfoDictionary() {
        let provider = APIKeyProvider(infoDictionary: ["GEMINI_API_KEY": " test-key "])

        XCTAssertEqual(provider.geminiAPIKey(), "test-key")
    }

    func testTreatsBuildSettingPlaceholderAsMissing() {
        let provider = APIKeyProvider(infoDictionary: ["GEMINI_API_KEY": "$(GEMINI_API_KEY)"])

        XCTAssertEqual(provider.geminiAPIKey(), "")
    }
}
