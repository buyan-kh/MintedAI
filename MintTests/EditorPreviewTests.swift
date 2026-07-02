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
}
