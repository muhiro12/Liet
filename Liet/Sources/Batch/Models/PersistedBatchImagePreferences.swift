struct PersistedBatchImagePreferences: Codable, Equatable {
    static let `default`: Self = .init(
        userPresetSettings: nil,
        lastUsedSettings: .default
    )

    var userPresetSettings: PersistedBatchImageSettings?
    var lastUsedSettings: PersistedBatchImageSettings
}
