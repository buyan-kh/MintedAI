import Foundation
import Observation

@MainActor
@Observable
final class AppViewModel {
    var route: AppRoute = .onboarding
    var onboardingIndex = 0

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        switch environment["MINT_START_ROUTE"] {
        case "paywall":
            route = .paywall
        case "home":
            route = .home
        default:
            route = .onboarding
        }
    }

    func continueOnboarding() {
        if onboardingIndex < 2 {
            onboardingIndex += 1
        } else {
            route = .paywall
        }
    }

    func skipToPaywall() {
        route = .paywall
    }

    func enterHome() {
        route = .home
    }

    func startCreate() {
        route = .picker
    }
}
