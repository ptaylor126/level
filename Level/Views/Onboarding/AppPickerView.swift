import FamilyControls
import ManagedSettings
import SwiftUI

struct AppPickerView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let onPickTapped: () -> Void

  private let tileSize: CGFloat = 72
  private let columns = [GridItem(.adaptive(minimum: 72, maximum: 80), spacing: 12, alignment: .top)]

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
        pickedGrid
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

  private var pickedGrid: some View {
    ZStack(alignment: .topTrailing) {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
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
      .padding(16)
      .padding(.trailing, 28)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.cream)
      )

      CountBadge(count: screenTime.selectedItemCount)
        .offset(x: -12, y: 12)
    }
  }

  private func appTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.white)
      content()
        .font(.system(size: 48))
        .scaleEffect(1.5)
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
    }
    .frame(width: tileSize, height: tileSize)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
