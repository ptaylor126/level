import FamilyControls
import SwiftUI

struct AppPickerView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  @State private var isPickerPresented = false
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      VStack(spacing: 12) {
        Text("Choose apps to manage")
          .font(PauseFont.bold(28))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
        Text("Pick the apps and categories that pull you in most. You can change this anytime.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.center)
          .lineSpacing(4)
      }
      .padding(.horizontal, 8)

      selectionSummary

      VStack(spacing: 12) {
        PauseButton(
          title: screenTime.selectedItemCount == 0 ? "Choose apps" : "Update selection",
          style: .ghostOnDark,
          action: { isPickerPresented = true }
        )
        PauseButton(
          title: "Continue",
          style: .primaryOnDark,
          isEnabled: screenTime.selectedItemCount > 0,
          action: onContinue
        )
      }
    }
    .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTime.selection)
    .onChange(of: screenTime.selection) { _, _ in
      screenTime.persistSelection()
    }
  }

  private var selectionSummary: some View {
    VStack(spacing: 4) {
      Text("\(screenTime.selectedItemCount)")
        .font(.pauseDisplay)
        .foregroundStyle(Color.cream)
      Text(screenTime.selectedItemCount == 1 ? "item selected" : "items selected")
        .font(PauseFont.bold(11))
        .tracking(0.5)
        .textCase(.uppercase)
        .foregroundStyle(Color.cream.opacity(0.6))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream.opacity(0.08))
    )
  }
}
