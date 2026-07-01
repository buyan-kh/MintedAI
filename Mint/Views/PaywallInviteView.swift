import SwiftUI

struct PaywallInviteView: View {
    let onContinue: () -> Void
    @State private var selectedPlan = "Annual"
    @State private var trialEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: MintSpacing.xs) {
                Text("✨")
                    .font(.system(size: 48))
                    .frame(height: 48)

                Text("Unlock Mint Pro")
                    .font(.mintTitle)
                    .foregroundStyle(MintColor.primaryText)

                Text("Try free for 7 days, then from just $4.99/mo. Cancel anytime.")
                    .font(.mintBodyRegular)
                    .lineSpacing(2)
                    .foregroundStyle(MintColor.secondaryText)
                    .multilineTextAlignment(.center)

                Text("7 days free")
                    .font(.mintSmall)
                    .foregroundStyle(MintColor.success)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(MintColor.successBackground)
                    .clipShape(Capsule())
                    .padding(.top, MintSpacing.xxs)
            }
            .padding(.top, 48)
            .padding(.horizontal, MintSpacing.lg)

            VStack(spacing: 10) {
                planCard(name: "Annual", detail: "$4.99 / month", price: "$59.99/yr", saving: "Save 50% vs monthly", isPopular: true)
                planCard(name: "Monthly", detail: "$9.99 / month", price: "$9.99/mo", saving: nil, isPopular: false)
                planCard(name: "Lifetime", detail: "One-time payment", price: "$99.99", saving: "Never pay again", isPopular: false)
            }
            .padding(.top, MintSpacing.screen)
            .padding(.horizontal, MintSpacing.lg)

            Spacer(minLength: MintSpacing.md)

            Toggle(isOn: $trialEnabled) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Free trial")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Cancel anytime before it renews")
                        .font(.mintTiny)
                        .foregroundStyle(MintColor.tertiaryText)
                }
            }
            .tint(MintColor.success)
            .padding(.horizontal, MintSpacing.lg)
            .padding(.vertical, MintSpacing.sm)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(MintColor.borderLight)
                    .frame(height: 1)
            }

            VStack(spacing: 10) {
                MintPrimaryButton(title: "Start 7-day free trial", action: onContinue)

                Text("Renews at $59.99/year. Cancel anytime in settings.")
                    .font(.mintTiny)
                    .foregroundStyle(MintColor.mutedText)
                    .multilineTextAlignment(.center)

                Button("Maybe later", action: onContinue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(MintColor.tertiaryText)
                    .underline()
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, MintSpacing.lg)
            .padding(.bottom, 36)
        }
        .mintScreen()
    }

    private func planCard(name: String, detail: String, price: String, saving: String?, isPopular: Bool) -> some View {
        Button { selectedPlan = name } label: {
            HStack(alignment: .center, spacing: MintSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                    Text(detail)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(MintColor.tertiaryText)
                    if let saving {
                        Text(saving)
                            .font(.mintTiny)
                            .foregroundStyle(MintColor.success)
                            .padding(.top, 2)
                    }
                }

                Spacer(minLength: MintSpacing.sm)

                Text(price)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Circle()
                    .stroke(selectedPlan == name ? MintColor.accent : Color(red: 0.867, green: 0.867, blue: 0.867), lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if selectedPlan == name {
                            Circle()
                                .fill(MintColor.accent)
                                .padding(3)
                        }
                    }
            }
            .padding(MintSpacing.md)
            .padding(.top, isPopular ? MintSpacing.xs : 0)
            .foregroundStyle(MintColor.primaryText)
            .background(isPopular ? Color(red: 0.980, green: 0.980, blue: 0.980) : MintColor.background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selectedPlan == name || isPopular ? MintColor.accent : MintColor.border, lineWidth: 1.5)
            }
            .overlay(alignment: .top) {
                if isPopular {
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .background(MintColor.accent)
                        .clipShape(Capsule())
                        .offset(y: -8)
                }
            }
            .padding(.top, isPopular ? MintSpacing.xs : 0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallInviteView(onContinue: {})
}
