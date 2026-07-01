import SwiftUI

struct ProcessingView: View {
    @Bindable var viewModel: EditSessionViewModel
    @State private var progressOffset: CGFloat = -0.8

    var body: some View {
        VStack(spacing: MintSpacing.lg) {
            ProgressView()
                .controlSize(.large)
                .tint(MintColor.accent)
                .scaleEffect(1.7)
                .frame(width: 64, height: 64)

            VStack(spacing: MintSpacing.xs) {
                Text("Creating your video")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(MintColor.primaryText)
                Text(viewModel.stage)
                    .font(.mintBodyRegular)
                    .foregroundStyle(MintColor.secondaryText)
                    .multilineTextAlignment(.center)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.933, green: 0.933, blue: 0.933))
                    Capsule()
                        .fill(MintColor.accent)
                        .frame(width: proxy.size.width * 0.35)
                        .offset(x: proxy.size.width * progressOffset)
                }
            }
            .frame(width: 200, height: 4)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(MintSpacing.xxl)
        .mintScreen()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false)) {
                progressOffset = 1.1
            }
        }
    }
}
