struct PersistedBatchImagePreferences: Codable, Equatable {
    var defaultSettings: PersistedBatchImageSettings
    var lastUsedSettings: PersistedBatchImageSettings

    static let `default`: Self = .init(
        defaultSettings: .default,
        lastUsedSettings: .default
    )
}
