import Foundation

/// App-level authentication state that drives top-level navigation.
@Observable
@MainActor
final class SessionStore {
    private(set) var isAuthenticated: Bool
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        isAuthenticated = authRepository.isLoggedIn
    }

    func signedIn() {
        isAuthenticated = true
    }

    func signOut() {
        authRepository.logout()
        isAuthenticated = false
    }
}
