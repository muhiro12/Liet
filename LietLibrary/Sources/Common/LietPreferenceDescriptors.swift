import MHPlatformCore

/// Shared preference descriptors backed by the app group's `UserDefaults` suite.
public enum LietPreferenceDescriptors {
    /// Preference descriptors used by the batch-image workflow.
    public enum BatchImage {
        /// Persisted batch-image preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchImagePreferences>(
            storageKey: LietUserDefaultsKeys.AppGroup.batchImagePreferences.rawValue,
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }

    /// Preference descriptors used by the batch background-removal workflow.
    public enum BatchBackgroundRemoval {
        /// Persisted background-removal preference payload.
        public static let preferences = MHCodablePreferenceDescriptor<PersistedBatchBackgroundRemovalPreferences>(
            storageKey: LietUserDefaultsKeys.AppGroup.batchBackgroundRemovalPreferences.rawValue,
            defaultSelection: AppGroup.preferencesDefaultsSelection
        )
    }
}
