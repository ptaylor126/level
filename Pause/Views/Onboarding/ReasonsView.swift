import SwiftUI

struct ReasonsView: View {
  @Binding var reasons: [String]
  @FocusState private var focusedIndex: Int?

  private static let suggestions: [String] = [
    "Sleep better",
    "Be present with family",
    "Focus at work",
    "Read more books",
    "Stop doomscrolling",
    "Reduce anxiety",
    "Exercise more",
    "Have real conversations",
    "Stop comparing myself",
    "Learn something new",
    "Get outside more",
    "Improve attention span"
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Why bother?")
          .font(PauseFont.bold(32))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
          .staged(0.05)
        Text("Write as many as you want. You'll see one every time you try to open an app.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.leading)
          .lineSpacing(4)
          .staged(0.18)
      }

      suggestionStrip
        .staged(0.28)

      VStack(spacing: 10) {
        ForEach(reasons.indices, id: \.self) { index in
          ReasonField(
            text: $reasons[index],
            placeholder: placeholder(for: index),
            canRemove: reasons.count > 1,
            onRemove: { removeReason(at: index) }
          )
          .focused($focusedIndex, equals: index)
          .staged(0.32 + Double(min(index, 3)) * 0.06)
        }

        if reasons.count < 10 {
          Button(action: addReason) {
            HStack(spacing: 8) {
              Image(systemName: "plus")
                .font(PauseFont.bold(14))
              Text("Add another")
                .font(PauseFont.bold(14))
            }
            .foregroundStyle(Color.cream.opacity(0.7))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                  Color.cream.opacity(0.25),
                  style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
            )
          }
          .buttonStyle(.plain)
          .staged(0.5)
        }
      }
    }
  }

  private func placeholder(for index: Int) -> String {
    let defaults = [
      "Read more books",
      "Stop scrolling in bed",
      "Actually get work done",
      "Sleep better",
      "Focus at work"
    ]
    return defaults[index % defaults.count]
  }

  private func addReason() {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
      reasons.append("")
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      focusedIndex = reasons.count - 1
    }
  }

  private func removeReason(at index: Int) {
    guard reasons.indices.contains(index) else { return }
    withAnimation(.easeInOut(duration: 0.2)) {
      reasons.remove(at: index)
    }
  }

  private func applySuggestion(_ suggestion: String) {
    if let emptyIndex = reasons.firstIndex(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
      reasons[emptyIndex] = suggestion
      focusedIndex = emptyIndex
    } else {
      reasons.append(suggestion)
      focusedIndex = reasons.count - 1
    }
  }

  private var suggestionStrip: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(Self.suggestions, id: \.self) { suggestion in
          Button {
            applySuggestion(suggestion)
          } label: {
            Text(suggestion)
              .font(PauseFont.medium(13))
              .foregroundStyle(Color.cream.opacity(0.9))
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(
                Capsule().fill(Color.cream.opacity(0.1))
              )
              .overlay(
                Capsule().strokeBorder(Color.cream.opacity(0.2), lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 1)
    }
  }
}

private struct ReasonField: View {
  @Binding var text: String
  let placeholder: String
  let canRemove: Bool
  let onRemove: () -> Void
  @FocusState private var focused: Bool

  var body: some View {
    HStack(spacing: 8) {
      TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.cream.opacity(0.35)))
        .font(.pauseBody)
        .foregroundStyle(Color.cream)
        .focused($focused)
      if canRemove && !text.isEmpty {
        Button(action: onRemove) {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 18))
            .foregroundStyle(Color.cream.opacity(0.45))
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Color.cream.opacity(focused ? 0.12 : 0.08))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .strokeBorder(Color.cream.opacity(focused ? 0.35 : 0.15), lineWidth: 1)
    )
    .animation(.easeInOut(duration: 0.2), value: focused)
    .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
  }
}
