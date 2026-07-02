import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct VideoPickerView: View {
    let onBack: () -> Void
    let onVideoImported: (URL) -> Void

    @State private var isPhotosPickerPresented = false
    @State private var didStartPickerFlow = false
    @State private var isImporting = false
    @State private var errorMessage: String?

    private let importService = VideoImportService()

    var body: some View {
        VStack(spacing: 0) {
            MintTopBar(title: "Photos") {
                Button("Back", action: onBack)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(MintColor.primaryText)
                    .buttonStyle(.plain)
            } trailing: {
                EmptyView()
            }

            Spacer(minLength: 0)

            VStack(spacing: MintSpacing.md) {
                if isImporting {
                    ProgressView("Importing video...")
                        .font(.mintBody)
                        .tint(MintColor.accent)
                } else {
                    Text("Opening Photos...")
                        .font(.mintCardTitle)
                        .foregroundStyle(MintColor.primaryText)
                    Text("Select a video from your camera roll to start editing.")
                        .font(.mintSmall)
                        .foregroundStyle(MintColor.tertiaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)

                    Button { isPhotosPickerPresented = true } label: {
                        Text("Open Photos")
                            .font(.figtree(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(MintColor.accent)
                            .clipShape(RoundedRectangle(cornerRadius: MintRadius.pill, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.mintSmall)
                        .foregroundStyle(MintColor.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(MintSpacing.screen)

            Spacer(minLength: 0)
        }
        .mintScreen()
        .task {
            await startPickerFlowIfNeeded()
        }
        .sheet(isPresented: $isPhotosPickerPresented) {
            SystemVideoPicker { result in
                isPhotosPickerPresented = false
                guard let result else { return }
                Task { await importPickedVideo(result) }
            }
        }
    }

    private func startPickerFlowIfNeeded() async {
        guard didStartPickerFlow == false else { return }
        didStartPickerFlow = true

        if ProcessInfo.processInfo.arguments.contains("UITEST_MOCK_GEMINI") {
            await useSampleVideo()
        } else {
            isPhotosPickerPresented = true
        }
    }

    private func importPickedVideo(_ result: Result<URL, Error>) async {
        isImporting = true
        errorMessage = nil
        do {
            let url = try result.get()
            let imported = try await importService.importVideo(from: url)
            onVideoImported(imported.localURL)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isImporting = false
    }

    private func useSampleVideo() async {
        isImporting = true
        errorMessage = nil
        do {
            let source = FileManager.default.temporaryDirectory
                .appendingPathComponent("mint-sample")
                .appendingPathExtension("mp4")
            try Data(repeating: 1, count: 1024).write(to: source, options: [.atomic])
            let imported = try await importService.importVideo(from: source)
            onVideoImported(imported.localURL)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isImporting = false
    }
}

private struct SystemVideoPicker: UIViewControllerRepresentable {
    let onComplete: (Result<URL, Error>?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .videos
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: (Result<URL, Error>?) -> Void

        init(onComplete: @escaping (Result<URL, Error>?) -> Void) {
            self.onComplete = onComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                onComplete(nil)
                return
            }

            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                if let error {
                    Task { @MainActor in self.onComplete(.failure(error)) }
                    return
                }
                guard let url else {
                    Task { @MainActor in self.onComplete(.failure(VideoImportError.unsupportedFile)) }
                    return
                }

                let destination = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension.isEmpty ? "mov" : url.pathExtension)

                do {
                    try FileManager.default.copyItem(at: url, to: destination)
                    Task { @MainActor in self.onComplete(.success(destination)) }
                } catch {
                    Task { @MainActor in self.onComplete(.failure(error)) }
                }
            }
        }
    }
}
