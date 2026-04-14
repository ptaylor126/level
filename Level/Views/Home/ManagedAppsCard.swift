import FamilyControls
import SwiftUI

struct ManagedAppsCard: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let onTapApp: () -> Void

  var body: some View {
    LevelCard(background: .cream, showBorder: false) {
      VStack(alignment: .leading, spacing: 14) {
        Text("YOUR APPS")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)

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
    Button(action: onTapApp) {
      content()
        .font(.system(size: 56))
        .frame(width: 72, height: 72)
        .background(
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.5))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }
}
