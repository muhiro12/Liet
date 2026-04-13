import MHPlatformCore

/// Shared preference descriptors backed by the app group's `UserDefaults` suite.
public enum LietPreferenceDescriptors {
    /// Preference descriptors used by the batch-image workflow.
    public enum BatchImage {
        /// Persisted batch-image preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchImagePreferences>(
            storageKey: "B7q1N4xP",
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }

    /// Preference descriptors used by the batch background-removal workflow.
    public enum BatchBackgroundRemoval {
        /// Persisted background-removal preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchBackgroundRemovalPreferences>(
            storageKey: "H3m8R2vK",
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }
}
