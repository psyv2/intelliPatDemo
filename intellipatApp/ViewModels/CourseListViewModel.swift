import Foundation

@Observable
@MainActor
final class CourseListViewModel {
    private(set) var state: ViewState<[Course]> = .idle
    private(set) var isShowingCachedData = false

    private let repository: CourseRepositoryProtocol

    init(repository: CourseRepositoryProtocol) {
        self.repository = repository
    }

    func load() async {
        if case .loaded = state { return }
        await fetch(showLoading: true)
    }

    func refresh() async {
        await fetch(showLoading: false)
    }

    private func fetch(showLoading: Bool) async {
        if showLoading { state = .loading }

        do {
            let result = try await repository.loadCourses()
            isShowingCachedData = result.isFromCache
            state = result.courses.isEmpty ? .empty : .loaded(result.courses)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? "Unable to load courses."
            state = .failed(message)
        }
    }

    /// Replaces a single course after it was mutated on the detail screen.
    func apply(_ updatedCourse: Course) {
        guard case .loaded(var courses) = state,
              let index = courses.firstIndex(where: { $0.id == updatedCourse.id }) else {
            return
        }
        courses[index] = updatedCourse
        state = .loaded(courses)
    }
}
