import SwiftUI

struct RootView: View {
    @State private var appViewModel = AppViewModel()
    @State private var editSessionViewModel: EditSessionViewModel
    @State private var processingTitle = "Creating your video"
    @State private var processingMessage = "AI is working on it..."
    @State private var processingStage = "Starting..."
    @State private var generationErrorMessage: String?
    @State private var generatedVideo: GeneratedVideo?
    @State private var tokenLedger: TokenLedger
    @State private var isBuyTokensPresented = false
    @State private var toastMessage: String?
    private let textToVideoService: TextToVideoGenerating

    init(container: AppContainer = .live()) {
        _editSessionViewModel = State(initialValue: container.editSessionViewModel)
        let isUITest = ProcessInfo.processInfo.arguments.contains("UITEST_MOCK_GEMINI")
        _tokenLedger = State(initialValue: TokenLedger(
            environment: ProcessInfo.processInfo.environment,
            persistBankedTokens: isUITest == false
        ))
        textToVideoService = container.textToVideoService
    }

    var body: some View {
        ZStack {
            Group {
                switch appViewModel.route {
                case .onboarding:
                    OnboardingView(
                        index: appViewModel.onboardingIndex,
                        onContinue: appViewModel.continueOnboarding,
                        onSkip: appViewModel.skipToPaywall
                    )
                case .paywall:
                    PaywallInviteView(onContinue: appViewModel.enterHome)
                case .home:
                    HomeView(
                        onCreateGenerate: appViewModel.startGenerate,
                        onCreateEdit: appViewModel.startEdit,
                        onSettings: appViewModel.openSettings
                    )
                case .generate:
                    GenerateView(
                        tokenLedger: tokenLedger,
                        errorMessage: generationErrorMessage,
                        onBack: appViewModel.enterHome,
                        onGenerate: { prompt in
                            submitGeneration(prompt)
                        }
                    )
                case .picker:
                    VideoPickerView(
                        onBack: appViewModel.enterHome,
                        onVideoImported: { url in
                            editSessionViewModel.startSession(sourceVideoURL: url)
                            appViewModel.route = .prompt
                        }
                    )
                case .prompt:
                    PromptView(
                        viewModel: editSessionViewModel,
                        tokenLedger: tokenLedger,
                        onBack: appViewModel.enterHome,
                        onSubmit: { prompt in
                            submit(prompt)
                        },
                        onUndo: editSessionViewModel.undoLastEdit,
                        onRevert: { version in
                            revertToVersion(version)
                        },
                        onOutOfTokens: { isBuyTokensPresented = true },
                        onToast: showToast,
                        onExport: { appViewModel.route = .success }
                    )
                case .processing:
                    ProcessingView(
                        title: processingTitle,
                        message: processingMessage,
                        stage: processingStage
                    )
                case .success:
                    SuccessView(
                        onHome: appViewModel.enterHome,
                        onGenerateAnother: appViewModel.startGenerate
                    )
                case .settings:
                    SettingsView(tokenLedger: tokenLedger, onBack: appViewModel.enterHome)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MintColor.background.ignoresSafeArea())
            .preferredColorScheme(.light)

            if isBuyTokensPresented {
                BuyTokensOverlay(
                    onBuy: { quantity in
                        tokenLedger.buyPack(quantity: quantity)
                        isBuyTokensPresented = false
                        showToast("✨ Purchased \(quantity) edits!")
                    },
                    onClose: { isBuyTokensPresented = false }
                )
            }

            if let toastMessage {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.figtree(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(MintColor.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func submit(_ prompt: String) {
        Task {
            await editSessionViewModel.submitPrompt(prompt)
            if editSessionViewModel.errorMessage != nil {
                tokenLedger.restoreDailyToken()
            }
        }
    }

    private func revertToVersion(_ version: Int) {
        let removedCount = editSessionViewModel.revertToVersion(version)
        guard removedCount > 0 else {
            showToast("Reverted to v\(version)")
            return
        }
        for _ in 0..<removedCount {
            tokenLedger.restoreDailyToken()
        }
        showToast("Reverted to v\(version)")
    }

    private func submitGeneration(_ prompt: String) {
        guard prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        guard tokenLedger.spend() else {
            isBuyTokensPresented = true
            return
        }
        generationErrorMessage = nil
        processingTitle = "Creating your video"
        processingMessage = "AI is working on it..."
        processingStage = "Starting..."
        appViewModel.route = .processing
        Task {
            do {
                processingStage = "Generating frames..."
                generatedVideo = try await textToVideoService.generateVideo(prompt: prompt, aspectRatio: "9:16")
                processingStage = "Done!"
                appViewModel.route = .success
            } catch {
                tokenLedger.restoreDailyToken()
                generationErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                appViewModel.route = .generate
            }
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            toastMessage = message
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            await MainActor.run {
                guard toastMessage == message else { return }
                withAnimation(.easeIn(duration: 0.2)) {
                    toastMessage = nil
                }
            }
        }
    }
}

private struct BuyTokensOverlay: View {
    let onBuy: (Int) -> Void
    let onClose: () -> Void

    private let packs = [
        (quantity: 10, price: "$1.99", per: "$0.20 each"),
        (quantity: 50, price: "$7.99", per: "$0.16 each"),
        (quantity: 200, price: "$24.99", per: "$0.12 each")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(red: 0.867, green: 0.867, blue: 0.867))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 16)

                Text("Out of daily edits")
                    .font(.figtree(size: 18, weight: .bold))
                    .foregroundStyle(MintColor.primaryText)
                    .padding(.bottom, 4)

                Text("You've used all 8 today. Grab a pack to keep going.")
                    .font(.figtree(size: 13, weight: .regular))
                    .foregroundStyle(MintColor.tertiaryText)
                    .padding(.bottom, 16)

                VStack(spacing: 8) {
                    ForEach(packs, id: \.quantity) { pack in
                        Button { onBuy(pack.quantity) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(pack.quantity) edits")
                                        .font(.figtree(size: 15, weight: .semibold))
                                        .foregroundStyle(MintColor.primaryText)
                                    Text(pack.per)
                                        .font(.figtree(size: 10, weight: .regular))
                                        .foregroundStyle(MintColor.tertiaryText)
                                }
                                Spacer()
                                Text(pack.price)
                                    .font(.figtree(size: 16, weight: .bold))
                                    .foregroundStyle(MintColor.primaryText)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(MintColor.background)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(MintColor.border, lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(pack.quantity) edits")
                    }
                }

                Button("Maybe later", action: onClose)
                    .font(.figtree(size: 14, weight: .semibold))
                    .foregroundStyle(MintColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(MintColor.surfaceHover)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .buttonStyle(.plain)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            .background(MintColor.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous))
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .zIndex(10)
    }
}

#Preview {
    RootView()
}
