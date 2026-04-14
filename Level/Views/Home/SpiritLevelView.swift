import SwiftUI

enum BubbleLean: String {
  case left, right

  static func from(trigger: String?) -> BubbleLean? {
    guard let trigger = trigger?.lowercased() else { return nil }
    if trigger.contains("anxious") || trigger.contains("habit") {
      return .left
    }
    if trigger.contains("bored") || trigger.contains("avoiding") {
      return .right
    }
    return nil
  }
}

struct SpiritLevelView: View {
  let score: Int
  let recentTrigger: String?

  @State private var previousScore: Int?
  @State private var knockOffset: CGFloat = 0
  @State private var glowPulse: Double = 0
  @State private var persistedLean: BubbleLean = .left

  private var tubeHeight: CGFloat { 60 }
  private var bubbleDiameter: CGFloat { 44 }

  private var lean: BubbleLean {
    if let fromTrigger = BubbleLean.from(trigger: recentTrigger) {
      return fromTrigger
    }
    return persistedLean
  }

  private var clampedScore: Int {
    max(0, min(100, score))
  }

  private var distanceFraction: Double {
    Double(100 - clampedScore) / 100.0
  }

  private var tiltDegrees: Double {
    let magnitude = distanceFraction * 8.0
    return lean == .left ? magnitude : -magnitude
  }

  private var directionSign: CGFloat {
    lean == .left ? -1 : 1
  }

  private var isFlow: Bool {
    clampedScore >= 100
  }

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width
      let maxOffset = (width / 2) - (bubbleDiameter / 2) - 14
      let bubbleOffset = directionSign * CGFloat(distanceFraction) * maxOffset + knockOffset

      ZStack {
        if isFlow {
          Capsule()
            .fill(Color.cream)
            .blur(radius: 26)
            .opacity(0.35 + glowPulse * 0.35)
            .frame(width: width + 60, height: tubeHeight + 60)
        }

        ZStack {
          tubeBase
            .frame(width: width, height: tubeHeight)

          liquidFill
            .frame(width: width - 4, height: tubeHeight - 4)

          tubeGloss
            .frame(width: width - 4, height: tubeHeight - 4)

          calibrationLines
            .frame(height: tubeHeight * 0.6)

          bubble
            .offset(x: bubbleOffset)

          tubeRim
            .frame(width: width, height: tubeHeight)
        }
        .rotationEffect(.degrees(tiltDegrees))
        .animation(.spring(response: 0.9, dampingFraction: 0.8), value: tiltDegrees)
        .animation(.spring(response: 0.9, dampingFraction: 0.8), value: clampedScore)
      }
      .frame(width: width, height: tubeHeight + 16)
    }
    .frame(height: tubeHeight + 16)
    .onAppear {
      previousScore = clampedScore
      seedLeanIfNeeded()
      if isFlow { startGlow() }
    }
    .onChange(of: clampedScore) { old, new in
      handleScoreChange(from: old, to: new)
    }
  }

  // MARK: - Tube components

  private var tubeBase: some View {
    Capsule()
      .fill(
        LinearGradient(
          colors: [
            Color.teaGreen.opacity(0.35),
            Color.teaGreen.opacity(0.55)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
  }

  private var liquidFill: some View {
    let clarity = 0.5 + 0.5 * (Double(clampedScore) / 100.0)
    return Capsule()
      .fill(
        LinearGradient(
          stops: [
            .init(color: Color.teaGreen.opacity(0.55 + 0.4 * clarity), location: 0.0),
            .init(color: Color.teaGreen.opacity(0.9), location: 0.4),
            .init(color: Color.darkGreen.opacity(0.25 + 0.2 * clarity), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay(
        Capsule()
          .fill(Color.mutedGrape.opacity((1 - clarity) * 0.2))
      )
  }

  private var tubeGloss: some View {
    Capsule()
      .fill(
        LinearGradient(
          stops: [
            .init(color: Color.white.opacity(0.5), location: 0.0),
            .init(color: Color.white.opacity(0.15), location: 0.22),
            .init(color: Color.white.opacity(0.0), location: 0.55)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
  }

  private var calibrationLines: some View {
    HStack(spacing: 24) {
      Rectangle()
        .fill(Color.cream.opacity(0.8))
        .frame(width: 0.5)
      Rectangle()
        .fill(Color.cream.opacity(0.8))
        .frame(width: 0.5)
    }
  }

  private var tubeRim: some View {
    Capsule()
      .strokeBorder(
        LinearGradient(
          colors: [
            Color.white.opacity(0.35),
            Color.darkGreen.opacity(0.3)
          ],
          startPoint: .top,
          endPoint: .bottom
        ),
        lineWidth: 1.2
      )
  }

  private var bubble: some View {
    ZStack {
      Circle()
        .fill(Color.deepGrape.opacity(0.3))
        .frame(width: bubbleDiameter, height: bubbleDiameter)
        .offset(y: 3)
        .blur(radius: 4)

      Circle()
        .fill(
          RadialGradient(
            colors: [
              Color.cream,
              Color.cream.opacity(0.95),
              Color.warmGrey
            ],
            center: .init(x: 0.35, y: 0.3),
            startRadius: 2,
            endRadius: bubbleDiameter
          )
        )
        .frame(width: bubbleDiameter, height: bubbleDiameter)

      Circle()
        .fill(
          RadialGradient(
            colors: [Color.white.opacity(0.9), Color.white.opacity(0.0)],
            center: .init(x: 0.35, y: 0.3),
            startRadius: 0,
            endRadius: bubbleDiameter * 0.35
          )
        )
        .frame(width: bubbleDiameter, height: bubbleDiameter)

      Circle()
        .strokeBorder(Color.warmGrey.opacity(0.4), lineWidth: 0.5)
        .frame(width: bubbleDiameter, height: bubbleDiameter)
    }
  }

  // MARK: - Animations

  private func seedLeanIfNeeded() {
    if BubbleLean.from(trigger: recentTrigger) != nil { return }
    if let saved = SharedStore.defaults.string(forKey: "bubbleLean"),
       let restored = BubbleLean(rawValue: saved) {
      persistedLean = restored
    } else {
      let choice: BubbleLean = Bool.random() ? .left : .right
      persistedLean = choice
      SharedStore.defaults.set(choice.rawValue, forKey: "bubbleLean")
    }
  }

  private func handleScoreChange(from old: Int, to new: Int) {
    if new < old {
      let knockAmount: CGFloat = directionSign * 18
      withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
        knockOffset = knockAmount
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
          knockOffset = 0
        }
      }
    }
    previousScore = new

    if new >= 100 {
      startGlow()
    } else {
      glowPulse = 0
    }
  }

  private func startGlow() {
    glowPulse = 0
    withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
      glowPulse = 1
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 32) {
      SpiritLevelView(score: 100, recentTrigger: nil)
      SpiritLevelView(score: 75, recentTrigger: "anxious")
      SpiritLevelView(score: 50, recentTrigger: "bored")
      SpiritLevelView(score: 25, recentTrigger: "habit")
      SpiritLevelView(score: 0, recentTrigger: "avoiding")
    }
    .padding(.horizontal, 20)
  }
}
