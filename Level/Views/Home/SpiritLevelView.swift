import SwiftUI
#if canImport(CoreMotion)
import CoreMotion
#endif

// MARK: - Tilt (CoreMotion)

@MainActor
final class TiltMotionManager: ObservableObject {
  @Published var roll: Double = 0
  #if canImport(CoreMotion) && !os(macOS)
  private let manager = CMMotionManager()
  #endif
  private var isActive = false

  func start() {
    #if canImport(CoreMotion) && !os(macOS)
    guard !isActive, manager.isDeviceMotionAvailable else { return }
    isActive = true
    manager.deviceMotionUpdateInterval = 1.0 / 30.0
    manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let self, let motion else { return }
      withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
        self.roll = motion.attitude.roll
      }
    }
    #endif
  }

  func stop() {
    guard isActive else { return }
    #if canImport(CoreMotion) && !os(macOS)
    manager.stopDeviceMotionUpdates()
    #endif
    isActive = false
    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
      roll = 0
    }
  }

  deinit {
    #if canImport(CoreMotion) && !os(macOS)
    manager.stopDeviceMotionUpdates()
    #endif
  }
}

// MARK: - Wave

struct WaveShape: Shape {
  var phase: Double
  var amplitude: CGFloat
  var frequency: CGFloat

  var animatableData: Double {
    get { phase }
    set { phase = newValue }
  }

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let baseY: CGFloat = amplitude
    let step: CGFloat = 3
    p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    p.addLine(to: CGPoint(x: rect.minX, y: baseY))
    var x: CGFloat = rect.minX
    while x <= rect.maxX {
      let rel = rect.width > 0 ? x / rect.width : 0
      let angle = Double(rel) * .pi * 2 * Double(frequency) + phase
      let y = baseY + CGFloat(sin(angle)) * amplitude
      p.addLine(to: CGPoint(x: x, y: y))
      x += step
    }
    p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    p.closeSubpath()
    return p
  }
}

// MARK: - Badge event

struct TankBadgeEvent: Identifiable, Equatable {
  let id = UUID()
  let delta: Int
}

// MARK: - Momentum Tank

struct MomentumTankView: View {
  let score: Int
  var height: CGFloat = 340
  var showsScore: Bool = true

  @StateObject private var tilt = TiltMotionManager()
  @State private var displayedScore: Double = 0
  @State private var turbulence: Double = 0
  @State private var previousScore: Int? = nil
  @State private var badges: [TankBadgeEvent] = []
  @Environment(\.scenePhase) private var scenePhase

  private var clampedScore: Int { max(0, min(100, Int(displayedScore.rounded()))) }
  private var fillFraction: CGFloat { CGFloat(max(0, min(100, displayedScore)) / 100.0) }
  private var tiltDegrees: Double {
    let clamped = max(-1.0, min(1.0, tilt.roll / 0.6))
    return clamped * 8.0
  }

