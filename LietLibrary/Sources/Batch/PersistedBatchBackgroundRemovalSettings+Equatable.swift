import Foundation

public extension PersistedBatchBackgroundRemovalSettings {
    /// Compares settings by their semantic field values.
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.strength == rhs.strength &&
            lhs.edgeSmoothing == rhs.edgeSmoothing &&
            lhs.edgeExpansion == rhs.edgeExpansion &&
            lhs.naming == rhs.naming
    }
}
