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
        case "generate":
            route = .generate
        case "processing":
            route = .processing
        case "success":
            route = .success
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

    func startGenerate() {
        route = .generate
    }

    func startEdit() {
        route = .picker
    }
}
