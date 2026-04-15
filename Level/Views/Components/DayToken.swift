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

      switch state {
      case .empty:
        Circle()
          .stroke(Color.black.opacity(0.55), lineWidth: 2)
          .blur(radius: 1.5)
          .mask(
            Circle().fill(
              LinearGradient(
                colors: [Color.black, Color.clear],
                startPoint: .top,
                endPoint: .bottom
              )
            )
          )
      case .completed, .missed:
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

      Circle()
        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
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
    case .empty: return Color.deepGrape
    case .completed: return Color.teaGreen
    case .missed: return Color.pastelPink.opacity(0.55)
    }
  }
}
