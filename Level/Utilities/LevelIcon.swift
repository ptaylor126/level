import SwiftUI

enum LevelIcon: String {
  case arrowCurve = "icon-arrow-curve"
  case bell = "icon-bell"
  case chart = "icon-chart"
  case diamond = "icon-diamond"
  case flame = "icon-flame"
  case gear = "icon-gear"
  case heart = "icon-heart"
  case lock = "icon-lock"
  case phone = "icon-phone"
}

extension Image {
  init(levelIcon: LevelIcon) {
    self.init(levelIcon.rawValue, bundle: .main)
  }
}

struct LevelIconView: View {
  let icon: LevelIcon
  var size: CGFloat = 24
  var color: Color = .vintageGrape

  var body: some View {
    Image(levelIcon: icon)
      .renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
      .foregroundStyle(color)
  }
}
