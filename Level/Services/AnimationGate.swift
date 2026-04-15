import Foundation

@MainActor
final class AnimationGate {
  static let shared = AnimationGate()

  private var pending: Bool = true

  private init() {}

  func markPending() {
    pending = true
  }

  func consume() -> Bool {
    let value = pending
    pending = false
    return value
  }
}
