import Foundation

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

struct Course: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let instructor: String
    var lessons: [Lesson]

    var lessonCount: Int { lessons.count }

    var completedLessonCount: Int {
        lessons.filter(\.isCompleted).count
    }

    /// Derived from the lessons so progress can never disagree with the checklist.
    var progressPercent: Int {
        guard !lessons.isEmpty else { return 0 }
        return Int((Double(completedLessonCount) / Double(lessonCount) * 100).rounded())
    }

    var progressFraction: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessonCount) / Double(lessonCount)
    }
}
