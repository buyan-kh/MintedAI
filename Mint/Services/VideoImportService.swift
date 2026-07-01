import AVFoundation
import Foundation
import UniformTypeIdentifiers

enum VideoImportError: LocalizedError, Equatable {
    case unsupportedFile
    case copyFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedFile:
            "Choose a video file to edit."
        case .copyFailed:
            "Mint could not copy this video into the project."
        }
    }
}

struct ImportedVideo: Equatable {
    let localURL: URL
    let duration: TimeInterval
    let byteCount: Int64
}

struct VideoImportService {
    let documentsDirectory: URL

    init(documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.documentsDirectory = documentsDirectory
    }

    func importVideo(from sourceURL: URL) async throws -> ImportedVideo {
        guard Self.isSupportedVideo(sourceURL) else {
            throw VideoImportError.unsupportedFile
        }

        let destinationDirectory = documentsDirectory.appendingPathComponent("ImportedVideos", isDirectory: true)
        try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)

        let destination = destinationDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(sourceURL.pathExtension.lowercased())
        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destination)
        } catch {
            throw VideoImportError.copyFailed
        }

        let attributes = try FileManager.default.attributesOfItem(atPath: destination.path)
        let duration = await Self.duration(for: destination)
        return ImportedVideo(
            localURL: destination,
            duration: duration,
            byteCount: attributes[.size] as? Int64 ?? 0
        )
    }

    static func isSupportedVideo(_ url: URL) -> Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
        return type.conforms(to: .movie) || type.conforms(to: .video)
    }

    private static func duration(for url: URL) async -> TimeInterval {
        let asset = AVURLAsset(url: url)
        guard let seconds = try? await asset.load(.duration).seconds, seconds.isFinite else {
            return 0
        }
        return seconds
    }
}
