import Foundation

public extension BatchImagePreferencesState {
    /// Updates the selected naming template.
    mutating func setNamingTemplate(
        _ newValue: BatchImageNamingTemplate
    ) {
        guard namingTemplate != newValue else {
            return
        }

        namingTemplate = newValue
        settingsSource = .custom
    }

    /// Updates the editable custom prefix text.
    mutating func setCustomNamingPrefixText(
        _ newValue: String
    ) {
        customNamingPrefixText = newValue
        settingsSource = .custom
    }

    /// Updates the selected numbering style.
    mutating func setNamingNumberingStyle(
        _ newValue: BatchImageNumberingStyle
    ) {
        guard numberingStyle != newValue else {
            return
        }

        numberingStyle = newValue
        settingsSource = .custom
    }
}
