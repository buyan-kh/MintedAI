import SwiftUI

struct GenerateView: View {
    var errorMessage: String?
    let onBack: () -> Void
    let onGenerate: (String) -> Void

    @State private var prompt = ""
    @FocusState private var isPromptFocused: Bool

    private let remainingEdits = 5
    private let dailyEditLimit = 5
    private let placeholder = "e.g. \"Cinematic slow-motion of a neon-lit cyberpunk city at night\""
    private var tokenText: String { "\(remainingEdits)/\(dailyEditLimit)" }
    private let suggestions = [
        ("🌆 Cityscape", "Cinematic sunset over a futuristic city skyline, drone shot"),
        ("🌸 Anime", "Anime-style girl walking through a cherry blossom forest, golden hour"),
        ("💻 Cyberpunk", "Cyberpunk hacker in a neon-lit room, typing on holographic keyboards")
    ]

    var body: some View {
        VStack(spacing: 0) {
            topBar

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Text("✨")
                    .font(.system(size: 56))
                    .padding(.bottom, 16)

                Text("What do you want to see?")
                    .font(.figtree(size: 24, weight: .bold))
                    .foregroundStyle(MintColor.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)

                generateSubtitle

                promptBox
                suggestionRow

                if let errorMessage {
                    Text(errorMessage)
                        .font(.figtree(size: 13, weight: .medium))
                        .foregroundStyle(MintColor.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(MintColor.surfaceAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(MintColor.border, lineWidth: 1)
                        }
                        .padding(.top, 12)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            bottomBar
        }
        .mintScreen()
    }

    private var topBar: some View {
        HStack {
            Button("← Back", action: onBack)
                .font(.figtree(size: 16, weight: .medium))
                .foregroundStyle(MintColor.primaryText)
                .lineLimit(1)
                .buttonStyle(.plain)
                .frame(width: 88, alignment: .leading)
            Spacer(minLength: 0)
            Text("Generate")
                .font(.mintSection)
                .foregroundStyle(MintColor.primaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
            Color.clear
                .frame(width: 88, height: 40)
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }

    private var generateSubtitle: some View {
        HStack(spacing: 0) {
            Text("Describe any scene. AI generates it from scratch. ")
                .foregroundStyle(MintColor.tertiaryText)
            Text(tokenText)
                .font(.figtree(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
                .accessibilityIdentifier("Generate hero token count")
            Text(" edits remaining today.")
                .foregroundStyle(MintColor.tertiaryText)
        }
        .font(.figtree(size: 14, weight: .regular))
        .lineLimit(2)
        .minimumScaleFactor(0.9)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }

    private var promptBox: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $prompt)
                    .font(.figtree(size: 15, weight: .medium))
                    .lineSpacing(6)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isPromptFocused)
                    .frame(minHeight: 118)
                    .onChange(of: prompt) { _, newValue in
                        if newValue.count > 500 {
                            prompt = String(newValue.prefix(500))
                        }
                    }

                if prompt.isEmpty {
                    Text(placeholder)
                        .font(.figtree(size: 15, weight: .medium))
                        .lineSpacing(6)
                        .foregroundStyle(MintColor.placeholderText)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 118)

            HStack(spacing: 0) {
                Spacer()
                Text("\(prompt.count) ")
                    .font(.figtree(size: 10, weight: .regular))
                    .foregroundStyle(Color(red: 0.733, green: 0.733, blue: 0.733))
                Text("/ 500")
                    .font(.figtree(size: 10, weight: .regular))
                    .foregroundStyle(Color(red: 0.733, green: 0.733, blue: 0.733))
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(MintColor.border)
                    .frame(height: 1)
            }
        }
        .padding(16)
        .frame(height: 160)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }

    private var suggestionRow: some View {
        FlowLayout(spacing: 6, rowSpacing: 6) {
            ForEach(suggestions, id: \.0) { suggestion in
                Button {
                    prompt = suggestion.1
                    isPromptFocused = false
                } label: {
                    Text(suggestion.0)
                        .font(.figtree(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.333, green: 0.333, blue: 0.333))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(MintColor.surfaceHover)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(MintColor.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            TextField("Describe your video...", text: $prompt)
                .font(.figtree(size: 14, weight: .medium))
                .foregroundStyle(MintColor.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MintColor.surfaceHover)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(MintColor.border, lineWidth: 1)
                }
                .onChange(of: prompt) { _, newValue in
                    if newValue.count > 500 {
                        prompt = String(newValue.prefix(500))
                    }
                }

            Text(tokenText)
                .font(.figtree(size: 10, weight: .bold))
                .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
                .lineLimit(1)
                .fixedSize()
                .accessibilityIdentifier("Generate bottom token count")

            Button { onGenerate(prompt) } label: {
                Text("✨ Generate")
                    .font(.figtree(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(MintColor.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Generate")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(MintColor.borderLight)
                .frame(height: 1)
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + rowSpacing
                widestRow = max(widestRow, rowWidth)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += rowWidth == 0 ? size.width : spacing + size.width
            rowHeight = max(rowHeight, size.height)
        }

        totalHeight += rowHeight
        widestRow = max(widestRow, rowWidth)
        return CGSize(width: maxWidth == 0 ? widestRow : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var row: [(LayoutSubviews.Element, CGSize)] = []
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var y = bounds.minY

        func flushRow() {
            let startX = bounds.midX - rowWidth / 2
            var x = startX
            for (subview, size) in row {
                subview.place(at: CGPoint(x: x, y: y + (rowHeight - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + rowSpacing
            row.removeAll()
            rowWidth = 0
            rowHeight = 0
        }

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > bounds.width {
                flushRow()
            }
            row.append((subview, size))
            rowWidth += rowWidth == 0 ? size.width : spacing + size.width
            rowHeight = max(rowHeight, size.height)
        }
        if row.isEmpty == false {
            flushRow()
        }
    }
}

#Preview {
    GenerateView(errorMessage: nil, onBack: {}, onGenerate: { _ in })
}
