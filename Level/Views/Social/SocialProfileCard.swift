import SwiftUI

struct SocialProfileCard: View {
  let displayName: String
  let momentum: Int
  let streak: Int
  let xp: Int

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 12) {
        Text("YOUR LEVEL")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.mutedGrape)

        Text(displayName)
          .font(.levelH1)
          .foregroundStyle(Color.vintageGrape)

        Divider()
          .background(Color.warmGrey)

        HStack(spacing: 0) {
          statColumn(value: "\(momentum)", label: "MOMENTUM")
          Divider()
            .frame(height: 40)
            .background(Color.warmGrey)
          statColumn(value: "\(streak)", label: "STREAK")
          Divider()
            .frame(height: 40)
            .background(Color.warmGrey)
          statColumn(value: "\(xp)", label: "XP")
        }
      }
    }
  }

  private func statColumn(value: String, label: String) -> some View {
    VStack(spacing: 4) {
      Text(value)
        .font(LevelFont.extraBold(24))
        .foregroundStyle(Color.vintageGrape)
      Text(label)
        .font(.levelLabel)
        .tracking(0.5)
        .foregroundStyle(Color.mutedGrape)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    SocialProfileCard(displayName: "You", momentum: 72, streak: 5, xp: 340)
      .padding(20)
  }
}
