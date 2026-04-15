import SwiftUI

struct HowItWorksView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Everything goes through Level")
          .font(LevelFont.bold(28))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("When you want to open a blocked app.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(alignment: .leading, spacing: 16) {
        PrimaryCard()
          .staged(0.25)

        Text("Or go straight there — try opening the app and you'll be redirected to Level.")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.55))
          .lineSpacing(3)
          .padding(.horizontal, 4)
          .staged(0.35)
      }
    }
  }
}

private struct PrimaryCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Open Level first")
        .font(LevelFont.bold(18))
        .foregroundStyle(Color.vintageGrape)
      Text("Tap the app from your list. You earn more XP this way.")
        .font(.levelBody)
        .foregroundStyle(Color.vintageGrape.opacity(0.75))
        .lineSpacing(2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.teaGreen)
    )
  }
}
