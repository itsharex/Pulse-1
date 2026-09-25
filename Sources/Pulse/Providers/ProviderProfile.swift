import Foundation

/// Everything a provider says about itself, in one value, for the providers
/// written after there were dozens of them.
///
/// **Why this exists.** The first twenty-five providers each answer twenty-odd
/// exhaustive `switch`es spread over the app — name, icon, credential, access
/// sentence, route, colour, setup page, discovery, fetch. That is what made
/// every one of them get looked at in every place, and it is also what made
/// adding fifty more a merge conflict in every one of those files. A profiled
/// provider still has its case in every one of those switches, but the arm
/// hands the question to its profile, and the profile lives in the provider's
/// own file under `Providers/Profiled/`. Adding or changing one touches that
/// file and nothing shared.
///
/// Nothing here relaxes a rule. A profile states a credential kind, and the
/// kinds are the ones the rest of the app already knows how to draw and guard:
/// a pasted key, a browser session read on request, a key and a server address,
/// or a login the provider's own tool saved on this Mac.
struct ProviderProfile: Sendable {
    enum Credential: Sendable, Equatable {
        /// A key the user pastes. `optional` when the service can also find a
        /// login its own tool saved, and the field is only for a key from
        /// somewhere else.
        case apiKey(optional: Bool)
        /// A browser session for `host`, read when the user presses Read and
        /// kept to the named cookies. The first name is the one that has to
        /// be there for the session to count.
        case sessionCookie(host: String, cookies: [String])
        /// A self-hosted gateway: a key, and the address it is sent to. The
        /// key goes nowhere else.
        case keyAndAddress
        /// Nothing pasted: the service reads a login its own app or CLI saved.
        case localLogin
    }

    /// The product's name, left untranslated.
    let displayName: String
    /// An SVG in `Resources`, without its extension.
    let iconResource: String
    let credential: Credential
    /// Shown before the provider is switched on, in the chooser and in
    /// Settings. What is read and from where — never a guess.
    let accessDescription: @Sendable () -> String
    /// The subtitle under the credential field. Nil for the shared wording.
    var keySubtitle: (@Sendable () -> String)? = nil
    /// For a `localLogin` provider, the route named on its pane.
    var soleRoute: (@Sendable () -> (name: String, note: String))? = nil
    /// Money in an account, spent by the call, with a number and a currency.
    var reportsSpendableBalance = false
    /// See `Provider.spendingIsWatchedLocally`. False for anything spent on
    /// somebody else's servers where nothing on this Mac moves.
    var spendingIsWatchedLocally = true
    /// Whether a banked reading may stand in only for the same account.
    var requiresScopeMatch = false
    /// The brand's colour for the animated mark, where the brand has one.
    var brandColor: UInt32? = nil
    /// `Docs/setup/<slug>.md`, which the in-app Setup help link opens.
    let setupSlug: String
    /// Presence-only hints for the chooser, relative to the home folder
    /// unless absolute. Never read, only checked for existence.
    var discoveryPaths: [String] = []
    /// The reading. Runs off the main actor; must never throw, and must
    /// return `.unavailable` with a reason from the shared set rather than
    /// invent one.
    let fetch: @Sendable (ProfileContext) async -> ProviderUsage
}

/// What the store hands a profiled provider's fetch: the provider, whatever
/// Pulse holds for it, and the settings that can change what it asks.
struct ProfileContext: Sendable {
    let provider: Provider
    /// The pasted key or the imported session header, if there is one.
    let credential: String?
    /// For `keyAndAddress`, the address the reader entered.
    let serverAddress: String?

    var account: AccountKey { AccountKey(provider) }

    /// The one way a profiled fetch says it has nothing. Keeps the account and
    /// the reason together so no provider can file a failure under another.
    func unavailable(_ reason: ProviderUsage.Unavailability) -> ProviderUsage {
        .unavailable(account, reason: reason)
    }
}