  var body: some View {
    GeometryReader { geo in
      let w = geo.size.width
      let h = geo.size.height
      let fillH = h * fillFraction

      ZStack {
        tankBackground

        liquidLayer(width: w, height: h, fillHeight: fillH)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

        if showsScore {
          scoreText(width: w, height: h, fillHeight: fillH)
        }

        glassRim

        ForEach(badges) { badge in
          TankBadgeFloat(badge: badge)
            .position(x: w / 2, y: max(24, h - fillH))
        }
      }
      .frame(width: w, height: h)
    }
    .frame(height: height)
    .onAppear {
      displayedScore = Double(score)
      previousScore = score
      tilt.start()
    }
    .onDisappear { tilt.stop() }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { tilt.start() } else { tilt.stop() }
    }
    .onChange(of: score) { _, new in
      handleScoreChange(to: new)
    }
  }

  // MARK: Background / glass

  private var tankBackground: some View {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
      .fill(
        LinearGradient(
          colors: [
            Color.deepGrape,
            Color.vintageGrape
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(
            LinearGradient(
              colors: [Color.white.opacity(0.06), Color.clear],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
  }

  private var glassRim: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(
          LinearGradient(
            stops: [
              .init(color: Color.white.opacity(0.12), location: 0.0),
              .init(color: Color.white.opacity(0.0), location: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .allowsHitTesting(false)
    }
  }

  // MARK: Liquid

  private func liquidLayer(width w: CGFloat, height h: CGFloat, fillHeight fillH: CGFloat) -> some View {
    let amp: CGFloat = 6 + CGFloat(turbulence) * 14
    let waveBand: CGFloat = amp * 2 + 2
    let liquidHeight = fillH + waveBand
    // Position: the band should straddle the waterline (top of the liquid)
    // Liquid container is wider than tank to hide tilt edges
    let overshoot: CGFloat = 60
    let containerWidth = w + overshoot * 2

    return TimelineView(.animation) { timeline in
      let t = timeline.date.timeIntervalSinceReferenceDate
      let phaseBack = t * 1.3
      let phaseFront = t * 1.9

      ZStack(alignment: .top) {
        // Back translucent wave
        WaveShape(phase: phaseBack, amplitude: amp * 0.7, frequency: 1.8)
          .fill(Color.teaGreen.opacity(0.45))
          .frame(width: containerWidth, height: liquidHeight)

        // Front solid wave
        WaveShape(phase: phaseFront, amplitude: amp, frequency: 1.4)
          .fill(
            LinearGradient(
              colors: [Color.teaGreen, Color.teaGreen.opacity(0.85)],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .frame(width: containerWidth, height: liquidHeight)

        // Surface highlight line
        WaveShape(phase: phaseFront, amplitude: amp, frequency: 1.4)
          .stroke(Color.white.opacity(0.25), lineWidth: 1)
          .frame(width: containerWidth, height: liquidHeight)
      }
      .frame(width: containerWidth, height: liquidHeight, alignment: .top)
      .rotationEffect(.degrees(tiltDegrees), anchor: .center)
      .frame(width: w, height: h, alignment: .bottom)
      .offset(y: (h - fillH - amp).clamped(max: h))
    }
  }

  // MARK: Score text (split at waterline)

  private func scoreText(width w: CGFloat, height h: CGFloat, fillHeight fillH: CGFloat) -> some View {
    let label = "\(clampedScore)"
    return ZStack {
      Text(label)
        .font(LevelFont.extraBold(96))
        .foregroundStyle(Color.mutedGrape.opacity(0.55))
        .contentTransition(.numericText(value: displayedScore))

      Text(label)
        .font(LevelFont.extraBold(96))
        .foregroundStyle(Color.cream)
        .contentTransition(.numericText(value: displayedScore))
        .mask(alignment: .bottom) {
          Rectangle()
            .frame(height: fillH)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    .frame(width: w, height: h)
  }

  // MARK: Animation handling

  private func handleScoreChange(to new: Int) {
    let old = previousScore ?? Int(displayedScore.rounded())
    let delta = new - old
    previousScore = new

    if delta == 0 { return }

    if delta < 0 {
      // turbulent drop
      withAnimation(.easeIn(duration: 0.15)) {
        turbulence = 1.0
      }
      withAnimation(.spring(response: 0.9, dampingFraction: 0.55)) {
        displayedScore = Double(new)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
        withAnimation(.easeOut(duration: 0.8)) {
          turbulence = 0
        }
      }
    } else {
      withAnimation(.spring(response: 1.1, dampingFraction: 0.85)) {
        displayedScore = Double(new)
      }
      #if os(iOS)
      if #available(iOS 17.0, *) {
        // haptic via sensoryFeedback attached elsewhere; UIImpactFeedbackGenerator fallback
      }
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
      #endif
    }

    let event = TankBadgeEvent(delta: delta)
    badges.append(event)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
      badges.removeAll { $0.id == event.id }
    }
  }
}

// MARK: - Badge float

private struct TankBadgeFloat: View {
  let badge: TankBadgeEvent
  @State private var appeared = false
  @State private var lifted = false
  @State private var faded = false

  var body: some View {
    FloatingBadge(delta: badge.delta)
      .scaleEffect(appeared ? 1.0 : 0.8)
      .opacity(faded ? 0 : 1)
      .offset(y: lifted ? -80 : 0)
      .onAppear {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
          appeared = true
        }
        withAnimation(.easeOut(duration: 1.3)) {
          lifted = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          withAnimation(.easeIn(duration: 0.6)) {
            faded = true
          }
        }
      }
  }
}

private extension CGFloat {
  func clamped(max upper: CGFloat) -> CGFloat {
    Swift.min(self, upper)
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack {
      MomentumTankView(score: 68)
        .padding(20)
    }
  }
}
