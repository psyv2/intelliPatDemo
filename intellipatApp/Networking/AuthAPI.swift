import Foundation

protocol AuthAPI {
    func login(email: String, password: String) async throws -> AuthToken
}

/// Accepts a single demo account so both success and error states are easy to
/// reproduce: `test@example.com` / `password123`.
final class MockAuthAPI: AuthAPI {
    static let demoEmail = "test@example.com"
    static let demoPassword = "password123"

    var latency: Duration = .milliseconds(900)

    func login(email: String, password: String) async throws -> AuthToken {
        try? await Task.sleep(for: latency)

        guard email.lowercased() == Self.demoEmail,
              password == Self.demoPassword else {
            throw APIError.invalidCredentials
        }
        return AuthToken(accessToken: UUID().uuidString)
    }
}
