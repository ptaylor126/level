import SwiftUI

/// Data for a single app category limit row.
struct AppLimitData: Identifiable {
  let id = UUID()
  let categoryName: String
  /// Total daily budget in seconds.
  let budgetSeconds: TimeInterval
  /// Seconds used so far today.
  let usedSeconds: TimeInterval

  var remaining: TimeInterval { max(budgetSeconds - usedSeconds, 0) }
  var fraction: Double {
    guard budgetSeconds > 0 else { return 0 }
    return min(usedSeconds / budgetSeconds, 1)
  }

  var formattedRemaining: String {
    let mins = Int(remaining) / 60
    let hrs = mins / 60
    let m = mins % 60
    if hrs > 0 {
      return "\(hrs)h \(m)m left"
    }
    return "\(m)m left"
  }
}

/// Full-width card showing a progress bar for each managed app category.
struct AppLimitsCard: View {
  var limits: [AppLimitData] = AppLimitsCard.mockLimits

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        // Header
        HStack {
          Text("APP LIMITS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)

          Spacer()

          LevelIconView(icon: .lock, size: 16, color: .mutedGrape)
        }

        if limits.isEmpty {
          Text("No apps managed yet.")
            .font(.levelBody)
            .foregroundStyle(Color.mutedGrape)
        } else {
          VStack(spacing: 14) {
            ForEach(limits) { limit in
              AppLimitRow(limit: limit)
            }
          }
        }
      }
    }
  }

  // MARK: - Mock data
  static var mockLimits: [AppLimitData] = [
    AppLimitData(categoryName: "Social Media",  budgetSeconds: 3600, usedSeconds: 2520),
    AppLimitData(categoryName: "Entertainment", budgetSeconds: 5400, usedSeconds: 1800),
    AppLimitData(categoryName: "Games",         budgetSeconds: 1800, usedSeconds: 900),
  ]
}

// MARK: - AppLimitRow

private struct AppLimitRow: View {
  let limit: AppLimitData
  @State private var animatedFraction: Double = 0

  var body: some View {
    VStack(spacing: 6) {
      // Name + remaining
      HStack {
        Text(limit.categoryName)
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)

        Spacer()

        Text(limit.formattedRemaining)
          .font(.levelCaption)
          .foregroundStyle(Color.mutedGrape)
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(Color.warmGrey)
            .frame(height: 6)
          RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(limit.fraction > 0.85 ? Color.pastelPink : Color.teaGreen)
            .frame(width: geo.size.width * animatedFraction, height: 6)
            .animation(.easeOut(duration: 0.3), value: animatedFraction)
        }
      }
      .frame(height: 6)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
        animatedFraction = limit.fraction
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    AppLimitsCard()
      .padding(20)
  }
}
