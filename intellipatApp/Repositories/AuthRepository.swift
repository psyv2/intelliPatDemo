import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func logout()
    var isLoggedIn: Bool { get }
}

final class AuthRepository: AuthRepositoryProtocol {
    private let api: AuthAPI
    private let tokenStore: TokenStore

    init(api: AuthAPI, tokenStore: TokenStore) {
        self.api = api
        self.tokenStore = tokenStore
    }

    var isLoggedIn: Bool {
        tokenStore.load() != nil
    }

    func login(email: String, password: String) async throws -> AuthToken {
        let token = try await api.login(email: email, password: password)
        tokenStore.save(token)
        return token
    }

    func logout() {
        tokenStore.clear()
    }
}
