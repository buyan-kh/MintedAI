import SwiftUI

struct PromptView: View {
    @Bindable var viewModel: EditSessionViewModel
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    @State private var prompt = ""
    private let hints = [
        "Cinematic",
        "Mirror ripple",
        "Reflective arm",
        "Slow motion"
    ]

    var body: some View {
        VStack(spacing: 0) {
            MintTopBar(title: "Edit") {
                Button("Back", action: onBack)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(MintColor.primaryText)
                    .buttonStyle(.plain)
            } trailing: {
                EmptyView()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: MintSpacing.sm) {
                    VideoPlayerView(url: viewModel.session?.sourceVideoURL, height: 200)

                    HStack {
                        Text("Selected video")
                            .font(.mintSmall)
                            .foregroundStyle(MintColor.primaryText)
                            .lineLimit(1)
                        Text("\(viewModel.session?.turns.count ?? 0) edits")
                            .font(.mintTiny)
                            .foregroundStyle(MintColor.tertiaryText)
                        Spacer()
                        Button("Change", action: onBack)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(MintColor.primaryText)
                            .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: MintSpacing.xs) {
                        TextEditor(text: $prompt)
                            .font(.mintBody)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 150)
                            .overlay(alignment: .topLeading) {
                                if prompt.isEmpty {
                                    Text("Describe your edit. For example: When the person touches the mirror, make it ripple like liquid.")
                                        .font(.mintBody)
                                        .foregroundStyle(MintColor.placeholderText)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }

                        HStack {
                            Spacer()
                            Text("\(prompt.count) / 500")
                                .font(.mintTiny)
                                .foregroundStyle(MintColor.mutedText)
                        }
                    }
                    .padding(MintSpacing.md)
                    .background(MintColor.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous))

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 6)], alignment: .leading, spacing: 6) {
                        ForEach(hints, id: \.self) { hint in
                            Button { applyHint(hint) } label: {
                                MintChip(title: hint)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.mintSmall)
                            .foregroundStyle(MintColor.secondaryText)
                            .padding(MintSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(MintColor.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: MintRadius.standard, style: .continuous))
                    }
                }
                .padding(.horizontal, MintSpacing.screen)
                .padding(.bottom, 100)
            }

            HStack(spacing: 10) {
                TextField("Describe your edit...", text: $prompt)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(MintColor.surfaceHover)
                    .clipShape(RoundedRectangle(cornerRadius: MintRadius.extra, style: .continuous))
                    .onChange(of: prompt) { _, newValue in
                        if newValue.count > 500 {
                            prompt = String(newValue.prefix(500))
                        }
                    }

                MintIconButton(systemImage: "paperplane.fill", isEnabled: canSend) {
                    onSubmit(prompt)
                }
                .accessibilityLabel("Send")
            }
            .padding(.horizontal, MintSpacing.screen)
            .padding(.top, MintSpacing.xs)
            .padding(.bottom, MintSpacing.lg)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(MintColor.borderLight)
                    .frame(height: 1)
            }
        }
        .mintScreen()
    }

    private var canSend: Bool {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func applyHint(_ hint: String) {
        let phrase: String
        switch hint {
        case "Cinematic":
            phrase = "Make this cinematic with soft contrast, warm highlights, and smooth camera motion."
        case "Mirror ripple":
            phrase = "When the person touches the mirror, make the mirror ripple beautifully like liquid."
        case "Reflective arm":
            phrase = "Turn the person's arm into reflective mirror material while keeping the face natural."
        default:
            phrase = "Slow the motion down and make the moment feel dramatic and polished."
        }
        prompt = phrase
    }
}
