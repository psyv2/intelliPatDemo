import SwiftUI

@main
struct intellipatAppApp: App {
    @State private var environment: AppEnvironment
    @State private var session: SessionStore

    init() {
        let environment = AppEnvironment()
        _environment = State(initialValue: environment)
        _session = State(initialValue: SessionStore(authRepository: environment.authRepository))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(session)
        }
    }
}
