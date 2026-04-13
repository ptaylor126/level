import SwiftUI

struct MomentumCard: View {
  var score: Int = 74
  var streak: Int = 9
  var lastStreakBroken: Int? = nil
  @State private var displayedScore: Int = 0

  var body: some View {
    LevelCard(background: .pastelPink) {
      VStack(alignment: .leading, spacing: 0) {
        Text("MOMENTUM")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.rose)

        Spacer(minLength: 12)

        Text("\(displayedScore)")
          .font(.levelDisplay)
          .foregroundStyle(Color.darkGreen)
          .contentTransition(.numericText(value: Double(displayedScore)))
          .padding(.horizontal, 14)
          .padding(.vertical, 6)
          .background(Color.teaGreen)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

        Spacer(minLength: 12)

        if streak > 0 {
          HStack(spacing: 4) {
            LevelIconView(icon: .flame, size: 14, color: .rose)
            Text(streak == 1 ? "1 day streak" : "\(streak) day streak")
              .font(.levelCaption)
              .foregroundStyle(Color.rose)
          }
        } else if let broken = lastStreakBroken, broken > 2 {
          Text("\(broken) days. Nice run.")
            .font(.levelCaption)
            .foregroundStyle(Color.rose)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
        displayedScore = score
      }
    }
    .onChange(of: score) { _, newValue in
      withAnimation(.easeOut(duration: 0.5)) {
        displayedScore = newValue
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    HStack(spacing: 12) {
      MomentumCard(score: 74, streak: 9)
      MomentumCard(score: 45, streak: 0, lastStreakBroken: 12)
    }
    .padding(20)
  }
}
