import XCTest

final class EditorPreviewTests: XCTestCase {
    func testEditorPreviewDoesNotUseSystemVideoPlayerChrome() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let promptViewURL = projectDirectory.appendingPathComponent("Mint/Views/PromptView.swift")
        let source = try String(contentsOf: promptViewURL, encoding: .utf8)

        XCTAssertFalse(
            source.contains("VideoPlayer("),
            "Edit mode should use a plain preview layer so system video chrome cannot surface local filenames."
        )
        XCTAssertTrue(source.contains("EditorVideoPreview"))
    }

    func testPaywallSelectedPlanUsesHTMLBlackInsteadOfAccent() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let paywallURL = projectDirectory.appendingPathComponent("Mint/Views/PaywallInviteView.swift")
        let source = try String(contentsOf: paywallURL, encoding: .utf8)

        XCTAssertFalse(source.contains("selectedPlan == name || isPopular ? MintColor.accent"))
        XCTAssertFalse(source.contains(".background(MintColor.accent)"))
        XCTAssertFalse(source.contains("isSelected ? MintColor.accent"))
        XCTAssertFalse(source.contains(".fill(MintColor.accent)"))
        XCTAssertTrue(source.contains("htmlSelectedPlanColor"))
    }
}
