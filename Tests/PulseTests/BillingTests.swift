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
