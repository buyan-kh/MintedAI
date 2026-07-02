import Foundation

struct GeminiUploadedFile: Codable, Equatable {
    let name: String
    let uri: String
    let state: String?
}

struct GeminiFileUploadResponse: Codable, Equatable {
    let file: GeminiUploadedFile
}

protocol GeminiFileServicing: Sendable {
    func uploadVideo(fileURL: URL) async throws -> GeminiUploadedFile
    func waitUntilActive(fileName: String) async throws -> GeminiUploadedFile
    func downloadVideo(from remoteURI: String, to localURL: URL) async throws
}

struct GeminiUploadStartRequest: Sendable {
    let apiKey: String
    let fileURL: URL
    let byteCount: Int
    let mimeType: String
    let uploadBaseURL: URL

    func urlRequest() throws -> URLRequest {
        guard apiKey.isEmpty == false else { throw GeminiClientError.missingAPIKey }
        var components = URLComponents(url: uploadBaseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("resumable", forHTTPHeaderField: "X-Goog-Upload-Protocol")
        request.setValue("start", forHTTPHeaderField: "X-Goog-Upload-Command")
        request.setValue("\(byteCount)", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length")
        request.setValue(mimeType, forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "file": ["display_name": fileURL.lastPathComponent]
        ])
        return request
    }
}

struct GeminiFileService: GeminiFileServicing {
    let client: GeminiClient
    var session: URLSession
    var uploadBaseURL = URL(string: "https://generativelanguage.googleapis.com/upload/v1beta/files")!
    var pollDelayNanoseconds: UInt64 = 5_000_000_000
    var maxPollAttempts = 60

    init(
        client: GeminiClient,
        session: URLSession? = nil,
        uploadBaseURL: URL = URL(string: "https://generativelanguage.googleapis.com/upload/v1beta/files")!,
        pollDelayNanoseconds: UInt64 = 5_000_000_000,
        maxPollAttempts: Int = 60
    ) {
        self.client = client
        self.session = session ?? client.session
        self.uploadBaseURL = uploadBaseURL
        self.pollDelayNanoseconds = pollDelayNanoseconds
        self.maxPollAttempts = maxPollAttempts
    }

    func uploadVideo(fileURL: URL) async throws -> GeminiUploadedFile {
        guard client.apiKey.isEmpty == false else { throw GeminiClientError.missingAPIKey }
        let data = try Data(contentsOf: fileURL)
        let uploadURL = try await startUpload(
            fileURL: fileURL,
            byteCount: data.count,
            mimeType: Self.mimeType(for: fileURL)
        )

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("0", forHTTPHeaderField: "X-Goog-Upload-Offset")
        request.setValue("upload, finalize", forHTTPHeaderField: "X-Goog-Upload-Command")

        let (responseData, response) = try await session.upload(for: request, from: data)
        try validate(response: response, data: responseData, fallbackMessage: "Gemini could not upload this video.")
        return try JSONDecoder.gemini.decode(GeminiFileUploadResponse.self, from: responseData).file
    }

    func waitUntilActive(fileName: String) async throws -> GeminiUploadedFile {
        guard client.apiKey.isEmpty == false else { throw GeminiClientError.missingAPIKey }
        for _ in 0..<maxPollAttempts {
            let file = try await fetchFile(fileName: fileName)
            if file.state == "ACTIVE" {
                return file
            }
            if file.state == "FAILED" {
                throw GeminiClientError.api("Gemini could not process the source video.")
            }
            try await Task.sleep(nanoseconds: pollDelayNanoseconds)
        }
        throw GeminiClientError.api("Gemini is still processing the source video.")
    }

    func downloadVideo(from remoteURI: String, to localURL: URL) async throws {
        let url = try downloadURL(for: remoteURI)
        let (temporaryURL, response) = try await session.download(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw GeminiClientError.api("The generated video could not be downloaded.")
        }

        let directory = localURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.removeItem(at: localURL)
        }
        try FileManager.default.moveItem(at: temporaryURL, to: localURL)
    }

    private func downloadURL(for remoteURI: String) throws -> URL {
        if remoteURI.hasPrefix("files/") {
            let fileID = remoteURI.dropFirst("files/".count)
            var components = URLComponents(url: client.baseURL.appendingPathComponent("files/\(fileID):download"), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "alt", value: "media"),
                URLQueryItem(name: "key", value: client.apiKey)
            ]
            return components.url!
        }

        guard var components = URLComponents(string: remoteURI) else { throw GeminiClientError.invalidResponse }
        var queryItems = components.queryItems ?? []
        if components.host?.contains("generativelanguage.googleapis.com") == true,
           queryItems.contains(where: { $0.name == "key" }) == false {
            queryItems.append(URLQueryItem(name: "key", value: client.apiKey))
            components.queryItems = queryItems
        }
        guard let url = components.url else { throw GeminiClientError.invalidResponse }
        return url
    }

    static func mimeType(for fileURL: URL) -> String {
        switch fileURL.pathExtension.lowercased() {
        case "mov":
            "video/quicktime"
        case "m4v":
            "video/x-m4v"
        default:
            "video/mp4"
        }
    }

    private func startUpload(fileURL: URL, byteCount: Int, mimeType: String) async throws -> URL {
        let request = try GeminiUploadStartRequest(
            apiKey: client.apiKey,
            fileURL: fileURL,
            byteCount: byteCount,
            mimeType: mimeType,
            uploadBaseURL: uploadBaseURL
        ).urlRequest()

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data, fallbackMessage: "Gemini could not start the upload.")
        guard let http = response as? HTTPURLResponse,
              let uploadURLString = http.value(forHTTPHeaderField: "X-Goog-Upload-URL"),
              let uploadURL = URL(string: uploadURLString) else {
            throw GeminiClientError.invalidResponse
        }
        return uploadURL
    }

    private func fetchFile(fileName: String) async throws -> GeminiUploadedFile {
        var components = URLComponents(
            url: client.baseURL.appendingPathComponent(fileName),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "key", value: client.apiKey)]
        let (data, response) = try await session.data(from: components.url!)
        try validate(response: response, data: data, fallbackMessage: "Gemini could not read the uploaded file.")
        return try JSONDecoder.gemini.decode(GeminiUploadedFile.self, from: data)
    }

    private func validate(response: URLResponse, data: Data, fallbackMessage: String) throws {
        guard let http = response as? HTTPURLResponse else { throw GeminiClientError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            if let envelope = try? JSONDecoder.gemini.decode(GeminiErrorEnvelope.self, from: data) {
                throw GeminiClientError.api(envelope.error.message)
            }
            throw GeminiClientError.api(fallbackMessage)
        }
    }
}
