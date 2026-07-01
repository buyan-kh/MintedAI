import SwiftUI

struct RootView: View {
    @State private var appViewModel = AppViewModel()

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
            case .picker, .prompt, .processing, .result:
                HomeView(onCreate: appViewModel.startCreate)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MintColor.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

#Preview {
    RootView()
}
