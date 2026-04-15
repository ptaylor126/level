import FamilyControls
import SwiftUI

struct SummaryView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let reasons: [String]
  let onEditApps: () -> Void
  let onEditReasons: () -> Void

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

        Spacer(minLength: 16)
      }
    }
  }

  private var appsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          LevelIconView(icon: .lock, size: 14, color: .vintageGrape)
          Text("APPS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)
        }
        Spacer()
        Button(action: onEditApps) {
          Text("Edit")
            .font(LevelFont.medium(13))
            .foregroundStyle(Color.rose)
        }
        .buttonStyle(.plain)
      }

      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 64, maximum: 76), spacing: 10, alignment: .top)],
        alignment: .leading,
        spacing: 10
      ) {
        ForEach(Array(screenTime.selection.categoryTokens), id: \.self) { token in
          appTile { Label(token).labelStyle(.iconOnly) }
        }
        ForEach(Array(screenTime.selection.applicationTokens), id: \.self) { token in
          appTile { Label(token).labelStyle(.iconOnly) }
        }
        ForEach(Array(screenTime.selection.webDomainTokens), id: \.self) { token in
          appTile { Label(token).labelStyle(.iconOnly) }
        }
      }
      .environment(\.colorScheme, .light)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream)
    )
  }

  private func appTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color.white)
      content()
        .font(.system(size: 42))
        .scaleEffect(1.5)
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
    }
    .frame(width: 64, height: 64)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
  }

  private var reasonsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          LevelIconView(icon: .heart, size: 14, color: .vintageGrape)
          Text("REASONS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)
        }
        Spacer()
        Button(action: onEditReasons) {
          Text("Edit")
            .font(LevelFont.medium(13))
            .foregroundStyle(Color.rose)
        }
        .buttonStyle(.plain)
      }

      VStack(alignment: .leading, spacing: 10) {
        ForEach(Array(filteredReasons.enumerated()), id: \.offset) { index, reason in
          HStack(alignment: .top, spacing: 10) {
            Text("\(index + 1).")
              .font(LevelFont.bold(15))
              .foregroundStyle(Color.mutedGrape)
              .frame(width: 20, alignment: .trailing)
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