extension ProviderProfile {
    /// Keeps only the named cookies out of a browser's `name=value; …`
    /// header, and nothing at all if the first name is missing. What is not
    /// kept never leaves the process.
    static func keep(_ header: String, cookies names: [String]) -> String? {
        guard let required = names.first else { return nil }
        let pairs = header.split(separator: ";").compactMap { part -> (String, String)? in
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            guard let equals = trimmed.firstIndex(of: "=") else { return nil }
            let name = String(trimmed[..<equals])
            let value = String(trimmed[trimmed.index(after: equals)...])
            return names.contains(name) && !value.isEmpty ? (name, value) : nil
        }
        guard pairs.contains(where: { $0.0 == required }) else { return nil }
        var seen: Set<String> = []
        return pairs.filter { seen.insert($0.0).inserted }
            .map { "\($0.0)=\($0.1)" }
            .joined(separator: "; ")
    }
}

/// So a request can fail with the reason itself: `Result<Data, Unavailability>`.
extension ProviderUsage.Unavailability: Error {}

/// One request, and what its status means, for the profiled providers.
///
/// Every one of them asks an HTTP endpoint and every one of them has to turn
/// the same handful of failures into the same handful of reasons. Written once
/// so that a refused key reads as a refused key everywhere — and so a provider
/// cannot quietly treat a 500 as "no limits".
enum ProfileHTTP {
    struct Reply: Sendable {
        let data: Data
        let status: Int
    }

    /// Sends `request` and returns the body of a 2xx reply, or the reason there
    /// is none. `refused` is what a 401 or 403 means for this credential: a
    /// pasted key, a browser session, or a saved login.
    static func data(
        for request: URLRequest,
        refused: ProviderUsage.Unavailability = .apiKeyRefused,
        session: URLSession? = nil
    ) async -> Result<Data, ProviderUsage.Unavailability> {
        switch await reply(for: request, session: session) {
        case .failure(let reason): return .failure(reason)
        case .success(let reply): return classify(reply, refused: refused)
        }
    }

    /// What a status means, apart from the request. Separate so a provider's
    /// tests can pin its mapping without a network.
    static func classify(_ reply: Reply, refused: ProviderUsage.Unavailability = .apiKeyRefused)
        -> Result<Data, ProviderUsage.Unavailability> {
        switch reply.status {
        case 200..<300: .success(reply.data)
        case 401, 403: .failure(refused)
        case 429: .failure(.rateLimited)
        default: .failure(.serverError)
        }
    }

    /// The reply whatever its status, for a provider whose failures carry
    /// meaning in the body. Only a request that never got an answer fails.
    static func reply(
        for request: URLRequest,
        session: URLSession? = nil
    ) async -> Result<Reply, ProviderUsage.Unavailability> {
        guard let (data, response) = try? await (session ?? NetworkSession.shared).data(for: request),
              let http = response as? HTTPURLResponse
        else { return .failure(.unreachable) }
        return .success(Reply(data: data, status: http.statusCode))
    }

    /// A GET with a bearer token, which is most of them.
    static func bearer(_ url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        return request
    }

    /// ISO 8601 with or without fractional seconds, the two shapes every
    /// service here uses.
    static func date(_ text: String?) -> Date? {
        guard let text, !text.isEmpty else { return nil }
        let plain = ISO8601DateFormatter()
        if let date = plain.date(from: text) { return date }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: text)
    }
}

extension ProfileContext {
    /// The credential, trimmed, or nil when there is nothing usable.
    var trimmedCredential: String? {
        credential.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.flatMap { $0.isEmpty ? nil : $0 }
    }

    /// A live reading of this provider, from what it reported.
    func reading(
        _ windows: [UsageWindow],
        plan: String? = nil,
        creditBalance: String? = nil,
        creditRemaining: ProviderUsage.CreditAmount? = nil,
        at now: Date = Date()
    ) -> ProviderUsage {
        var usage = ProviderUsage(
            account: account,
            windows: windows,
            observedAt: now,
            state: .live,
            plan: plan,
            creditBalance: creditBalance
        )
        usage.creditRemaining = creditRemaining
        return usage
    }
}
