import Foundation

/// The API wire format, kept separate from the domain `Course`.
struct CourseDTO: Codable, Equatable {
    let id: Int
    let title: String
    let instructor: String
    let progress: Int
    let lessons: Int
}

extension CourseDTO {
    /// Expands the compact DTO into a domain `Course`, synthesising lessons and
    /// marking the first N complete so derived progress matches the server value.
    func toDomain() -> Course {
        let titles = LessonCatalog.titles(forCourseID: id, count: lessons)
        let completedCount = Int((Double(progress) / 100.0 * Double(lessons)).rounded())

        let lessonModels = titles.enumerated().map { index, title in
            Lesson(id: index + 1, title: title, isCompleted: index < completedCount)
        }
        return Course(id: id, title: title, instructor: instructor, lessons: lessonModels)
    }
}
