import SwiftUI

struct HomeView: View {
    let onCreateGenerate: () -> Void
    let onCreateEdit: () -> Void

    @State private var selectedMode = GalleryMode.edit
    @State private var selectedFilter = GalleryFilter.all

    private let items: [GalleryItem] = [
        .init(emoji: "🎬", title: "Mirror Ripple Edit", date: "Today", duration: "0:08", mode: .edit, edits: 4, views: 234, hue: 212),
        .init(emoji: "🌆", title: "Neon Tokyo Cityscape", date: "Today", duration: "0:12", mode: .generate, edits: nil, views: 89, hue: 42),
        .init(emoji: "🏖️", title: "Beach Memories", date: "Yesterday", duration: "0:15", mode: .edit, edits: 2, views: 156, hue: 176),
        .init(emoji: "🌟", title: "Stargazing Reframe", date: "2 days ago", duration: "0:18", mode: .edit, edits: 6, views: 412, hue: 284),
        .init(emoji: "🌸", title: "Cherry Blossom Anime", date: "3 days ago", duration: "0:10", mode: .generate, edits: nil, views: 67, hue: 338),
        .init(emoji: "🌃", title: "City Lights Grade", date: "4 days ago", duration: "0:14", mode: .edit, edits: 3, views: 198, hue: 246)
    ]

    private var visibleItems: [GalleryItem] {
        items.filter { item in
            switch selectedFilter {
            case .all:
                return true
            case .edited:
                return item.mode == .edit
            case .generated:
                return item.mode == .generate
            case .favorites:
                return item.views > 150
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                heroBar
                modeSwitch
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                hero
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                albumFilters

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(visibleItems) { item in
                            GalleryCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 88)
                }
            }
            .mintScreen()

            VStack(alignment: .trailing, spacing: 8) {
                Text(selectedMode == .edit ? "New edit" : "Generate")
                    .font(.figtree(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(MintColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button(action: startNew) {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(MintColor.accent)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("Primary create")
                .accessibilityLabel(selectedMode == .edit ? "New edit" : "Generate")
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
    }

    private var heroBar: some View {
        HStack {
            Text("Mint")
                .font(.figtree(size: 22, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(MintColor.primaryText)
            Text(".")
                .font(.figtree(size: 22, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
                .offset(x: -4)
            Spacer()
            Button(action: {}) {
                Text("⚙︎")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(MintColor.primaryText.opacity(0.4))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }

    private var modeSwitch: some View {
        HStack(spacing: 0) {
            modeButton(.edit)
            modeButton(.generate)
        }
        .padding(3)
        .background(MintColor.surfaceHover)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func modeButton(_ mode: GalleryMode) -> some View {
        Button { selectedMode = mode } label: {
            VStack(spacing: 2) {
                Text(mode == .edit ? "✂️ Edit" : "✨ Generate")
                    .font(.figtree(size: 13, weight: .semibold))
                Text(mode == .edit ? "Transform your clips" : "Text to video")
                    .font(.figtree(size: 9, weight: .regular))
                    .lineLimit(1)
            }
            .foregroundStyle(selectedMode == mode ? MintColor.primaryText : MintColor.tertiaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(selectedMode == mode ? MintColor.background : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: selectedMode == mode ? .black.opacity(0.06) : .clear, radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(mode == .edit ? "Edit mode" : "Generate mode")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedMode == .edit ? "Your edits" : "Generated")
                    .font(.figtree(size: 22, weight: .bold))
                    .foregroundStyle(MintColor.primaryText)
                Text(selectedMode == .edit ? "Stateful AI edits live here. Start with a clip, then refine." : "Text-to-video. Describe a scene, AI creates it.")
                    .font(.figtree(size: 14, weight: .regular))
                    .lineSpacing(2)
                    .foregroundStyle(MintColor.tertiaryText)
            }

            HStack(spacing: 12) {
                stat(value: "23", label: "Videos")
                stat(value: "12", label: "This month")
                stat(value: "4.8K", label: "Total views")
            }
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.figtree(size: 20, weight: .bold))
            Text(label)
                .font(.figtree(size: 10, weight: .regular))
                .foregroundStyle(MintColor.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }

    private var albumFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GalleryFilter.allCases) { filter in
                    Button { selectedFilter = filter } label: {
                        Text(filter.title)
                            .font(.figtree(size: 13, weight: .medium))
                            .foregroundStyle(selectedFilter == filter ? .white : MintColor.tertiaryText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(selectedFilter == filter ? MintColor.accent : MintColor.surfaceHover)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }

    private func startNew() {
        if selectedMode == .edit {
            onCreateEdit()
        } else {
            onCreateGenerate()
        }
    }
}

private struct GalleryCard: View {
    let item: GalleryItem

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(item.thumbnailColor)
                Text(item.emoji)
                    .font(.system(size: 40))
                VStack {
                    HStack {
                        Text(item.mode == .edit ? "✂️ Edit" : "✨ Gen")
                            .font(.figtree(size: 8, weight: .bold))
                            .tracking(0.3)
                            .textCase(.uppercase)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.mode == .edit ? Color(red: 0.424, green: 0.361, blue: 0.906).opacity(0.7) : .black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        Spacer()
                        if let edits = item.edits {
                            Text("\(edits)")
                                .font(.figtree(size: 8, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    Spacer()
                    HStack {
                        Text(item.duration)
                            .font(.figtree(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        Spacer()
                    }
                }
                .padding(6)
            }
            .frame(height: 150)

            VStack(alignment: .leading, spacing: 0) {
                Text(item.title)
                    .font(.figtree(size: 12, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(MintColor.primaryText)
                Text("\(item.date) · \(item.views) views")
                    .font(.figtree(size: 10, weight: .regular))
                    .foregroundStyle(MintColor.tertiaryText)
                    .padding(.top, 1)
                if let edits = item.edits {
                    Text("✂️ \(edits) stateful edits")
                        .font(.figtree(size: 9, weight: .medium))
                        .foregroundStyle(Color(red: 0.424, green: 0.361, blue: 0.906))
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(MintColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }
}

private struct GalleryItem: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let date: String
    let duration: String
    let mode: GalleryMode
    let edits: Int?
    let views: Int
    let hue: Double

    var thumbnailColor: Color {
        Color(hue: hue / 360, saturation: 0.18, brightness: 0.92)
    }
}

private enum GalleryMode {
    case edit
    case generate
}

private enum GalleryFilter: CaseIterable, Identifiable {
    case all
    case edited
    case generated
    case favorites

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "All"
        case .edited: "Edited"
        case .generated: "Generated"
        case .favorites: "Favorites"
        }
    }
}

#Preview {
    HomeView(onCreateGenerate: {}, onCreateEdit: {})
}
