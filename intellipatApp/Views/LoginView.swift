import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 16) {
                    emailField
                    passwordField
                }

                if let errorMessage = viewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }

                loginButton

                demoHint
            }
            .padding(24)
        }
        .animation(.default, value: viewModel.errorMessage)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text("Welcome back")
                .font(.largeTitle.bold())
            Text("Sign in to continue learning.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            if let emailError = viewModel.emailError {
                Text(emailError).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 4) {
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
            if let passwordError = viewModel.passwordError {
                Text(passwordError).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var loginButton: some View {
        Button {
            Task { await viewModel.login() }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
                Text(viewModel.isLoading ? "Signing in…" : "Login")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.canSubmit)
    }

    private var demoHint: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Demo credentials").font(.caption.bold())
            Text("test@example.com / password123")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
    }
}
