import SwiftUI

struct OnboardingView: View {
    let index: Int
    let onContinue: () -> Void
    let onSkip: () -> Void

    private let slides = [
        OnboardingSlide(
            icon: "✂️",
            title: "Edit your videos\nwith AI. Naturally.",
            message: "Not another generator. Take any clip and transform it — prompt by prompt, like talking to your video.",
            badge: "✦ The AI editor, not generator"
        ),
        OnboardingSlide(
            icon: "🎬",
            title: "Real example",
            message: "Start with a selfie. Prompt: \"When I touch the mirror, make it ripple.\" Done. Then prompt again. It builds.",
            badge: "✦ Iterative. Not one-shot."
        ),
        OnboardingSlide(
            icon: "✨",
            title: "Also: Generate",
            message: "Sometimes you want something from nothing. Type a scene — AI generates it. But editing is the main act.",
            badge: "✦ Editing is the hero feature"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(slides.indices, id: \.self) { slideIndex in
                    OnboardingSlideView(slide: slides[slideIndex])
                        .opacity(slideIndex == index ? 1 : 0)
                        .offset(x: slideIndex == index ? 0 : (slideIndex < index ? -40 : 40))
                        .allowsHitTesting(slideIndex == index)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
            .padding(.top, 60)
            .clipped()
            .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.5), value: index)

            HStack(spacing: 6) {
                ForEach(slides.indices, id: \.self) { dot in
                    Capsule()
                        .fill(dot == index ? MintColor.accent : Color(red: 0.867, green: 0.867, blue: 0.867))
                        .frame(width: dot == index ? 24 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: index)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            VStack(spacing: 0) {
                MintPrimaryButton(title: index == slides.count - 1 ? "Get started" : "Continue", action: onContinue)
                Button("Skip", action: onSkip)
                    .font(.figtree(size: 14, weight: .medium))
                    .foregroundStyle(MintColor.mutedText)
                    .underline()
                    .buttonStyle(.plain)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .mintScreen()
    }
}

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Text(slide.icon)
                .font(.system(size: 72))
                .padding(.bottom, 24)

            Text(slide.title)
                .font(.figtree(size: 28, weight: .bold))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(MintColor.primaryText)
                .padding(.bottom, 10)

            Text(slide.message)
                .font(.figtree(size: 16, weight: .regular))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(MintColor.secondaryText)
                .frame(maxWidth: 300)

            Text(slide.badge)
                .font(.figtree(size: 11, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.941, green: 0.929, blue: 1.000))
                .clipShape(Capsule())
                .padding(.top, 14)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingSlide {
    let icon: String
    let title: String
    let message: String
    let badge: String
}

#Preview {
    OnboardingView(index: 0, onContinue: {}, onSkip: {})
}
