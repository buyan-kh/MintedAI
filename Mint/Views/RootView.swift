import SwiftUI

struct RootView: View {
    @State private var appViewModel = AppViewModel()
    @State private var editSessionViewModel: EditSessionViewModel

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
                HomeView(onCreate: appViewModel.startCreate)
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
                ProcessingView(viewModel: editSessionViewModel)
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
        appViewModel.route = .processing
        Task {
            await editSessionViewModel.submitPrompt(prompt)
            appViewModel.route = editSessionViewModel.errorMessage == nil ? .result : .prompt
        }
    }
}

#Preview {
    RootView()
}
