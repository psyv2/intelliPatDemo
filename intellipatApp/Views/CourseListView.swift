import SwiftUI

struct CourseListView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(SessionStore.self) private var session
    @State private var viewModel: CourseListViewModel

    init(viewModel: CourseListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("My Courses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") { session.signOut() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    offlineToggle
                }
            }
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading courses…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let courses):
            loadedList(courses)

        case .empty:
            ContentUnavailableView(
                "No Courses Yet",
                systemImage: "books.vertical",
                description: Text("Courses you enroll in will appear here.")
            )

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't Load Courses", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.refresh() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func loadedList(_ courses: [Course]) -> some View {
        List {
            if viewModel.isShowingCachedData {
                offlineBanner
            }
            ForEach(courses) { course in
                NavigationLink(value: course) {
                    CourseRow(course: course)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.refresh() }
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(
                viewModel: CourseDetailViewModel(
                    course: course,
                    repository: environment.courseRepository,
                    onCourseUpdated: { viewModel.apply($0) }
                )
            )
        }
    }

    private var offlineBanner: some View {
        Label("You're offline — showing saved courses.", systemImage: "wifi.slash")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .listRowBackground(Color.yellow.opacity(0.15))
    }

    // Demo-only switch to simulate losing connectivity.
    private var offlineToggle: some View {
        Button {
            environment.courseAPI.shouldFail.toggle()
        } label: {
            Image(systemName: environment.courseAPI.shouldFail ? "wifi.slash" : "wifi")
        }
        .accessibilityLabel("Toggle simulated connectivity")
    }
}

private struct CourseRow: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.headline)
            Text(course.instructor)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: course.progressFraction) {
                HStack {
                    Text("\(course.progressPercent)% complete")
                    Spacer()
                    Text("\(course.completedLessonCount)/\(course.lessonCount) lessons")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Text("Continue")
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(.tint)
        }
        .padding(.vertical, 6)
    }
}
