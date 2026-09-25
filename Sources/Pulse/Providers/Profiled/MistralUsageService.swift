import Foundation

/// Not implemented yet: a placeholder so the case has a profile to answer
/// with. Replaced by the real service.
extension ProviderProfile {
    static let mistral = ProviderProfile(
        displayName: "Mistral",
        iconResource: "extension",
        credential: .apiKey(optional: false),
        accessDescription: { .localized("Uses only the API key you enter in Settings. No Keychain prompt.") },
        setupSlug: "mistral",
        fetch: { $0.unavailable(.loading) }
    )
}
