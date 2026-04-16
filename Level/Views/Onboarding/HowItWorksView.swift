import SwiftUI

struct HowShieldWorksView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("How the shield works")
          .font(LevelFont.bold(28))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("When you try to open a blocked app, you'll see your reasons. You get a set number of opens per day — use them wisely.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      ShieldPreviewCard()
        .staged(0.25)
    }
  }
}

private struct ShieldPreviewCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Level with me.")
        .font(LevelFont.bold(20))
        .foregroundStyle(Color.cream)

      VStack(alignment: .leading, spacing: 4) {
        Text("Remember why it's locked:")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.8))
        Text("▸ Read more books")
          .font(.levelBody)
          .foregroundStyle(Color.cream)
      }

      Text("Attempt 1 today.")
        .font(.levelCaption)
        .foregroundStyle(Color.cream.opacity(0.6))

      HStack(spacing: 12) {
        Text("Open anyway")
          .font(LevelFont.bold(14))
          .foregroundStyle(Color.vintageGrape)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.cream)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

        Text("I'm good")
          .font(LevelFont.medium(14))
          .foregroundStyle(Color.cream.opacity(0.6))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.deepGrape)
        .overlay(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(Color.cream.opacity(0.1), lineWidth: 1)
        )
    )
  }
}
