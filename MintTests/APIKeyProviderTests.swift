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

    func testAppInfoPlistIncludesGeminiAPIKeyBuildSetting() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let plistURL = projectDirectory.appendingPathComponent("Mint/Supporting/Info.plist")
        let data = try Data(contentsOf: plistURL)
        let plist = try XCTUnwrap(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])

        XCTAssertEqual(plist["GEMINI_API_KEY"] as? String, "$(GEMINI_API_KEY)")
    }
}
