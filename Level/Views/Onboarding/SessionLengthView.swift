import SwiftUI

struct SessionLengthView: View {
  @Binding var sessionMinutes: Int

  private let options = [2, 5, 10, 15]

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Session length")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("After you tap 'Open anyway', how long before the shield comes back?")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(spacing: 10) {
        ForEach(options, id: \.self) { minutes in
          Button {
            sessionMinutes = minutes
          } label: {
            HStack {
              Text("\(minutes) min")
                .font(LevelFont.bold(17))
                .foregroundStyle(sessionMinutes == minutes ? Color.vintageGrape : Color.cream)
              Spacer()
              if sessionMinutes == minutes {
                Image(systemName: "checkmark")
                  .font(.system(size: 14, weight: .bold))
                  .foregroundStyle(Color.vintageGrape)
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(sessionMinutes == minutes ? Color.teaGreen : Color.cream.opacity(0.08))
            )
          }
          .buttonStyle(.plain)
        }

        Button {
          sessionMinutes = sessionMinutes == 0 ? 5 : sessionMinutes
        } label: {
          HStack {
            Text("Custom")
              .font(LevelFont.bold(17))
              .foregroundStyle(!options.contains(sessionMinutes) ? Color.vintageGrape : Color.cream)
            Spacer()
            if !options.contains(sessionMinutes) {
              Stepper("", value: $sessionMinutes, in: 1...60, step: 1)
                .labelsHidden()
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(!options.contains(sessionMinutes) ? Color.teaGreen : Color.cream.opacity(0.08))
          )
        }
        .buttonStyle(.plain)
      }
      .staged(0.25)
    }
  }
}
