import SwiftUI

enum PauseButtonStyle {
  case primaryOnDark
  case primaryOnLight
  case ghostOnDark
  case ghostOnLight
}

struct PauseButton: View {
  let title: String
  var style: PauseButtonStyle = .primaryOnDark
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(PauseFont.bold(15))
        .frame(maxWidth: .infinity, minHeight: 48)
        .foregroundStyle(foreground)
        .background(background)
        .overlay(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(borderColor, lineWidth: borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(isEnabled ? 1 : 0.4)
    }
    .buttonStyle(.plain)
    .disabled(!isEnabled)
  }

  private var foreground: Color {
    switch style {
    case .primaryOnDark: return .vintageGrape
    case .primaryOnLight: return .cream
    case .ghostOnDark: return .cream
    case .ghostOnLight: return .vintageGrape
    }
  }

  private var background: Color {
    switch style {
    case .primaryOnDark: return .teaGreen
    case .primaryOnLight: return .vintageGrape
    case .ghostOnDark, .ghostOnLight: return .clear
    }
  }

  private var borderColor: Color {
    switch style {
    case .primaryOnDark, .primaryOnLight: return .clear
    case .ghostOnDark: return .cream
    case .ghostOnLight: return .vintageGrape
    }
  }

  private var borderWidth: CGFloat {
    switch style {
    case .primaryOnDark, .primaryOnLight: return 0
    case .ghostOnDark, .ghostOnLight: return 1
    }
  }
}
