import Foundation

/// Composition root. Wires concrete implementations together so the rest of the
/// app depends only on protocols.
@Observable
@MainActor
final class AppEnvironment {
    let authRepository: AuthRepositoryProtocol
    let courseRepository: CourseRepositoryProtocol
    let courseAPI: MockCourseAPI

    init() {
        let courseAPI = MockCourseAPI()
        self.courseAPI = courseAPI

        courseRepository = CourseRepository(
            api: courseAPI,
            store: SwiftDataCourseStore()
        )
        authRepository = AuthRepository(
            api: MockAuthAPI(),
            tokenStore: KeychainTokenStore()
        )
    }
}
