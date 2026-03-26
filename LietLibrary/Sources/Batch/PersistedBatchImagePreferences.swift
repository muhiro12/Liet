import Foundation

/// Persisted batch preference slots stored by the app.
public struct PersistedBatchImagePreferences: Codable, Equatable, Sendable {
    /// The default stored preferences used on first launch.
    public static let `default`: Self = .init(
        userPresetSettings: nil,
        lastUsedSettings: .default
    )

    /// The optional user-saved preset slot.
    public var userPresetSettings: PersistedBatchImageSettings?
    /// The most recent valid settings used by the app.
    public var lastUsedSettings: PersistedBatchImageSettings

    /// Creates stored batch preferences from persisted slots.
    public init(
        userPresetSettings: PersistedBatchImageSettings?,
        lastUsedSettings: PersistedBatchImageSettings
    ) {
        self.userPresetSettings = userPresetSettings
        self.lastUsedSettings = lastUsedSettings
    }
}
