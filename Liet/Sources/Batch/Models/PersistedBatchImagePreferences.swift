struct PersistedBatchImagePreferences: Codable, Equatable {
    static let `default`: Self = .init(
        defaultSettings: .default,
        lastUsedSettings: .default
    )

    var defaultSettings: PersistedBatchImageSettings
    var lastUsedSettings: PersistedBatchImageSettings
}
