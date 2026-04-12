import SwiftUI

struct StagedEntrance: ViewModifier {
  let delay: Double
  let offset: CGFloat
  @State private var appeared = false

  func body(content: Content) -> some View {
    content
      .opacity(appeared ? 1 : 0)
      .offset(y: appeared ? 0 : offset)
      .onAppear {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(delay)) {
          appeared = true
        }
      }
  }
}

extension View {
  func staged(_ delay: Double = 0, offset: CGFloat = 16) -> some View {
    modifier(StagedEntrance(delay: delay, offset: offset))
  }
}

struct BreathingScale: ViewModifier {
  @State private var scaled = false
  let amount: CGFloat
  let duration: Double

  func body(content: Content) -> some View {
    content
      .scaleEffect(scaled ? 1 + amount : 1)
      .onAppear {
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
          scaled = true
        }
      }
  }
}

extension View {
  func breathing(amount: CGFloat = 0.03, duration: Double = 2.4) -> some View {
    modifier(BreathingScale(amount: amount, duration: duration))
  }
}
