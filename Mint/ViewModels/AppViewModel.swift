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
        case "settings":
            route = .settings
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

    func openSettings() {
        route = .settings
    }
}

@MainActor
@Observable
final class TokenLedger {
    let dailyLimit: Int
    var dailyRemaining: Int {
        didSet {
            persistDailyState()
        }
    }
    var bankedTokens: Int {
        didSet {
            defaults?.set(bankedTokens, forKey: bankedTokensKey)
        }
    }
    private let defaults: UserDefaults?
    private let bankedTokensKey = "mint.bankedTokens"
    private let dailyRemainingKey = "mint.dailyRemaining"
    private let dailyDateKey = "mint.dailyDate"
    private let dayIdentifier: String

    var displayText: String {
        "\(dailyRemaining)/\(dailyLimit)"
    }

    var usedToday: Int {
        max(0, dailyLimit - dailyRemaining)
    }

    var hasAvailableToken: Bool {
        dailyRemaining > 0 || bankedTokens > 0
    }

    init(
        dailyLimit: Int = 8,
        dailyRemaining: Int = 8,
        bankedTokens: Int = 2,
        persistBankedTokens: Bool = false,
        defaults: UserDefaults? = nil,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        self.dailyLimit = dailyLimit
        self.defaults = persistBankedTokens ? (defaults ?? .standard) : nil
        dayIdentifier = Self.dayIdentifier(for: now, calendar: calendar)
        let clampedDailyRemaining = min(max(0, dailyRemaining), dailyLimit)
        if persistBankedTokens,
           self.defaults?.string(forKey: dailyDateKey) == dayIdentifier,
           let savedDailyRemaining = self.defaults?.object(forKey: dailyRemainingKey) as? Int {
            self.dailyRemaining = min(max(0, savedDailyRemaining), dailyLimit)
        } else {
            self.dailyRemaining = clampedDailyRemaining
        }
        self.bankedTokens = if persistBankedTokens, let saved = self.defaults?.object(forKey: bankedTokensKey) as? Int {
            max(0, saved)
        } else {
            max(0, bankedTokens)
        }
        persistDailyState()
    }

    convenience init(environment: [String: String], persistBankedTokens: Bool = false) {
        let dailyLimit = 8
        let dailyRemaining = environment["MINT_DAILY_TOKENS"].flatMap(Int.init) ?? dailyLimit
        let bankedTokens = environment["MINT_BANKED_TOKENS"].flatMap(Int.init) ?? 2
        self.init(
            dailyLimit: dailyLimit,
            dailyRemaining: dailyRemaining,
            bankedTokens: bankedTokens,
            persistBankedTokens: persistBankedTokens && environment["MINT_BANKED_TOKENS"] == nil
        )
    }

    @discardableResult
    func spend() -> Bool {
        if spendDaily() {
            return true
        }
        guard bankedTokens > 0 else {
            return false
        }
        bankedTokens -= 1
        return true
    }

    @discardableResult
    func spendDaily() -> Bool {
        guard dailyRemaining > 0 else {
            return false
        }
        dailyRemaining -= 1
        return true
    }

    func restoreDailyToken() {
        guard dailyRemaining < dailyLimit else {
            return
        }
        dailyRemaining += 1
    }

    func buyPack(quantity: Int) {
        bankedTokens += max(0, quantity)
    }

    private func persistDailyState() {
        defaults?.set(dayIdentifier, forKey: dailyDateKey)
        defaults?.set(dailyRemaining, forKey: dailyRemainingKey)
    }

    private static func dayIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
