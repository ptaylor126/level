import SwiftUI

struct SpiritLevelView: View {
  let score: Int

  @State private var bubbleOffset: CGFloat = 0
  @State private var timer: Timer?
  @State private var glowIntensity: Double = 0

  private var tubeHeight: CGFloat { 60 }
  private var bubbleDiameter: CGFloat { 44 }

  private enum Tier {
    case chaos, unsteady, improving, steady, flow

    static func from(_ score: Int) -> Tier {
      switch score {
      case ..<26: return .chaos
      case ..<51: return .unsteady
      case ..<76: return .improving
      case ..<91: return .steady
      default: return .flow
      }
    }

    var maxDrift: CGFloat {
      switch self {
      case .chaos: return 0.8
      case .unsteady: return 0.5
      case .improving: return 0.18
      case .steady: return 0.06
      case .flow: return 0
      }
    }

    var tickInterval: TimeInterval {
      switch self {
      case .chaos: return 0.18
      case .unsteady: return 0.45
      case .improving: return 1.1
      case .steady: return 2.2
      case .flow: return 0
      }
    }

    var springResponse: Double {
      switch self {
      case .chaos: return 0.28
      case .unsteady: return 0.55
      case .improving: return 1.0
      case .steady: return 1.6
      case .flow: return 2.0
      }
    }

    var springDamping: Double {
      switch self {
      case .chaos: return 0.55
      case .unsteady: return 0.75
      case .improving: return 0.9
      case .steady: return 0.95
      case .flow: return 1.0
      }
    }

    var liquidClarity: Double {
      switch self {
      case .chaos: return 0.55
      case .unsteady: return 0.75
      case .improving: return 0.9
      case .steady: return 0.97
      case .flow: return 1.0
      }
    }

    var isFlow: Bool { self == .flow }
  }

  private var tier: Tier { Tier.from(score) }

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width
      let maxOffset = (width / 2) - (bubbleDiameter / 2) - 10

      ZStack {
        if tier.isFlow {
          Capsule()
            .fill(Color.pastelPink)
            .blur(radius: 28)
            .opacity(0.4 + glowIntensity * 0.4)
            .frame(width: width + 80, height: tubeHeight + 80)
        }

        tubeBase
          .frame(width: width, height: tubeHeight)

        liquidFill
          .frame(width: width - 4, height: tubeHeight - 4)

        tubeGloss
          .frame(width: width - 4, height: tubeHeight - 4)

        centerMarkers
          .frame(width: width - 40, height: tubeHeight - 20)

        bubble
          .offset(x: bubbleOffset * maxOffset)

        tubeRim
          .frame(width: width, height: tubeHeight)
      }
      .frame(width: width, height: tubeHeight)
    }
    .frame(height: tubeHeight)
    .onAppear(perform: startAnimation)
    .onDisappear {
      timer?.invalidate()
      timer = nil
    }
    .onChange(of: score) { _, _ in
      restartAnimation()
    }
  }

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
    let clarity = tier.liquidClarity
    return Capsule()
      .fill(
        LinearGradient(
          stops: [
            .init(color: Color.teaGreen.opacity(0.6 + 0.35 * clarity), location: 0.0),
            .init(color: Color.teaGreen.opacity(0.85 + 0.1 * clarity), location: 0.35),
            .init(color: Color.darkGreen.opacity(0.25 + 0.15 * clarity), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay(
        Capsule()
          .fill(
            LinearGradient(
              colors: [
                Color.mutedGrape.opacity((1 - clarity) * 0.25),
                Color.clear
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
  }

  private var tubeGloss: some View {
    Capsule()
      .fill(
        LinearGradient(
          stops: [
            .init(color: Color.white.opacity(0.45), location: 0.0),
            .init(color: Color.white.opacity(0.15), location: 0.2),
            .init(color: Color.white.opacity(0.0), location: 0.5),
            .init(color: Color.white.opacity(0.0), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .mask(
        Capsule()
          .fill(Color.white)
      )
  }

  private var tubeRim: some View {
    Capsule()
      .strokeBorder(
        LinearGradient(
          colors: [
            Color.cream.opacity(0.3),
            Color.darkGreen.opacity(0.35)
          ],
          startPoint: .top,
          endPoint: .bottom
        ),
        lineWidth: 1.5
      )
  }

  private var centerMarkers: some View {
    HStack {
      Spacer()
      Rectangle()
        .fill(Color.darkGreen.opacity(0.18))
        .frame(width: 1)
      Spacer().frame(width: 24)
      Rectangle()
        .fill(Color.darkGreen.opacity(0.18))
        .frame(width: 1)
      Spacer()
    }
  }

  private var bubble: some View {
    ZStack {
      Circle()
        .fill(Color.deepGrape.opacity(0.25))
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
    .shadow(color: tier.isFlow ? Color.pastelPink.opacity(0.6) : .clear, radius: 18)
  }

  // MARK: - Animation

  private func startAnimation() {
    if tier.isFlow {
      withAnimation(.easeInOut(duration: 0.8)) {
        bubbleOffset = 0
      }
      withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
        glowIntensity = 1
      }
      return
    }

    scheduleTick()
  }

  private func restartAnimation() {
    timer?.invalidate()
    timer = nil
    glowIntensity = 0
    if tier.isFlow {
      withAnimation(.spring(response: 1.5, dampingFraction: 0.9)) {
        bubbleOffset = 0
      }
      withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
        glowIntensity = 1
      }
    } else {
      scheduleTick()
    }
  }

  private func scheduleTick() {
    let currentTier = tier
    timer = Timer.scheduledTimer(withTimeInterval: currentTier.tickInterval, repeats: true) { _ in
      let newOffset = CGFloat.random(in: -currentTier.maxDrift...currentTier.maxDrift)
      withAnimation(.spring(
        response: currentTier.springResponse,
        dampingFraction: currentTier.springDamping
      )) {
        bubbleOffset = newOffset
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 40) {
      SpiritLevelView(score: 15)
      SpiritLevelView(score: 45)
      SpiritLevelView(score: 65)
      SpiritLevelView(score: 85)
      SpiritLevelView(score: 100)
    }
    .padding(.horizontal, 20)
  }
}
