import XCTest
@testable import Mint

final class VideoImportServiceTests: XCTestCase {
    func testRejectsUnsupportedFiles() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let source = directory.appendingPathComponent("notes.txt")
        try Data("not video".utf8).write(to: source)

        let service = VideoImportService(documentsDirectory: directory)

        do {
            _ = try await service.importVideo(from: source)
            XCTFail("Expected unsupported file error.")
        } catch let error as VideoImportError {
            XCTAssertEqual(error, .unsupportedFile)
        }
    }

    func testCopiesVideoIntoImportedVideosDirectory() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let source = directory.appendingPathComponent("clip.mp4")
        try Data(repeating: 7, count: 128).write(to: source)

        let imported = try await VideoImportService(documentsDirectory: directory).importVideo(from: source)

        XCTAssertTrue(FileManager.default.fileExists(atPath: imported.localURL.path))
        XCTAssertTrue(imported.localURL.path.contains("ImportedVideos"))
        XCTAssertEqual(imported.byteCount, 128)
    }
}
