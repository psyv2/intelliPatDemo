import Foundation

/// The lifecycle of an asynchronously loaded screen. A single enum guarantees
/// the UI is always in exactly one state.
enum ViewState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(String)
}
