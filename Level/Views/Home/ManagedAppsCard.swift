import FamilyControls
import SwiftUI

struct ManagedAppsCard: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let onTapApp: () -> Void

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
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
            HStack(spacing: 12) {
              ForEach(Array(screenTime.selection.categoryTokens), id: \.self) { token in
                Button(action: onTapApp) {
                  VStack(spacing: 6) {
                    Label(token)
                      .labelStyle(.iconOnly)
                      .font(.system(size: 48))
                      .frame(width: 72, height: 72)
                      .background(Color.cream.opacity(0.5))
                      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                  }
                }
                .buttonStyle(.plain)
              }
              ForEach(Array(screenTime.selection.applicationTokens), id: \.self) { token in
                Button(action: onTapApp) {
                  VStack(spacing: 6) {
                    Label(token)
                      .labelStyle(.iconOnly)
                      .font(.system(size: 48))
                      .frame(width: 72, height: 72)
                      .background(Color.cream.opacity(0.5))
                      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                  }
                }
                .buttonStyle(.plain)
              }
            }
            .environment(\.colorScheme, .light)
          }
        }
      }
    }
  }
}
