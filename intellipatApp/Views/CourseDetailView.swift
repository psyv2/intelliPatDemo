import SwiftUI

struct CourseDetailView: View {
    @State private var viewModel: CourseDetailViewModel

    init(viewModel: CourseDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                progressHeader
            }

            Section("Lessons") {
                ForEach(viewModel.course.lessons) { lesson in
                    LessonRow(lesson: lesson) {
                        viewModel.toggleCompletion(for: lesson)
                    }
                }
            }
        }
        .navigationTitle(viewModel.course.title)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: viewModel.course)
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.course.title)
                .font(.title3.bold())
            Text(viewModel.course.instructor)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: viewModel.course.progressFraction) {
                HStack {
                    Text("\(viewModel.course.progressPercent)% complete")
                    Spacer()
                    Text("\(viewModel.course.completedLessonCount)/\(viewModel.course.lessonCount)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(lesson.isCompleted ? Color.green : Color.secondary)
                    .font(.title3)

                Text(lesson.title)
                    .foregroundStyle(.primary)

                Spacer()

                Text(lesson.isCompleted ? "Completed" : "Pending")
                    .font(.caption)
                    .foregroundStyle(lesson.isCompleted ? Color.green : Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
