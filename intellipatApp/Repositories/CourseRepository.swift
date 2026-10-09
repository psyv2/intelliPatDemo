import Foundation

struct CoursesResult: Equatable {
    let courses: [Course]
    let isFromCache: Bool
}

protocol CourseRepositoryProtocol {
    func loadCourses() async throws -> CoursesResult
    func toggleLessonCompletion(courseID: Int, lessonID: Int) -> Course?
}

/// Single source of truth for course data. Mediates between the API and the
/// local cache and owns the offline-fallback policy.
final class CourseRepository: CourseRepositoryProtocol {
    private let api: CourseAPI
    private let store: CourseStore

    init(api: CourseAPI, store: CourseStore) {
        self.api = api
        self.store = store
    }

    func loadCourses() async throws -> CoursesResult {
        do {
            let remote = try await api.fetchCourses().map { $0.toDomain() }
            let merged = merge(remote: remote, cached: store.load())
            store.save(merged)
            return CoursesResult(courses: merged, isFromCache: false)
        } catch {
            let cached = store.load()
            guard !cached.isEmpty else { throw error }
            return CoursesResult(courses: cached, isFromCache: true)
        }
    }

    func toggleLessonCompletion(courseID: Int, lessonID: Int) -> Course? {
        var courses = store.load()
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseID }),
              let lessonIndex = courses[courseIndex].lessons.firstIndex(where: { $0.id == lessonID }) else {
            return nil
        }

        courses[courseIndex].lessons[lessonIndex].isCompleted.toggle()
        store.save(courses)
        return courses[courseIndex]
    }

    /// Overlays locally-stored completion onto freshly fetched courses so a
    /// refresh never wipes the learner's progress.
    private func merge(remote: [Course], cached: [Course]) -> [Course] {
        guard !cached.isEmpty else { return remote }
        let cachedByID = Dictionary(uniqueKeysWithValues: cached.map { ($0.id, $0) })

        return remote.map { course in
            guard let cachedCourse = cachedByID[course.id] else { return course }
            let completedLessonIDs = Set(
                cachedCourse.lessons.filter(\.isCompleted).map(\.id)
            )
            var merged = course
            merged.lessons = course.lessons.map { lesson in
                var lesson = lesson
                lesson.isCompleted = completedLessonIDs.contains(lesson.id)
                return lesson
            }
            return merged
        }
    }
}
