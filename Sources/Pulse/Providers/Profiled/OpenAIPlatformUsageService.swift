import Foundation

/// Not implemented yet: a placeholder so the case has a profile to answer
/// with. Replaced by the real service.
extension ProviderProfile {
    static let openAIPlatform = ProviderProfile(
        displayName: "OpenAI API",
        iconResource: "extension",
        credential: .apiKey(optional: false),
        accessDescription: { .localized("Uses only the API key you enter in Settings. No Keychain prompt.") },
        setupSlug: "openai-api",
        fetch: { $0.unavailable(.loading) }
    )
}
