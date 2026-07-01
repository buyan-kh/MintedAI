import Photos
import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: EditSessionViewModel
    let onHome: () -> Void
    let onRefine: (String) -> Void

    @State private var followUpPrompt = ""
    @State private var saveMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            MintTopBar(title: "Result") {
                Button("Home", action: onHome)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(MintColor.primaryText)
                    .buttonStyle(.plain)
            } trailing: {
                if let url = latestTurn?.outputVideoURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(MintColor.primaryText)
                    }
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: MintSpacing.md) {
                    VideoPlayerView(url: latestTurn?.outputVideoURL, height: 260)

                    if let saveMessage {
                        Text(saveMessage)
                            .font(.mintSmall)
                            .foregroundStyle(MintColor.success)
                            .padding(.horizontal, MintSpacing.sm)
                            .padding(.vertical, MintSpacing.xs)
                            .background(MintColor.successBackground)
                            .clipShape(RoundedRectangle(cornerRadius: MintRadius.standard, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: MintSpacing.xs) {
                        Text("Prompt history")
                            .font(.mintCardTitle)
                        ForEach(Array((viewModel.session?.turns ?? []).enumerated()), id: \.element.id) { index, turn in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(MintColor.accent)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(turn.prompt)
                                        .font(.system(size: 12, weight: .regular))
                                        .lineSpacing(3)
                                        .foregroundStyle(Color(red: 0.200, green: 0.200, blue: 0.200))
                                    Text(turn.status == .completed ? "Applied" : turn.status.rawValue)
                                        .font(.mintTiny)
                                        .foregroundStyle(turn.status == .completed ? MintColor.success : MintColor.tertiaryText)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(MintSpacing.sm)
                            .background(MintColor.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }

                    VStack(alignment: .leading, spacing: MintSpacing.xs) {
                        Text("Follow-up prompt")
                            .font(.mintCardTitle)
                        TextField("Describe the next refinement...", text: $followUpPrompt, axis: .vertical)
                            .font(.mintBody)
                            .lineLimit(2...4)
                            .padding(14)
                            .background(MintColor.surfaceHover)
                            .clipShape(RoundedRectangle(cornerRadius: MintRadius.extra, style: .continuous))
                    }

                    HStack(spacing: MintSpacing.xs) {
                        Button { saveToPhotos() } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay {
                                    RoundedRectangle(cornerRadius: MintRadius.pill, style: .continuous)
                                        .stroke(MintColor.border, lineWidth: 1.5)
                                }
                        }
                        .buttonStyle(.plain)

                        MintPrimaryButton(title: "Refine", systemImage: "wand.and.stars", isEnabled: canRefine) {
                            let prompt = followUpPrompt
                            followUpPrompt = ""
                            onRefine(prompt)
                        }
                    }

                    MintPrimaryButton(title: "Go to home", systemImage: "house.fill", action: onHome)
                }
                .padding(.horizontal, MintSpacing.screen)
                .padding(.bottom, MintSpacing.lg)
            }
        }
        .mintScreen()
    }

    private var latestTurn: VideoEditTurn? {
        viewModel.session?.turns.last
    }

    private var canRefine: Bool {
        followUpPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func saveToPhotos() {
        guard let url = latestTurn?.outputVideoURL else { return }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in saveMessage = "Photos access is needed to save." }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                Task { @MainActor in
                    saveMessage = success ? "Saved to Photos" : (error?.localizedDescription ?? "Could not save video.")
                }
            }
        }
    }
}
