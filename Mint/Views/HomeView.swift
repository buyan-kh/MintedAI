import SwiftUI

struct HomeView: View {
    let onCreate: () -> Void
    @State private var selectedMode = "Edit"
    @State private var selectedFilter = "All"

    private let filters = ["All", "Generated", "Edited", "Favorites"]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack {
                    Text("Mint")
                        .font(.mintSection)
                        .foregroundStyle(MintColor.primaryText)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(MintColor.tertiaryText)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Settings")
                }
                .frame(height: MintSpacing.topBar)
                .padding(.horizontal, MintSpacing.screen)

                modeSwitch
                    .padding(.horizontal, MintSpacing.screen)
                    .padding(.bottom, 14)

                VStack(alignment: .leading, spacing: MintSpacing.sm) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your videos")
                            .font(.system(size: 22, weight: .bold))
                        Text("Stateful edits and generations live here.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(MintColor.tertiaryText)
                    }

                    HStack(spacing: MintSpacing.md) {
                        statCard(value: "0", label: "Videos")
                        statCard(value: "0", label: "This month")
                        statCard(value: "4K", label: "Quality")
                    }
                }
                .padding(.horizontal, MintSpacing.screen)
                .padding(.bottom, MintSpacing.sm)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MintSpacing.xs) {
                        ForEach(filters, id: \.self) { filter in
                            Button { selectedFilter = filter } label: {
                                MintChip(title: filter, isSelected: selectedFilter == filter)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, MintSpacing.screen)
                    .padding(.vertical, MintSpacing.xs)
                }

                Spacer(minLength: 0)

                VStack(spacing: MintSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                            .fill(MintColor.surfaceAlt)
                            .frame(width: 108, height: 150)
                            .overlay {
                                RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                                    .stroke(MintColor.border, lineWidth: 1)
                            }
                        Image(systemName: selectedMode == "Edit" ? "movieclapper" : "sparkles")
                            .font(.system(size: 34, weight: .regular))
                            .foregroundStyle(MintColor.accent)
                    }

                    VStack(spacing: 6) {
                        Text(selectedMode == "Edit" ? "Create your first stateful edit" : "Generate your first video")
                            .font(.mintCardTitle)
                            .multilineTextAlignment(.center)
                        Text(selectedMode == "Edit" ? "Pick a clip, describe the change, then keep refining from the last result." : "Describe the scene you want and Mint will create it from scratch.")
                            .font(.mintBodyRegular)
                            .lineSpacing(3)
                            .foregroundStyle(MintColor.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 280)
                    }

                    MintPrimaryButton(title: "Create", systemImage: "plus", action: onCreate)
                        .frame(maxWidth: 220)
                        .accessibilityIdentifier("Primary create")
                }
                .padding(.horizontal, MintSpacing.screen)
                .padding(.bottom, 118)

                Spacer(minLength: 0)
            }
            .mintScreen()

            VStack(alignment: .trailing, spacing: MintSpacing.xs) {
                Text("Create")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(MintColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: MintRadius.medium, style: .continuous))

                Button(action: onCreate) {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(MintColor.accent)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create")
            }
            .padding(.trailing, MintSpacing.screen)
            .padding(.bottom, MintSpacing.lg)
        }
    }

    private var modeSwitch: some View {
        HStack(spacing: 0) {
            ForEach(["Generate", "Edit"], id: \.self) { mode in
                Button { selectedMode = mode } label: {
                    VStack(spacing: 1) {
                        Text(mode == "Generate" ? "✨ Generate" : "✂ Edit")
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                        Text(mode == "Generate" ? "Text to video" : "Iterative clip editing")
                            .font(.system(size: 9, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selectedMode == mode ? MintColor.primaryText : MintColor.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MintSpacing.xs)
                    .background(selectedMode == mode ? MintColor.background : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: MintRadius.standard, style: .continuous))
                    .shadow(color: selectedMode == mode ? .black.opacity(0.06) : .clear, radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(MintColor.surfaceHover)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(MintColor.primaryText)
                .lineLimit(1)
            Text(label)
                .font(.mintTiny)
                .foregroundStyle(MintColor.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, MintSpacing.xs)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }
}

#Preview {
    HomeView(onCreate: {})
}
