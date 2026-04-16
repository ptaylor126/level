import SwiftUI

enum DayTokenState {
  case empty
  case completed
  case missed
}

struct DayToken: View {
  let state: DayTokenState
  let size: CGFloat

  var body: some View {
    ZStack {
      Circle().fill(baseFill)

      if state == .completed || state == .missed {
        Circle()
          .fill(
            LinearGradient(
              stops: [
                .init(color: Color.white.opacity(0.35), location: 0),
                .init(color: Color.white.opacity(0), location: 0.55)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
        Circle()
          .fill(
            LinearGradient(
              stops: [
                .init(color: Color.black.opacity(0), location: 0.55),
                .init(color: Color.black.opacity(0.18), location: 1)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      }
    }
    .frame(width: size, height: size)
    .shadow(
      color: state == .empty ? .clear : Color.black.opacity(0.25),
      radius: 3,
      x: 0,
      y: 2
    )
  }

  private var baseFill: Color {
    switch state {
    case .empty: return Color.black.opacity(0.15)
    case .completed: return Color.teaGreen
    case .missed: return Color.pastelPink.opacity(0.55)
    }
  }
}
