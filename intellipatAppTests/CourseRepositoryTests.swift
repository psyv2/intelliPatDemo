import Testing
@testable import intellipatApp

@MainActor
struct CourseRepositoryTests {

    final class InMemoryCourseStore: CourseStore {
        private var courses: [Course]
        init(courses: [Course] = []) { self.courses = courses }
        func load() -> [Course] { courses }
        func save(_ courses: [Course]) { self.courses = courses }
        func clear() { courses = [] }
    }

    final class StubCourseAPI: CourseAPI {
        var result: Result<[CourseDTO], Error>
        init(result: Result<[CourseDTO], Error>) { self.result = result }
        func fetchCourses() async throws -> [CourseDTO] {
            try result.get()
        }
    }

    private static let sampleDTOs = [
        CourseDTO(id: 1, title: "Python Programming", instructor: "John Smith", progress: 65, lessons: 20)
    ]

    @Test
    func progressIsDerivedFromCompletedLessons() {
        let course = CourseDTO(id: 1, title: "Python", instructor: "John", progress: 65, lessons: 20).toDomain()
        #expect(course.completedLessonCount == 13)
        #expect(course.progressPercent == 65)
    }

    @Test
    func loadFallsBackToCacheWhenApiFails() async throws {
        let cached = Self.sampleDTOs.map { $0.toDomain() }
        let repo = CourseRepository(
            api: StubCourseAPI(result: .failure(APIError.network)),
            store: InMemoryCourseStore(courses: cached)
        )

        let result = try await repo.loadCourses()

        #expect(result.isFromCache == true)
        #expect(result.courses == cached)
    }

    @Test
    func loadPropagatesErrorWhenApiFailsAndCacheIsEmpty() async {
        let repo = CourseRepository(
            api: StubCourseAPI(result: .failure(APIError.network)),
            store: InMemoryCourseStore()
        )

        await #expect(throws: APIError.network) {
            _ = try await repo.loadCourses()
        }
    }

    @Test
    func refreshPreservesLocallyCompletedLessons() async throws {
        let store = InMemoryCourseStore()
        let repo = CourseRepository(
            api: StubCourseAPI(result: .success(Self.sampleDTOs)),
            store: store
        )

        _ = try await repo.loadCourses()

        let updated = repo.toggleLessonCompletion(courseID: 1, lessonID: 20)
        #expect(updated?.lessons.first(where: { $0.id == 20 })?.isCompleted == true)
        #expect(updated?.completedLessonCount == 14)

        let refreshed = try await repo.loadCourses()
        let lesson20 = refreshed.courses.first?.lessons.first(where: { $0.id == 20 })
        #expect(lesson20?.isCompleted == true)
        #expect(refreshed.courses.first?.completedLessonCount == 14)
    }
}
