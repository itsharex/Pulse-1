import Testing
@testable import Pulse

/// Which providers are subscriptions and which are API accounts, which decides
/// where each is listed. See `Provider.Billing`.
@Suite("Billing kind")
struct BillingTests {
    @Test("Money drawn down by the call is an API account; a plan is a subscription")
    func kinds() {
        for provider: Provider in [.deepSeek, .sub2api, .newAPI, .openAIPlatform, .xaiAPI, .moonshot, .liteLLM] {
            #expect(provider.billing == .api, "\(provider.rawValue)")
        }
        // A plan with a balance beside it is still a plan.
        for provider: Provider in [.claudeCode, .codex, .commandCode, .kimiCode, .clinePass, .amp, .kiloCode] {
            #expect(provider.billing == .subscription, "\(provider.rawValue)")
        }
    }

    @Test("Every API account that reports money says so, so its low-balance line is offered")
    func apiBalances() {
        for provider in Provider.builtIn where provider.billing == .api && provider.profile?.reportsSpendableBalance == true {
            #expect(provider.reportsSpendableBalance)
        }
    }
}

/// The Order group lists and moves only what the rail draws.
@Suite("Rail order among shown accounts")
@MainActor
struct ShownOrderTests {
    private func settings() -> AppSettings {
        AppSettings(enabledAccounts: ["codex", "claudeCode", "deepSeek"], providerOrder: ["codex", "kiro", "claudeCode", "deepSeek"])
    }

    @Test("An arrow moves past the next shown account, not past a hidden one")
    func arrowsSkipHidden() {
        let settings = settings()
        #expect(settings.shownAccounts.map(\.id) == ["codex", "claudeCode", "deepSeek"])
        settings.move(AccountKey(.claudeCode), by: -1)
        #expect(settings.shownAccounts.map(\.id) == ["claudeCode", "codex", "deepSeek"])
        // Kiro is off: it keeps a place, after the shown ones.
        #expect(settings.orderedAccounts.map(\.id).prefix(4) == ["claudeCode", "codex", "deepSeek", "kiro"])
    }

    @Test("A drop lands among the shown accounts, and the ends do nothing")
    func dropAndEnds() {
        let settings = settings()
        settings.move(AccountKey(.deepSeek), onto: AccountKey(.codex))
        #expect(settings.shownAccounts.map(\.id) == ["deepSeek", "codex", "claudeCode"])
        settings.move(AccountKey(.deepSeek), by: -1)
        #expect(settings.shownAccounts.map(\.id) == ["deepSeek", "codex", "claudeCode"])
        // A hidden account is not moved by either.
        settings.move(AccountKey(.kiro), by: 1)
        settings.move(AccountKey(.kiro), onto: AccountKey(.codex))
        #expect(settings.shownAccounts.map(\.id) == ["deepSeek", "codex", "claudeCode"])
    }
}
