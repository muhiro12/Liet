import MHPlatformCore

/// Shared preference keys backed by the app group's `UserDefaults` suite.
public enum LietPreferenceKeys {
    /// Preference keys used by the batch-image workflow.
    public enum BatchImage {
        /// Persisted batch-image preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchImagePreferences>(
            storageKey: "B7q1N4xP",
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }

    /// Preference keys used by the batch background-removal workflow.
    public enum BatchBackgroundRemoval {
        /// Persisted background-removal preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchBackgroundRemovalPreferences>(
            storageKey: "H3m8R2vK",
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }
}
