import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let url: URL?
    var height: CGFloat = 200

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                .fill(MintColor.surfaceHover)

            if let url {
                VideoPlayer(player: AVPlayer(url: url))
                    .clipShape(RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous))
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.4))
                    .clipShape(Circle())
            }
        }
        .frame(height: height)
        .overlay {
            RoundedRectangle(cornerRadius: MintRadius.large, style: .continuous)
                .stroke(MintColor.border, lineWidth: 1)
        }
    }
}
