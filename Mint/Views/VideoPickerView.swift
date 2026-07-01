import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct VideoPickerView: View {
    let onBack: () -> Void
    let onVideoImported: (URL) -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var isFileImporterPresented = false
    @State private var isImporting = false
    @State private var errorMessage: String?

    private let importService = VideoImportService()
    private let albums = ["Recents", "Videos", "Favorites", "Selfies"]

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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MintSpacing.xs) {
                    ForEach(albums, id: \.self) { album in
                        MintChip(title: album, isSelected: album == "Videos")
                    }
                }
                .padding(.horizontal, MintSpacing.screen)
                .padding(.vertical, MintSpacing.xs)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(MintColor.borderLight)
                    .frame(height: 1)
            }

            VStack(spacing: MintSpacing.lg) {
                PhotosPicker(selection: $selectedItem, matching: .videos) {
                    VideoPickerCard(
                        icon: "photo.on.rectangle.angled",
                        title: "Choose from Photos",
                        subtitle: "Select a video from your camera roll"
                    )
                }
                .buttonStyle(.plain)

                Button { isFileImporterPresented = true } label: {
                    VideoPickerCard(
                        icon: "folder",
                        title: "Browse files",
                        subtitle: "Import a .mov, .mp4, or .m4v video"
                    )
                }
                .buttonStyle(.plain)

                Button { Task { await useSampleVideo() } } label: {
                    VideoPickerCard(
                        icon: "testtube.2",
                        title: "Use sample video",
                        subtitle: "Fast path for previews and UI tests"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Use sample video")

                if isImporting {
                    ProgressView("Importing video...")
                        .font(.mintBody)
                        .tint(MintColor.accent)
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
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { await importPhotosItem(item) }
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.movie, .video]) { result in
            Task { await handleFileImporter(result) }
        }
    }

    private func importPhotosItem(_ item: PhotosPickerItem) async {
        isImporting = true
        errorMessage = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw VideoImportError.unsupportedFile
            }
            let source = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            try data.write(to: source, options: [.atomic])
            let imported = try await importService.importVideo(from: source)
            onVideoImported(imported.localURL)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isImporting = false
    }

    private func handleFileImporter(_ result: Result<URL, Error>) async {
        isImporting = true
        errorMessage = nil
        do {
            let url = try result.get()
            let isSecurityScoped = url.startAccessingSecurityScopedResource()
            defer {
                if isSecurityScoped {
                    url.stopAccessingSecurityScopedResource()
                }
            }
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

private struct VideoPickerCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: MintSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(MintColor.accent)
                .frame(width: 48, height: 48)
                .background(MintColor.surfaceHover)
                .clipShape(RoundedRectangle(cornerRadius: MintRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.mintCardTitle)
                    .foregroundStyle(MintColor.primaryText)
                Text(subtitle)
                    .font(.mintSmall)
                    .foregroundStyle(MintColor.tertiaryText)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(MintColor.tertiaryText)
        }
        .padding(MintSpacing.md)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }
}
