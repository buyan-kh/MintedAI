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

    func testPhotosPickerBackButtonMatchesHTMLTopBar() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let pickerURL = projectDirectory.appendingPathComponent("Mint/Views/VideoPickerView.swift")
        let source = try String(contentsOf: pickerURL, encoding: .utf8)

        XCTAssertTrue(source.contains("Button(\"← Back\""))
        XCTAssertTrue(source.contains(".font(.figtree(size: 16, weight: .medium))"))
        XCTAssertFalse(source.contains("Button(\"Back\""))
        XCTAssertFalse(source.contains(".font(.system(size: 16, weight: .medium))"))
    }

    func testGenerateBottomTokenCounterMatchesHTMLSplitStyling() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let generateURL = projectDirectory.appendingPathComponent("Mint/Views/GenerateView.swift")
        let source = try String(contentsOf: generateURL, encoding: .utf8)

        XCTAssertTrue(source.contains("Text(\"\\(remainingEdits)\""))
        XCTAssertTrue(source.contains("Text(\"/\\(dailyEditLimit)\""))
        XCTAssertTrue(source.contains(".foregroundColor(MintColor.tertiaryText)"))
        XCTAssertFalse(source.contains("Text(tokenText)\n                .font(.figtree(size: 10, weight: .bold))"))
    }
}
