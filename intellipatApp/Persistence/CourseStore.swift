import Foundation
import SwiftData

protocol CourseStore {
    func load() -> [Course]
    func save(_ courses: [Course])
    func clear()
}

/// SwiftData-backed offline cache. Sits behind `CourseStore` so the repository
/// is unaware of the storage technology.
@MainActor
final class SwiftDataCourseStore: CourseStore {
    private let context: ModelContext

    init(container: ModelContainer = .shared) {
        context = ModelContext(container)
    }

    func load() -> [Course] {
        let descriptor = FetchDescriptor<CourseModel>(sortBy: [SortDescriptor(\.id)])
        guard let models = try? context.fetch(descriptor) else { return [] }

        return models.map { model in
            let lessons = model.lessons
                .sorted { $0.order < $1.order }
                .map { Lesson(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) }
            return Course(
                id: model.id,
                title: model.title,
                instructor: model.instructor,
                lessons: lessons
            )
        }
    }

    func save(_ courses: [Course]) {
        // The catalogue is small, so a full replace is the simplest correct
        // strategy and avoids diffing logic.
        deleteAll()

        for course in courses {
            let model = CourseModel(id: course.id, title: course.title, instructor: course.instructor)
            model.lessons = course.lessons.enumerated().map { index, lesson in
                LessonModel(id: lesson.id, title: lesson.title, isCompleted: lesson.isCompleted, order: index)
            }
            context.insert(model)
        }
        try? context.save()
    }

    func clear() {
        deleteAll()
        try? context.save()
    }

    private func deleteAll() {
        try? context.delete(model: CourseModel.self)
    }
}
