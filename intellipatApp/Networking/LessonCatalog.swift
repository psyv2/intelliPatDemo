import Foundation

/// Supplies lesson titles. The mock backend only returns a lesson count, so we
/// provide curated titles for known courses and a generic fallback.
enum LessonCatalog {
    private static let curated: [Int: [String]] = [
        1: [
            "Introduction", "Variables & Data Types", "Functions", "OOP",
            "Modules & Packages", "File Handling", "Error Handling",
            "Comprehensions", "Decorators", "Generators"
        ],
        2: [
            "What is Generative AI", "Transformers 101", "Prompt Engineering",
            "Embeddings", "Fine-tuning", "RAG Pipelines", "Evaluation",
            "Guardrails & Safety"
        ],
        3: [
            "HTML & CSS", "JavaScript Basics", "React Fundamentals",
            "State Management", "REST APIs", "Databases", "Authentication",
            "Deployment"
        ]
    ]

    static func titles(forCourseID id: Int, count: Int) -> [String] {
        let base = curated[id] ?? []
        return (0..<count).map { index in
            index < base.count ? base[index] : "Lesson \(index + 1)"
        }
    }
}
