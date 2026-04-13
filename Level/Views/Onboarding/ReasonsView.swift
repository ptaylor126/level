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

  private var availableSuggestions: [String] {
    let trimmedReasons = Set(reasons.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
    return Self.suggestions.filter { !trimmedReasons.contains($0.lowercased()) }
  }

  private let placeholders = [
    "Be more present with my family",
    "Read more books",
    "Sleep better",
    "Get more work done",
    "Stop doomscrolling before bed"
  ]

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 12) {
          Text("Why bother?")
            .font(LevelFont.bold(32))
            .foregroundStyle(Color.cream)
            .multilineTextAlignment(.leading)
            .staged(0.05)
          Text("Add as many as you want, or skip this. We'll show you one every time you try to open an app.")
            .font(.levelBody)
            .foregroundStyle(Color.cream.opacity(0.75))
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .staged(0.18)
        }

        if !availableSuggestions.isEmpty {
          suggestionStrip
            .staged(0.28)
        }

        VStack(spacing: 10) {
          ForEach(reasons.indices, id: \.self) { index in
            ReasonField(
              text: $reasons[index],
              placeholder: placeholders[index % placeholders.count],
              canRemove: reasons.count > 1,
              onRemove: { removeReason(at: index) }
            )
            .focused($focusedIndex, equals: index)
          }

          Button(action: addReason) {
            HStack(spacing: 8) {
              Image(systemName: "plus")
                .font(LevelFont.bold(14))
              Text("Add another")
                .font(LevelFont.bold(14))
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
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          }
          .buttonStyle(.plain)
        }

        Spacer(minLength: 20)
      }
    }
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
    guard reasons.indices.contains(index), reasons.count > 1 else { return }
    withAnimation(.easeInOut(duration: 0.2)) {
      reasons.remove(at: index)
    }
  }

  private func applySuggestion(_ suggestion: String) {
    focusedIndex = nil
    if let emptyIndex = reasons.firstIndex(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
      withAnimation(.easeInOut(duration: 0.2)) {
        reasons[emptyIndex] = suggestion
      }
    } else {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
        reasons.append(suggestion)
      }
    }
  }

  private var suggestionStrip: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(availableSuggestions, id: \.self) { suggestion in
          Button {
            applySuggestion(suggestion)
          } label: {
            Text(suggestion)
              .font(LevelFont.medium(13))
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
        .font(.levelBody)
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
