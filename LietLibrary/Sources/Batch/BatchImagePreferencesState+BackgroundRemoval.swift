import Foundation

public extension BatchImagePreferencesState {
    /// Enables or disables background removal.
    mutating func setBackgroundRemovalEnabled(
        _ newValue: Bool
    ) {
        guard backgroundRemoval.isEnabled != newValue else {
            return
        }

        backgroundRemoval.isEnabled = newValue
        settingsSource = .custom
    }

    /// Updates the background-removal strength.
    mutating func setBackgroundRemovalStrength(
        _ newValue: Double
    ) {
        guard backgroundRemoval.strength != newValue else {
            return
        }

        backgroundRemoval.strength = newValue
        settingsSource = .custom
    }

    /// Updates the background-removal edge smoothing.
    mutating func setBackgroundRemovalEdgeSmoothing(
        _ newValue: Double
    ) {
        guard backgroundRemoval.edgeSmoothing != newValue else {
            return
        }

        backgroundRemoval.edgeSmoothing = newValue
        settingsSource = .custom
    }

    /// Updates the background-removal edge expansion.
    mutating func setBackgroundRemovalEdgeExpansion(
        _ newValue: Double
    ) {
        guard backgroundRemoval.edgeExpansion != newValue else {
            return
        }

        backgroundRemoval.edgeExpansion = newValue
        settingsSource = .custom
    }
}
