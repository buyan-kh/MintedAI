import SwiftUI

struct SettingsView: View {
    var tokenLedger: TokenLedger
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MintTopBar(title: "Settings") {
                Button("← Back", action: onBack)
                    .font(.figtree(size: 16, weight: .medium))
                    .foregroundStyle(MintColor.primaryText)
                    .buttonStyle(.plain)
            } trailing: {
                Color.clear
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    settingsSection(title: "Subscription") {
                        planCard
                    }

                    settingsSection(title: "Account") {
                        SettingsRow(icon: "👤", title: "Apple ID", subtitle: "buyan@icloud.com", value: "• • •")
                        SettingsRow(icon: "🚪", title: "Sign out", titleColor: Color(red: 1.000, green: 0.278, blue: 0.341))
                    }

                    settingsSection(title: "Support") {
                        SettingsRow(icon: "❓", title: "FAQ")
                        SettingsRow(icon: "💬", title: "Contact us")
                        SettingsRow(icon: "⭐", title: "Rate the app")
                    }

                    Text("Mint v1.0.2 · Build 42")
                        .font(.figtree(size: 11, weight: .regular))
                        .foregroundStyle(Color(red: 0.733, green: 0.733, blue: 0.733))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .mintScreen()
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mint Pro Annual")
                        .font(.figtree(size: 16, weight: .semibold))
                        .foregroundStyle(MintColor.primaryText)
                    Text("Renews April 15, 2027 · $99.99/yr")
                        .font(.figtree(size: 13, weight: .regular))
                        .foregroundStyle(MintColor.tertiaryText)
                }

                Spacer(minLength: 12)

                Text("Active")
                    .font(.figtree(size: 10, weight: .bold))
                    .tracking(0.3)
                    .textCase(.uppercase)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(MintColor.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Edits used today")
                    Spacer()
                    Text("\(displayedEditsUsedToday) / \(tokenLedger.dailyLimit)")
                        .fontWeight(.semibold)
                        .foregroundStyle(MintColor.primaryText)
                }
                .font(.figtree(size: 13, weight: .regular))
                .foregroundStyle(MintColor.secondaryText)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.933, green: 0.933, blue: 0.933))
                        Capsule()
                            .fill(MintColor.primaryText)
                            .frame(width: proxy.size.width * usageProgress)
                    }
                }
                .frame(height: 4)
            }

            HStack {
                Text("Token balance")
                Spacer()
                Text("\(tokenLedger.bankedTokens)")
                    .fontWeight(.semibold)
                    .foregroundStyle(MintColor.primaryText)
            }
            .font(.figtree(size: 13, weight: .regular))
            .foregroundStyle(MintColor.secondaryText)
            .padding(.top, -6)

            Button("Manage subscription →") {}
                .font(.figtree(size: 14, weight: .semibold))
                .foregroundStyle(MintColor.primaryText)
                .buttonStyle(.plain)
                .underline()
        }
        .padding(16)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
        .padding(.bottom, 12)
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.figtree(size: 11, weight: .semibold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(MintColor.tertiaryText)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            content()
        }
        .padding(.bottom, 24)
    }

    private var displayedEditsUsedToday: Int {
        max(tokenLedger.usedToday, 3)
    }

    private var usageProgress: CGFloat {
        guard tokenLedger.dailyLimit > 0 else { return 0 }
        return CGFloat(displayedEditsUsedToday) / CGFloat(tokenLedger.dailyLimit)
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    var titleColor = MintColor.primaryText
    var subtitle: String?
    var value: String?

    var body: some View {
        Button {} label: {
            HStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 18))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.figtree(size: 15, weight: .medium))
                        .foregroundStyle(titleColor)
                    if let subtitle {
                        Text(subtitle)
                            .font(.figtree(size: 11, weight: .regular))
                            .foregroundStyle(MintColor.tertiaryText)
                    }
                }

                Spacer(minLength: 10)

                HStack(spacing: 4) {
                    if let value {
                        Text(value)
                            .font(.figtree(size: 13, weight: .regular))
                            .foregroundStyle(value == "Follow system" ? Color(red: 0.800, green: 0.800, blue: 0.800) : MintColor.tertiaryText)
                    }
                    Text("›")
                        .font(.figtree(size: 14, weight: .regular))
                        .foregroundStyle(Color(red: 0.800, green: 0.800, blue: 0.800))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MintColor.borderLight)
                .frame(height: 1)
                .padding(.leading, 12)
        }
    }
}

#Preview {
    SettingsView(tokenLedger: TokenLedger(), onBack: {})
}
