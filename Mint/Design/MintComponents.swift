import SwiftUI

struct MintPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MintSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? MintColor.accent : MintColor.mutedText)
            .clipShape(RoundedRectangle(cornerRadius: MintRadius.pill, style: .continuous))
        }
        .disabled(isEnabled == false)
        .buttonStyle(.plain)
        .scaleEffect(isEnabled ? 1 : 0.99)
    }
}

struct MintIconButton: View {
    let systemImage: String
    var size: CGFloat = 38
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(isEnabled ? MintColor.accent : MintColor.mutedText)
                .clipShape(Circle())
        }
        .disabled(isEnabled == false)
        .buttonStyle(.plain)
    }
}

struct MintChip: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(.mintSmall)
            .foregroundStyle(isSelected ? .white : MintColor.tertiaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(isSelected ? MintColor.accent : MintColor.surfaceHover)
            .clipShape(RoundedRectangle(cornerRadius: MintRadius.standard, style: .continuous))
    }
}

struct MintSectionCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(MintSpacing.md)
            .background(MintColor.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                    .stroke(MintColor.border, lineWidth: 1)
            }
    }
}

struct MintProgressRow: View {
    let title: String
    var isActive: Bool
    var isComplete: Bool

    var body: some View {
        HStack(spacing: MintSpacing.sm) {
            ZStack {
                Circle()
                    .fill(isComplete || isActive ? MintColor.accent : MintColor.surfaceHover)
                    .frame(width: 22, height: 22)
                Image(systemName: isComplete ? "checkmark" : "circle.fill")
                    .font(.system(size: isComplete ? 10 : 6, weight: .bold))
                    .foregroundStyle(isComplete || isActive ? .white : MintColor.mutedText)
            }

            Text(title)
                .font(.mintBody)
                .foregroundStyle(isActive || isComplete ? MintColor.primaryText : MintColor.tertiaryText)
            Spacer(minLength: 0)
        }
        .frame(minHeight: 34)
    }
}

struct MintTopBar<Leading: View, Trailing: View>: View {
    let title: String
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack {
            leading
                .frame(width: 48, alignment: .leading)
            Spacer(minLength: 0)
            Text(title)
                .font(.mintSection)
                .foregroundStyle(MintColor.primaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
            trailing
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: MintSpacing.topBar)
        .padding(.horizontal, MintSpacing.screen)
    }
}
