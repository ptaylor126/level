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
  private var fillFraction: CGFloat {
    let raw = max(0, min(100, displayedScore)) / 100.0
    return CGFloat(raw) * 0.95
  }
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

        glassRim

        if showsScore {
          buoyView(width: w, height: h, fillHeight: fillH)
        }

        ForEach(badges) { badge in
          TankBadgeFloat(badge: badge)
            .position(x: w / 2 + 44, y: buoyCenterY(height: h, fillHeight: fillH))
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
      // Dark inner shadow at top edge (depth)
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(
          LinearGradient(
            stops: [
              .init(color: Color.black.opacity(0.35), location: 0.0),
              .init(color: Color.black.opacity(0.0), location: 0.18)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .blendMode(.multiply)
        .allowsHitTesting(false)

      // Subtle top-down highlight
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(
          LinearGradient(
            stops: [
              .init(color: Color.white.opacity(0.08), location: 0.0),
              .init(color: Color.white.opacity(0.0), location: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .allowsHitTesting(false)

      // Sharp 1px physical rim
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
        .blendMode(.overlay)
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

  // MARK: Buoy

  private static let buoyDiameter: CGFloat = 50
  private static let buoyMargin: CGFloat = 6

  private func buoyBaseY(height h: CGFloat, fillHeight fillH: CGFloat) -> CGFloat {
    let r = Self.buoyDiameter / 2
    let topBound = r + Self.buoyMargin
    let bottomBound = h - r - Self.buoyMargin
    let waterlineY = h - fillH
    return max(topBound, min(bottomBound, waterlineY))
  }

  private func buoyCenterY(height h: CGFloat, fillHeight fillH: CGFloat) -> CGFloat {
    let t = Date().timeIntervalSinceReferenceDate
    let bob = CGFloat(sin(t * 1.9)) * 1.5
    return buoyBaseY(height: h, fillHeight: fillH) + bob
  }

  private func buoyView(width w: CGFloat, height h: CGFloat, fillHeight fillH: CGFloat) -> some View {
    let baseY = buoyBaseY(height: h, fillHeight: fillH)
    let label = "\(clampedScore)"

    return TimelineView(.animation) { timeline in
      let t = timeline.date.timeIntervalSinceReferenceDate
      let bob = CGFloat(sin(t * 1.9)) * 1.5

      ZStack {
        Circle()
          .fill(Color.pastelPink)
          .overlay(
            Circle()
              .fill(
                LinearGradient(
                  colors: [Color.white.opacity(0.35), Color.clear],
                  startPoint: .top,
                  endPoint: .center
                )
              )
          )
          .overlay(
            Circle()
              .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
          )
          .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)

        Text(label)
          .font(LevelFont.extraBold(20))
          .foregroundStyle(Color.vintageGrape)
          .contentTransition(.numericText(value: displayedScore))
      }
      .frame(width: Self.buoyDiameter, height: Self.buoyDiameter)
      .position(x: w / 2, y: baseY + bob)
    }
    .frame(width: w, height: h)
    .animation(.spring(response: 0.9, dampingFraction: 0.85), value: fillH)
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

  private var isPositive: Bool { badge.delta >= 0 }
  private var fill: Color { isPositive ? Color.teaGreen : Color.cream.opacity(0.85) }
  private var textColor: Color { isPositive ? Color.darkGreen : Color.mutedGrape }
  private var label: String { badge.delta > 0 ? "+\(badge.delta)" : "\(badge.delta)" }

  var body: some View {
    Text(label)
      .font(LevelFont.bold(13))
      .foregroundStyle(textColor)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background(
        Capsule(style: .continuous)
          .fill(fill)
          .overlay(
            Capsule(style: .continuous)
              .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
          )
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
      )
      .scaleEffect(appeared ? 1.0 : 0.8)
      .opacity(faded ? 0 : 1)
      .offset(y: lifted ? -44 : 0)
      .onAppear {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
          appeared = true
        }
        withAnimation(.easeOut(duration: 1.1)) {
          lifted = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
          withAnimation(.easeIn(duration: 0.55)) {
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
