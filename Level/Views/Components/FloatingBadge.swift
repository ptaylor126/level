import SwiftUI

struct ShieldShape: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let w = rect.width
    let h = rect.height
    let r: CGFloat = min(w, h) * 0.25

    p.move(to: CGPoint(x: r, y: 0))
    p.addLine(to: CGPoint(x: w - r, y: 0))
    p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
    p.addLine(to: CGPoint(x: w, y: h * 0.55))
    p.addQuadCurve(to: CGPoint(x: w / 2, y: h), control: CGPoint(x: w, y: h))
    p.addQuadCurve(to: CGPoint(x: 0, y: h * 0.55), control: CGPoint(x: 0, y: h))
    p.addLine(to: CGPoint(x: 0, y: r))
    p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
    p.closeSubpath()
    return p
  }
}

struct FloatingBadge: View {
  let delta: Int
  var size: CGFloat = 42

  private var isPositive: Bool { delta >= 0 }
  private var fill: Color { isPositive ? Color.teaGreen : Color.cream.opacity(0.75) }
  private var textColor: Color { isPositive ? Color.darkGreen : Color.mutedGrape }

  var body: some View {
    ZStack {
      ShieldShape()
        .fill(fill)
        .overlay(
          ShieldShape()
            .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
      Text(delta > 0 ? "+\(delta)" : "\(delta)")
        .font(LevelFont.bold(15))
        .foregroundStyle(textColor)
    }
    .frame(width: size, height: size * 1.1)
  }
}
