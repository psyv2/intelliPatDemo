import SwiftData

/// SwiftData persistence models. Kept separate from the domain `Course`/`Lesson`
/// structs so the storage layer stays an implementation detail of the cache.
@Model
final class CourseModel {
    @Attribute(.unique) var id: Int
    var title: String
    var instructor: String
    @Relationship(deleteRule: .cascade) var lessons: [LessonModel]

    init(id: Int, title: String, instructor: String, lessons: [LessonModel] = []) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.lessons = lessons
    }
}

@Model
final class LessonModel {
    var id: Int
    var title: String
    var isCompleted: Bool
    var order: Int

    init(id: Int, title: String, isCompleted: Bool, order: Int) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.order = order
    }
}

extension ModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: CourseModel.self, LessonModel.self)
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
    }()
}
