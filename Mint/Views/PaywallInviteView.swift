import SwiftUI

struct PaywallInviteView: View {
    let onContinue: () -> Void
    @State private var selectedPlan = "Annual"
    @State private var trialEnabled = true
    private let htmlSelectedPlanColor = Color(red: 0.067, green: 0.067, blue: 0.067)

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("✨")
                    .font(.system(size: 48))
                    .padding(.bottom, 8)

                Text("Unlock Mint Pro")
                    .font(.figtree(size: 26, weight: .bold))
                    .foregroundStyle(MintColor.primaryText)
                    .padding(.bottom, 6)

                Text("Try free for 3 days. After that, 5 edits/day included with Pro — buy extra packs if you need more.")
                    .font(.figtree(size: 15, weight: .regular))
                    .lineSpacing(2)
                    .foregroundStyle(MintColor.secondaryText)
                    .multilineTextAlignment(.center)

                Text("🎁 3 days free")
                    .font(.figtree(size: 13, weight: .semibold))
                    .foregroundStyle(MintColor.success)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(MintColor.successBackground)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
            .padding(.top, 48)
            .padding(.horizontal, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    planCard(name: "Annual", detail: "$8.33 / month", price: "$99.99", suffix: "/yr", saving: "Save 44% vs monthly", isPopular: true)
                    planCard(name: "Monthly", detail: "$14.99 / month", price: "$14.99", suffix: "/mo", saving: nil, isPopular: false)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }

            Button { trialEnabled.toggle() } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Free trial")
                            .font(.figtree(size: 14, weight: .semibold))
                            .foregroundStyle(MintColor.primaryText)
                        Text("Cancel anytime before it renews")
                            .font(.figtree(size: 11, weight: .regular))
                            .foregroundStyle(MintColor.tertiaryText)
                    }
                    Spacer()
                    HTMLToggle(isOn: trialEnabled)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(MintColor.borderLight)
                    .frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 6) {
                feature("5 edits/day included")
                feature("4K export · No watermark")
                feature("All effects & style transfers")
                feature("Priority processing")
                feature("Buy token packs for extra")
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            VStack(spacing: 0) {
                MintPrimaryButton(title: "Start 3-day free trial", action: onContinue)

                Text("After trial: $14.99/month or $99.99/year. 5 edits/day included, extra token packs available. Cancel anytime.")
                    .font(.figtree(size: 11, weight: .regular))
                    .lineSpacing(2)
                    .foregroundStyle(MintColor.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                Button("Maybe later", action: onContinue)
                    .font(.figtree(size: 12, weight: .medium))
                    .foregroundStyle(MintColor.tertiaryText)
                    .underline()
                    .buttonStyle(.plain)
                    .padding(.top, 6)

                Button("Restore purchases", action: {})
                    .font(.figtree(size: 11, weight: .medium))
                    .foregroundStyle(MintColor.tertiaryText)
                    .underline()
                    .buttonStyle(.plain)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .mintScreen()
    }

    private func feature(_ text: String) -> some View {
        HStack(spacing: 8) {
            Text("✓")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MintColor.success)
            Text(text)
                .font(.figtree(size: 13, weight: .regular))
                .foregroundStyle(Color(red: 0.333, green: 0.333, blue: 0.333))
            Spacer(minLength: 0)
        }
    }

    private func planCard(name: String, detail: String, price: String, suffix: String?, saving: String?, isPopular: Bool) -> some View {
        Button { selectedPlan = name } label: {
            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.figtree(size: 16, weight: .semibold))
                        Text(detail)
                            .font(.figtree(size: 12, weight: .regular))
                            .foregroundStyle(MintColor.tertiaryText)
                            .padding(.top, 2)
                        if let saving {
                            Text(saving)
                                .font(.figtree(size: 11, weight: .semibold))
                                .foregroundStyle(MintColor.success)
                                .padding(.top, 4)
                        }
                    }

                    Spacer(minLength: 12)

                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(price)
                            .font(.figtree(size: 22, weight: .bold))
                        if let suffix {
                            Text(suffix)
                                .font(.figtree(size: 12, weight: .medium))
                                .foregroundStyle(MintColor.tertiaryText)
                        }
                    }
                }

                HStack {
                    Spacer()
                    RadioMark(isSelected: selectedPlan == name)
                }
            }
            .padding(16)
            .foregroundStyle(MintColor.primaryText)
            .background(isPopular ? Color(red: 0.980, green: 0.980, blue: 0.980) : MintColor.background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selectedPlan == name || isPopular ? htmlSelectedPlanColor : MintColor.border, lineWidth: 1.5)
            }
            .overlay(alignment: .top) {
                if isPopular {
                    Text("★ BEST VALUE")
                        .font(.figtree(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .background(htmlSelectedPlanColor)
                        .clipShape(Capsule())
                        .offset(y: -8)
                }
            }
            .padding(.top, isPopular ? 8 : 0)
        }
        .buttonStyle(.plain)
    }
}

private struct RadioMark: View {
    let isSelected: Bool
    private let htmlSelectedPlanColor = Color(red: 0.067, green: 0.067, blue: 0.067)

    var body: some View {
        Circle()
            .stroke(isSelected ? htmlSelectedPlanColor : Color(red: 0.867, green: 0.867, blue: 0.867), lineWidth: 2)
            .frame(width: 20, height: 20)
            .overlay {
                if isSelected {
                    Circle()
                        .fill(htmlSelectedPlanColor)
                        .padding(3)
                }
            }
    }
}

private struct HTMLToggle: View {
    let isOn: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(isOn ? MintColor.success : Color(red: 0.867, green: 0.867, blue: 0.867))
            .frame(width: 44, height: 26)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.white)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                    .offset(x: isOn ? 20 : 2)
            }
            .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}

#Preview {
    PaywallInviteView(onContinue: {})
}
