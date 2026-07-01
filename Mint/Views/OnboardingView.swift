import SwiftUI

struct OnboardingView: View {
    let index: Int
    let onContinue: () -> Void
    let onSkip: () -> Void

    private let slides = [
        OnboardingSlide(
            icon: "🎬",
            title: "Two ways to\ncreate magic",
            message: "Generate from scratch or edit existing video, prompt by prompt.",
            features: [
                ("✨", "Generate, text to video in one prompt"),
                ("✂", "Edit clips statefully, step by step"),
                ("✓", "Export in high quality")
            ]
        ),
        OnboardingSlide(
            icon: "✨",
            title: "Generate",
            message: "Type what you want to see. Mint creates it from scratch.",
            features: [
                ("✓", "Cinematic, anime, cyberpunk and more"),
                ("✓", "Any scene, any style"),
                ("✓", "Export-ready results")
            ]
        ),
        OnboardingSlide(
            icon: "✂",
            title: "Stateful Edit",
            message: "Pick a video, make an edit, then refine it with follow-up prompts.",
            features: [
                ("✓", "Sequential prompts remember context"),
                ("✓", "Build on the previous result"),
                ("✓", "Keep a full edit history")
            ]
        )
    ]

    var body: some View {
        let slide = slides[index]
        VStack(spacing: 0) {
            Spacer(minLength: 60)

            VStack(spacing: MintSpacing.lg) {
                Text(slide.icon)
                    .font(.system(size: 72))
                    .frame(height: 72)

                VStack(spacing: MintSpacing.sm) {
                    Text(slide.title)
                        .font(.mintOnboardingTitle)
                        .lineSpacing(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(MintColor.primaryText)

                    Text(slide.message)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(MintColor.secondaryText)
                        .frame(maxWidth: 300)
                }

                VStack(spacing: 0) {
                    ForEach(slide.features, id: \.text) { feature in
                        HStack(spacing: MintSpacing.sm) {
                            Text(feature.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 24)
                            Text(feature.text)
                                .font(.mintBody)
                                .foregroundStyle(Color(red: 0.200, green: 0.200, blue: 0.200))
                            Spacer(minLength: 0)
                        }
                        .frame(height: 42)
                        .overlay(alignment: .bottom) {
                            if feature.text != slide.features.last?.text {
                                Rectangle()
                                    .fill(MintColor.borderLight)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .frame(maxWidth: 280)
            }
            .padding(.horizontal, MintSpacing.xl)

            Spacer(minLength: 24)

            HStack(spacing: 6) {
                ForEach(0..<slides.count, id: \.self) { dot in
                    Capsule()
                        .fill(dot == index ? MintColor.accent : Color(red: 0.867, green: 0.867, blue: 0.867))
                        .frame(width: dot == index ? 24 : 6, height: 6)
                }
            }
            .padding(.bottom, MintSpacing.md)

            VStack(spacing: MintSpacing.sm) {
                MintPrimaryButton(title: index == slides.count - 1 ? "Get started" : "Continue", action: onContinue)
                Button("Skip", action: onSkip)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MintColor.mutedText)
                    .underline()
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, MintSpacing.lg)
            .padding(.bottom, MintSpacing.xxl)
        }
        .mintScreen()
    }
}

private struct OnboardingSlide {
    let icon: String
    let title: String
    let message: String
    let features: [(icon: String, text: String)]
}

#Preview {
    OnboardingView(index: 0, onContinue: {}, onSkip: {})
}
