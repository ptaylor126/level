import FamilyControls
import SwiftUI

struct AppPickerView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let onPickTapped: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Which apps suck you in?")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
          .staged(0.05)
        Text("Pick the ones you're on too much.\nYou can change this later.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.leading)
          .lineSpacing(4)
          .staged(0.18)
      }

      selectionSummary
        .staged(0.3)

      LevelButton(
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
  }

  private var emptyState: some View {
    HStack {
      Text("Nothing picked yet.")
        .font(.levelBody)
        .foregroundStyle(Color.cream.opacity(0.55))
      Spacer()
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.cream.opacity(0.08))
    )
  }

  private var pickedList: some View {
    ZStack(alignment: .topTrailing) {
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
        .font(.levelBody)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .padding(.trailing, 24)
      }
      .frame(maxWidth: .infinity, maxHeight: 180)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.cream)
      )

      CountBadge(count: screenTime.selectedItemCount)
        .offset(x: -12, y: 12)
    }
  }
}

private struct CountBadge: View {
  let count: Int

  var body: some View {
    Text("\(count)")
      .font(LevelFont.bold(14))
      .foregroundStyle(Color.vintageGrape)
      .frame(width: 32, height: 32)
      .background(Circle().fill(Color.teaGreen))
      .contentTransition(.numericText(value: Double(count)))
      .animation(.spring(response: 0.35, dampingFraction: 0.7), value: count)
  }
}
