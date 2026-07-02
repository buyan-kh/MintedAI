import SwiftUI

struct ProcessingView: View {
    let title: String
    let message: String
    let stage: String

    @State private var rotation = 0.0
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.933, green: 0.933, blue: 0.933), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: 0.24)
                    .stroke(MintColor.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(rotation))
            }
            .frame(width: 64, height: 64)
            .padding(.bottom, 24)

            Text(title)
                .font(.figtree(size: 22, weight: .bold))
                .foregroundStyle(MintColor.primaryText)
                .padding(.bottom, 8)

            Text(message)
                .font(.figtree(size: 15, weight: .regular))
                .lineSpacing(3)
                .foregroundStyle(MintColor.secondaryText)
                .multilineTextAlignment(.center)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color(red: 0.933, green: 0.933, blue: 0.933))
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(MintColor.accent)
                    .frame(width: 200 * progress)
            }
            .frame(width: 200, height: 4)
            .padding(.top, 24)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("Processing progress track")
            .accessibilityLabel("Processing progress")

            Text(stage)
                .font(.figtree(size: 12, weight: .regular))
                .foregroundStyle(MintColor.tertiaryText)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .mintScreen()
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
                progress = 1
            }
        }
    }
}

#Preview {
    ProcessingView(title: "Creating your video", message: "AI is working on it...", stage: "Starting...")
}
