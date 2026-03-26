import Foundation

/// The persisted source currently driving the batch settings UI.
public enum BatchImageSettingsSource: String, CaseIterable, Codable, Equatable, Sendable {
    /// The last-used settings restored from persistence.
    case lastUsed = "last_used"
    /// The user-saved preset slot.
    case userPreset = "user_preset"
    /// A custom in-session edit that no longer matches a saved source.
    case custom
}
