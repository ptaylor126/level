import SwiftUI

struct ReasonsView: View {
  @Binding var reasons: [String]
  let onContinue: () -> Void

  private let placeholders = [
    "Be more present with my family",
    "Read more books",
    "Sleep better"
  ]

  private var hasAtLeastOne: Bool {
    reasons.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }

  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 12) {
        Text("Why are you doing this?")
          .font(PauseFont.bold(28))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
        Text("Write one to three reasons. You'll see them whenever you reach for a managed app.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.center)
          .lineSpacing(4)
      }
      .padding(.horizontal, 8)

      VStack(spacing: 12) {
        ForEach(0..<3, id: \.self) { index in
          ReasonField(
            text: $reasons[index],
            placeholder: placeholders[index]
          )
        }
      }

      Spacer(minLength: 0)

      PauseButton(
        title: "Continue",
        style: .primaryOnDark,
        isEnabled: hasAtLeastOne,
        action: onContinue
      )
    }
  }
}

private struct ReasonField: View {
  @Binding var text: String
  let placeholder: String

  var body: some View {
    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.cream.opacity(0.35)))
      .font(.pauseBody)
      .foregroundStyle(Color.cream)
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(Color.cream.opacity(0.08))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .strokeBorder(Color.cream.opacity(0.15), lineWidth: 1)
      )
  }
}
