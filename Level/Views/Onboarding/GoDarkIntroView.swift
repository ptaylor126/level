import SwiftUI

struct GoDarkIntroView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Go Dark to recharge")
          .font(LevelFont.bold(28))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("Lock your apps for a focus session. The longer you go, the more your tank fills back up.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      GoDarkPreviewCard()
        .staged(0.25)
    }
  }
}

private struct GoDarkPreviewCard: View {
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "moon.fill")
          .font(.system(size: 16, weight: .semibold))
        Text("Go Dark")
          .font(LevelFont.bold(17))
      }
      .foregroundStyle(Color.vintageGrape)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(Color.teaGreen)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

      VStack(alignment: .leading, spacing: 8) {
        Label("Every minute earns XP", systemImage: "diamond.fill")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.8))
        Label("Recharges your momentum tank", systemImage: "arrow.up.circle.fill")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.8))
        Label("End early and you'll lose 20 XP", systemImage: "exclamationmark.triangle.fill")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.6))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
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
