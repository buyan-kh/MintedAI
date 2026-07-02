import AVKit
import SwiftUI

struct PromptView: View {
    @Bindable var viewModel: EditSessionViewModel
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    @State private var prompt = ""

    private let hints = ["🎬 Cinematic", "🪞 Mirror ripple", "✨ Reflective arm", "⏱️ Slow motion"]

    var body: some View {
        VStack(spacing: 0) {
            MintTopBar(title: "Edit") {
                Button("← Back", action: onBack)
                    .font(.figtree(size: 16, weight: .medium))
                    .foregroundStyle(MintColor.primaryText)
                    .buttonStyle(.plain)
            } trailing: {
                EmptyView()
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(MintColor.borderLight)
                    .frame(height: 1)
            }

            editorPreview

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    versionStrip

                    promptBox

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: 6)], alignment: .leading, spacing: 6) {
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
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }

            bottomActions
        }
        .mintScreen()
    }

    private var editCount: Int {
        viewModel.session?.turns.count ?? 0
    }

    private var canSend: Bool {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var editorPreview: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                MintColor.surfaceAlt

                if let url = viewModel.session?.sourceVideoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .frame(height: 200)
            .clipped()

            HStack {
                statusTag
                Spacer()
                if editCount > 0 {
                    Text("v\(editCount)")
                        .font(.figtree(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.424, green: 0.361, blue: 0.906).opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MintColor.borderLight)
                .frame(height: 1)
        }
    }

    private var statusTag: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(MintColor.success)
                .frame(width: 5, height: 5)
            Text("Ready")
            Text("·")
                .foregroundStyle(MintColor.border)
                .padding(.horizontal, 4)
            Text("\(editCount) edits")
            Text("·")
                .foregroundStyle(MintColor.border)
                .padding(.horizontal, 4)
            Text("10")
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
            Text("/ 10")
        }
        .font(.figtree(size: 10, weight: .semibold))
        .foregroundStyle(MintColor.tertiaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    @ViewBuilder
    private var versionStrip: some View {
        if editCount > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(1...editCount, id: \.self) { version in
                        Text("v\(version)")
                            .font(.figtree(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 28)
                            .background(MintColor.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
            }
        }
    }

    private var promptBox: some View {
        VStack(alignment: .leading, spacing: MintSpacing.xs) {
            TextEditor(text: $prompt)
                .font(.mintBody)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .overlay(alignment: .topLeading) {
                    if prompt.isEmpty {
                        Text("Describe your edit — e.g. \"When I touch the mirror, make it ripple like liquid\"")
                            .font(.mintBody)
                            .foregroundStyle(MintColor.placeholderText)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .onChange(of: prompt) { _, newValue in
                    if newValue.count > 500 {
                        prompt = String(newValue.prefix(500))
                    }
                }

            HStack {
                Spacer()
                Text("\(prompt.count) / 500")
                    .font(.mintTiny)
                    .foregroundStyle(Color(red: 0.733, green: 0.733, blue: 0.733))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }

    private var bottomActions: some View {
        VStack(spacing: 6) {
            Button {
                onSubmit(prompt)
            } label: {
                Text("✂️ Edit video")
                    .font(.figtree(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canSend ? MintColor.accent : MintColor.mutedText)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(canSend == false)
            .buttonStyle(.plain)
            .accessibilityLabel("Edit video")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(MintColor.borderLight)
                .frame(height: 1)
        }
    }

    private func applyHint(_ hint: String) {
        let phrase: String
        switch hint {
        case "🎬 Cinematic":
            phrase = "Make this cinematic with warm highlights and smooth camera motion"
        case "🪞 Mirror ripple":
            phrase = "When the person touches the mirror, make it ripple beautifully like liquid"
        case "✨ Reflective arm":
            phrase = "Turn the person's arm into reflective mirror material while keeping the face natural"
        default:
            phrase = "Slow the motion down and make the moment feel dramatic and polished"
        }
        prompt = phrase
    }
}
