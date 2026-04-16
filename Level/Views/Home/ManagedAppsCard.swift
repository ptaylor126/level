import FamilyControls
import SwiftUI

struct ManagedAppsCard: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  var unlocksSubtitle: String? = nil

  var body: some View {
    LevelCard(background: .cream, showBorder: false) {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 2) {
          Text("YOUR APPS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)
          if let unlocksSubtitle {
            Text(unlocksSubtitle)
              .font(.levelCaption)
              .foregroundStyle(Color.mutedGrape)
          }
        }

        if screenTime.selectedItemCount == 0 {
          Text("No apps picked yet. Add some in Settings.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .frame(height: 60)
        } else {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
              ForEach(Array(screenTime.selection.categoryTokens), id: \.self) { token in
                appTile {
                  Label(token).labelStyle(.iconOnly)
                }
              }
              ForEach(Array(screenTime.selection.applicationTokens), id: \.self) { token in
                appTile {
                  Label(token).labelStyle(.iconOnly)
                }
              }
            }
            .environment(\.colorScheme, .light)
          }
        }
      }
    }
  }

  private func appTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color.white)

      content()
        .font(.system(size: 60))
        .scaleEffect(1.6)

      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
    }
    .frame(width: 88, height: 88)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}
