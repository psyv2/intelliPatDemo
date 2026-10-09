import Foundation

protocol CourseAPI {
    func fetchCourses() async throws -> [CourseDTO]
}

/// Reads the bundled `courses.json`, simulates latency, and can be forced to
/// fail to demonstrate the error / offline paths.
final class MockCourseAPI: CourseAPI {
    var shouldFail = false
    var latency: Duration = .milliseconds(800)

    func fetchCourses() async throws -> [CourseDTO] {
        try? await Task.sleep(for: latency)

        if shouldFail {
            throw APIError.network
        }

        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json") else {
            throw APIError.notFound
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([CourseDTO].self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
