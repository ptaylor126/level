import FamilyControls
import SwiftUI

struct AppPickerView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let onPickTapped: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Which apps suck you in?")
          .font(PauseFont.bold(32))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
          .staged(0.05)
        Text("Pick the ones you're on too much.\nYou can change this later.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.leading)
          .lineSpacing(4)
          .staged(0.18)
      }

      selectionSummary
        .staged(0.3)

      PauseButton(
        title: screenTime.selectedItemCount == 0 ? "Pick apps" : "Change picks",
        style: .ghostOnDark,
        action: onPickTapped
      )
      .staged(0.42)
    }
  }

  private var selectionSummary: some View {
    Group {
      if screenTime.selectedItemCount == 0 {
        emptyState
      } else {
        pickedList
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream.opacity(0.08))
    )
  }

  private var emptyState: some View {
    HStack {
      Text("Nothing picked yet.")
        .font(.pauseBody)
        .foregroundStyle(Color.cream.opacity(0.55))
      Spacer()
    }
    .padding(20)
  }

  private var pickedList: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 12) {
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
      .font(.pauseBody)
      .foregroundStyle(Color.cream)
      .environment(\.colorScheme, .dark)
      .padding(16)
    }
    .frame(maxHeight: 180)
  }
}
