import Foundation

/// Not implemented yet: a placeholder so the case has a profile to answer
/// with. Replaced by the real service.
extension ProviderProfile {
    static let ibmBob = ProviderProfile(
        displayName: "IBM Bob",
        iconResource: "extension",
        credential: .apiKey(optional: false),
        accessDescription: { .localized("Uses only the API key you enter in Settings. No Keychain prompt.") },
        setupSlug: "ibm-bob",
        fetch: { $0.unavailable(.loading) }
    )
}
