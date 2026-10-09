import Foundation

enum APIError: LocalizedError, Equatable {
    case network
    case notFound
    case decoding
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .network:
            return "We couldn't reach the server. Check your connection and try again."
        case .notFound:
            return "The requested data could not be found."
        case .decoding:
            return "We received an unexpected response from the server."
        case .invalidCredentials:
            return "Incorrect email or password."
        }
    }
}
