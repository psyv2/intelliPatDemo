import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""

    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var emailError: String?
    private(set) var passwordError: String?

    private let authRepository: AuthRepositoryProtocol
    private let onAuthenticated: () -> Void

    init(authRepository: AuthRepositoryProtocol, onAuthenticated: @escaping () -> Void) {
        self.authRepository = authRepository
        self.onAuthenticated = onAuthenticated
    }

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    func login() async {
        guard validate() else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await authRepository.login(email: email, password: password)
            onAuthenticated()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Something went wrong. Please try again."
        }
    }

    @discardableResult
    func validate() -> Bool {
        emailError = Self.isValidEmail(email) ? nil : "Enter a valid email address."
        passwordError = password.count >= 6 ? nil : "Password must be at least 6 characters."
        return emailError == nil && passwordError == nil
    }

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
