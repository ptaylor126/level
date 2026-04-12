import FamilyControls
import SwiftUI

struct SummaryView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let reasons: [String]
  let onGoBack: () -> Void

  private var filteredReasons: [String] {
    reasons
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 12) {
          Text("Here's your plan.")
            .font(LevelFont.bold(32))
            .foregroundStyle(Color.cream)
            .staged(0.05)
          Text("Make sure this looks right.")
            .font(.levelBody)
            .foregroundStyle(Color.cream.opacity(0.75))
            .staged(0.15)
        }

        appsCard
          .staged(0.25)

        reasonsCard
          .staged(0.35)

        VStack(spacing: 12) {
          Button(action: onGoBack) {
            Text("Go back")
              .font(LevelFont.medium(14))
              .foregroundStyle(Color.cream.opacity(0.6))
          }
          .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .staged(0.45)

        Spacer(minLength: 16)
      }
    }
  }

  private var appsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        LevelIconView(icon: .lock, size: 14, color: .vintageGrape)
        Text("APPS")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)
      }

      VStack(alignment: .leading, spacing: 10) {
        ForEach(Array(screenTime.selection.categoryTokens), id: \.self) { token in
          Label(token)
            .labelStyle(.titleAndIcon)
        }
        ForEach(Array(screenTime.selection.applicationTokens), id: \.self) { token in
          Label(token)
            .labelStyle(.titleAndIcon)
        }
        ForEach(Array(screenTime.selection.webDomainTokens), id: \.self) { token in
          Label(token)
            .labelStyle(.titleAndIcon)
        }
      }
      .font(.levelBody)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream)
    )
  }

  private var reasonsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        LevelIconView(icon: .heart, size: 14, color: .vintageGrape)
        Text("REASONS")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)
      }

      VStack(alignment: .leading, spacing: 10) {
        ForEach(filteredReasons, id: \.self) { reason in
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "heart.fill")
              .font(.system(size: 10))
              .foregroundStyle(Color.rose)
              .padding(.top, 4)
            Text(reason)
              .font(.levelBody)
              .foregroundStyle(Color.vintageGrape)
              .lineSpacing(2)
          }
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream)
    )
  }
}
