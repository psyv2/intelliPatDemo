import Foundation

@Observable
@MainActor
final class CourseDetailViewModel {
    private(set) var course: Course

    private let repository: CourseRepositoryProtocol
    private let onCourseUpdated: (Course) -> Void

    init(course: Course,
         repository: CourseRepositoryProtocol,
         onCourseUpdated: @escaping (Course) -> Void) {
        self.course = course
        self.repository = repository
        self.onCourseUpdated = onCourseUpdated
    }

    func toggleCompletion(for lesson: Lesson) {
        guard let updated = repository.toggleLessonCompletion(
            courseID: course.id,
            lessonID: lesson.id
        ) else { return }

        course = updated
        onCourseUpdated(updated)
    }
}
