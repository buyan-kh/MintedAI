import SwiftUI

struct RootView: View {
    @State private var appViewModel = AppViewModel()
    @State private var editSessionViewModel: EditSessionViewModel
    @State private var processingTitle = "Creating your video"
    @State private var processingMessage = "AI is working on it..."
    @State private var processingStage = "Starting..."

    init(container: AppContainer = .live()) {
        _editSessionViewModel = State(initialValue: container.editSessionViewModel)
    }

    var body: some View {
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
                    onCreateEdit: appViewModel.startEdit
                )
            case .generate:
                GenerateView(
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
                    onBack: { appViewModel.route = .picker },
                    onSubmit: { prompt in
                        submit(prompt)
                    }
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
            case .result:
                ResultView(
                    viewModel: editSessionViewModel,
                    onHome: appViewModel.enterHome,
                    onRefine: { prompt in
                        submit(prompt)
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MintColor.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private func submit(_ prompt: String) {
        processingTitle = "Creating your video"
        processingMessage = "AI is working on it..."
        processingStage = "Starting..."
        appViewModel.route = .processing
        Task {
            await editSessionViewModel.submitPrompt(prompt)
            appViewModel.route = editSessionViewModel.errorMessage == nil ? .result : .prompt
        }
    }

    private func submitGeneration(_ prompt: String) {
        guard prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        processingTitle = "Creating your video"
        processingMessage = "AI is working on it..."
        processingStage = "Starting..."
        appViewModel.route = .processing
        Task {
            let stages = ["Generating frames...", "Applying style...", "Adding motion...", "Rendering 4K...", "Finalizing...", "Done!"]
            for stage in stages {
                try? await Task.sleep(nanoseconds: 450_000_000)
                processingStage = stage
            }
            appViewModel.route = .success
        }
    }
}

#Preview {
    RootView()
}
