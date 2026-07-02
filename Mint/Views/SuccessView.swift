import SwiftUI

struct SuccessView: View {
    let onHome: () -> Void
    let onGenerateAnother: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Text("✅")
                .font(.system(size: 36))
                .frame(width: 80, height: 80)
                .background(MintColor.successBackground)
                .clipShape(Circle())
                .padding(.bottom, 20)

            Text("Saved to Photos")
                .font(.figtree(size: 24, weight: .bold))
                .foregroundStyle(MintColor.primaryText)
                .padding(.bottom, 6)

            Text("Your video is ready in your camera roll.")
                .font(.figtree(size: 15, weight: .regular))
                .foregroundStyle(MintColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Text("✓")
                    .font(.figtree(size: 14, weight: .medium))
                Text("Saved to Recents · 1080p · 0:12")
                    .font(.figtree(size: 14, weight: .medium))
            }
            .foregroundStyle(MintColor.primaryText)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(MintColor.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(MintColor.border, lineWidth: 1)
            }
            .padding(.bottom, 24)

            HStack(spacing: 10) {
                shareButton("🔗", label: "Copy link")
                shareButton("📷", label: "Instagram")
                shareButton("🎵", label: "TikTok")
                shareButton("⬇️", label: "Download")
            }
            .padding(.bottom, 24)

            MintPrimaryButton(title: "Go to home", action: onHome)
                .frame(maxWidth: 300)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .multilineTextAlignment(.center)
        .mintScreen()
    }

    private func shareButton(_ icon: String, label: String) -> some View {
        Button(action: {}) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 48, height: 48)
                .background(MintColor.surfaceHover)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(MintColor.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    SuccessView(onHome: {}, onGenerateAnother: {})
}
