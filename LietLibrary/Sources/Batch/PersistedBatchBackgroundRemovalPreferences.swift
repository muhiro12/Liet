import Foundation

// swiftlint:disable type_name
/// Persisted background-removal preference slots stored by the app.
public struct PersistedBatchBackgroundRemovalPreferences: Codable, Equatable, Sendable {
    /// The default stored preferences used on first launch.
    public static let `default`: Self = .init(
        userPresetSettings: nil,
        lastUsedSettings: .default
    )

    /// The optional user-saved preset slot.
    public var userPresetSettings: PersistedBatchBackgroundRemovalSettings?
    /// The most recent valid settings used by the app.
    public var lastUsedSettings: PersistedBatchBackgroundRemovalSettings

    /// Creates stored preferences from persisted slots.
    public init(
        userPresetSettings: PersistedBatchBackgroundRemovalSettings?,
        lastUsedSettings: PersistedBatchBackgroundRemovalSettings
    ) {
        self.userPresetSettings = userPresetSettings
        self.lastUsedSettings = lastUsedSettings
    }
}
// swiftlint:enable type_name
