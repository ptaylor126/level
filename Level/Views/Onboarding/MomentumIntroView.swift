import SwiftUI

struct MomentumIntroView: View {
  @Binding var hasInteracted: Bool
  @State private var score: Int = 100
  @State private var drained: Bool = false
  @State private var refilled: Bool = false
  @State private var visibleLines: Int = 0

  private let lines: [String] = [
    "Minutes on your blocked apps drain the tank.",
    "Focus sessions refill it.",
    "Find your level. Start each day full."
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("This is your Level.")
        .font(LevelFont.bold(28))
        .foregroundStyle(Color.cream)
        .staged(0.05)

      MomentumTankView(score: score, height: 240)
        .padding(.vertical, 8)
        .staged(0.15)

      Text(promptText)
        .font(.levelCaption)
        .foregroundStyle(Color.cream.opacity(0.55))
        .staged(0.2)

      VStack(spacing: 10) {
        if !drained {
          tapButton(
            title: "Tap here if you scroll when bored",
            systemImage: "arrow.down"
          ) {
            drained = true
            score = 45
          }
          tapButton(
            title: "Tap here if you scroll to avoid work",
            systemImage: "arrow.down"
          ) {
            drained = true
            score = 35
          }
        } else if !refilled {
          tapButton(
            title: "Now lock your apps to fill it back up",
            systemImage: "arrow.up"
          ) {
            refilled = true
            score = 100
            if !hasInteracted {
              revealLines()
            }
          }
        }
      }
      .staged(0.25)

      VStack(alignment: .leading, spacing: 12) {
        ForEach(lines.indices, id: \.self) { index in
          if index < visibleLines {
            Text(lines[index])
              .font(.levelCaption)
              .foregroundStyle(Color.vintageGrape)
              .multilineTextAlignment(.leading)
              .padding(.horizontal, 20)
              .padding(.vertical, 10)
              .background(
                Capsule(style: .continuous)
                  .fill(Color.cream.opacity(0.6))
              )
              .transition(.opacity.combined(with: .move(edge: .bottom)))
          }
        }
      }
      .animation(.spring(response: 0.45, dampingFraction: 0.85), value: visibleLines)
    }
  }

  private var promptText: String {
    if !drained { return "Tap one to see what happens." }
    if !refilled { return "Good. Now fill it back up." }
    return "That's the loop."
  }

  private func tapButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(LevelFont.bold(15))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
        Spacer()
        Image(systemName: systemImage)
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(Color.cream.opacity(0.7))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color.cream.opacity(0.10))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .strokeBorder(Color.cream.opacity(0.28), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }

  private func revealLines() {
    for index in lines.indices {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
        visibleLines = index + 1
        if index == lines.count - 1 {
          hasInteracted = true
        }
      }
    }
  }
}
