import SwiftUI

struct TriggerPromptView: View {
  let onSelect: (String) -> Void
  let onDismiss: () -> Void

  private let triggers = [
    "Bored",
    "Anxious",
    "Avoiding something",
    "Habit",
    "Just checking"
  ]

  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Text("What were you looking for?")
          .font(.levelH2)
          .foregroundStyle(Color.cream)
        Spacer()
        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.cream.opacity(0.6))
        }
        .buttonStyle(.plain)
      }

      FlowLayout(spacing: 10) {
        ForEach(triggers, id: \.self) { trigger in
          Button {
            onSelect(trigger.lowercased())
          } label: {
            Text(trigger)
              .font(LevelFont.medium(14))
              .foregroundStyle(Color.vintageGrape)
              .padding(.horizontal, 16)
              .padding(.vertical, 10)
              .background(
                Capsule().fill(Color.cream)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.deepGrape)
    )
    .padding(.horizontal, 20)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}

struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let result = layout(proposal: proposal, subviews: subviews)
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = layout(proposal: proposal, subviews: subviews)
    for (index, position) in result.positions.enumerated() {
      subviews[index].place(
        at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
        proposal: .unspecified
      )
    }
  }

  private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
    let maxWidth = proposal.width ?? .infinity
    var positions: [CGPoint] = []
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x + size.width > maxWidth && x > 0 {
        x = 0
        y += rowHeight + spacing
        rowHeight = 0
      }
      positions.append(CGPoint(x: x, y: y))
      rowHeight = max(rowHeight, size.height)
      x += size.width + spacing
    }

    return (CGSize(width: maxWidth, height: y + rowHeight), positions)
  }
}
