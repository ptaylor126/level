import SwiftUI

enum PauseIcon: String {
  case arrowCurve = "icon-arrow-curve"
  case bell = "icon-bell"
  case chart = "icon-chart"
  case flame = "icon-flame"
  case gear = "icon-gear"
  case heart = "icon-heart"
  case lock = "icon-lock"
  case phone = "icon-phone"
}

extension Image {
  init(pauseIcon: PauseIcon) {
    self.init(pauseIcon.rawValue, bundle: .main)
  }
}

struct PauseIconView: View {
  let icon: PauseIcon
  var size: CGFloat = 24
  var color: Color = .vintageGrape

  var body: some View {
    Image(pauseIcon: icon)
      .renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
      .foregroundStyle(color)
  }
}
