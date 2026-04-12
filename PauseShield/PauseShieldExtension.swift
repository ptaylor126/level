import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

final class PauseShieldExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    ShieldConfiguration(
      backgroundBlurStyle: .systemMaterialDark,
      backgroundColor: UIColor(red: 0x47 / 255, green: 0x31 / 255, blue: 0x44 / 255, alpha: 1),
      icon: nil,
      title: ShieldConfiguration.Label(text: "Pause", color: .white),
      subtitle: ShieldConfiguration.Label(
        text: "Take a breath before opening.",
        color: UIColor(white: 1, alpha: 0.85)
      ),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: .white),
      primaryButtonBackgroundColor: .clear,
      secondaryButtonLabel: nil
    )
  }

  override func configuration(
    shielding application: Application,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    configuration(shielding: application)
  }
}
