import Foundation

/// Not implemented yet: a placeholder so the case has a profile to answer
/// with. Replaced by the real service.
extension ProviderProfile {
    static let alibabaCodingPlan = ProviderProfile(
        displayName: "Alibaba Coding Plan",
        iconResource: "extension",
        credential: .apiKey(optional: false),
        accessDescription: { .localized("Uses only the API key you enter in Settings. No Keychain prompt.") },
        setupSlug: "alibaba-coding-plan",
        fetch: { $0.unavailable(.loading) }
    )
}
