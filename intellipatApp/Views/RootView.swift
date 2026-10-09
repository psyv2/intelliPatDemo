import SwiftUI

/// Top-level router between the login screen and the authenticated experience.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(SessionStore.self) private var session

    var body: some View {
        if session.isAuthenticated {
            NavigationStack {
                CourseListView(
                    viewModel: CourseListViewModel(repository: environment.courseRepository)
                )
            }
        } else {
            LoginView(
                viewModel: LoginViewModel(
                    authRepository: environment.authRepository,
                    onAuthenticated: { session.signedIn() }
                )
            )
        }
    }
}
