import XCTest
@testable import Mint

final class EditorPreviewTests: XCTestCase {
    func testEditorPreviewDoesNotUseSystemVideoPlayerChrome() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let promptViewURL = projectDirectory.appendingPathComponent("Mint/Views/PromptView.swift")
        let source = try String(contentsOf: promptViewURL, encoding: .utf8)

        XCTAssertFalse(
            source.contains("VideoPlayer("),
            "Edit mode should use a plain preview layer so system video chrome cannot surface local filenames."
        )
        XCTAssertTrue(source.contains("EditorVideoPreview"))
    }

    func testPaywallSelectedPlanUsesHTMLBlackInsteadOfAccent() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let paywallURL = projectDirectory.appendingPathComponent("Mint/Views/PaywallInviteView.swift")
        let source = try String(contentsOf: paywallURL, encoding: .utf8)

        XCTAssertFalse(source.contains("selectedPlan == name || isPopular ? MintColor.accent"))
        XCTAssertFalse(source.contains(".background(MintColor.accent)"))
        XCTAssertFalse(source.contains("isSelected ? MintColor.accent"))
        XCTAssertFalse(source.contains(".fill(MintColor.accent)"))
        XCTAssertTrue(source.contains("htmlSelectedPlanColor"))
    }

    func testPhotosPickerBackButtonMatchesHTMLTopBar() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let pickerURL = projectDirectory.appendingPathComponent("Mint/Views/VideoPickerView.swift")
        let source = try String(contentsOf: pickerURL, encoding: .utf8)

        XCTAssertTrue(source.contains("Button(\"← Back\""))
        XCTAssertTrue(source.contains(".font(.figtree(size: 16, weight: .medium))"))
        XCTAssertFalse(source.contains("Button(\"Back\""))
        XCTAssertFalse(source.contains(".font(.system(size: 16, weight: .medium))"))
    }

    func testGenerateBottomTokenCounterMatchesHTMLSplitStyling() throws {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory.deletingLastPathComponent()
        let generateURL = projectDirectory.appendingPathComponent("Mint/Views/GenerateView.swift")
        let source = try String(contentsOf: generateURL, encoding: .utf8)

        XCTAssertTrue(source.contains("Text(\"\\(tokenLedger.dailyRemaining)\""))
        XCTAssertTrue(source.contains("Text(\"/\\(tokenLedger.dailyLimit)\""))
        XCTAssertTrue(source.contains(".foregroundColor(MintColor.tertiaryText)"))
        XCTAssertFalse(source.contains("Text(tokenText)\n                .font(.figtree(size: 10, weight: .bold))"))
    }

    @MainActor
    func testTokenLedgerSpendsDailyTokensRestoresAndBuysPacks() {
        let ledger = TokenLedger(dailyLimit: 8, dailyRemaining: 8, bankedTokens: 2)

        XCTAssertEqual(ledger.displayText, "8/8")
        XCTAssertEqual(ledger.usedToday, 0)
        XCTAssertTrue(ledger.spend())
        XCTAssertEqual(ledger.displayText, "7/8")
        XCTAssertEqual(ledger.usedToday, 1)

        ledger.restoreDailyToken()
        XCTAssertEqual(ledger.displayText, "8/8")
        XCTAssertEqual(ledger.usedToday, 0)

        ledger.dailyRemaining = 0
        XCTAssertTrue(ledger.spend())
        XCTAssertEqual(ledger.bankedTokens, 1)
        XCTAssertFalse(ledger.spendDaily())

        ledger.buyPack(quantity: 50)
        XCTAssertEqual(ledger.bankedTokens, 51)
    }

    @MainActor
    func testTokenLedgerPersistsSameDayUsageAndResetsDailyAllowance() throws {
        let suiteName = "TokenLedgerTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let firstDay = Date(timeIntervalSince1970: 1_767_225_600)
        let sameDay = firstDay.addingTimeInterval(3_600)
        let nextDay = firstDay.addingTimeInterval(86_400)

        let ledger = TokenLedger(
            dailyLimit: 8,
            dailyRemaining: 8,
            bankedTokens: 2,
            persistBankedTokens: true,
            defaults: defaults,
            now: firstDay,
            calendar: calendar
        )
        XCTAssertTrue(ledger.spend())
        ledger.buyPack(quantity: 10)

        let relaunchedSameDay = TokenLedger(
            dailyLimit: 8,
            dailyRemaining: 8,
            bankedTokens: 2,
            persistBankedTokens: true,
            defaults: defaults,
            now: sameDay,
            calendar: calendar
        )
        XCTAssertEqual(relaunchedSameDay.dailyRemaining, 7)
        XCTAssertEqual(relaunchedSameDay.bankedTokens, 12)

        let relaunchedNextDay = TokenLedger(
            dailyLimit: 8,
            dailyRemaining: 8,
            bankedTokens: 2,
            persistBankedTokens: true,
            defaults: defaults,
            now: nextDay,
            calendar: calendar
        )
        XCTAssertEqual(relaunchedNextDay.dailyRemaining, 8)
        XCTAssertEqual(relaunchedNextDay.bankedTokens, 12)
    }
}
