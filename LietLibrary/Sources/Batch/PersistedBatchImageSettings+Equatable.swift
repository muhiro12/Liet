import Foundation

public extension PersistedBatchImageSettings {
    /// Compares settings by their semantic field values.
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.resizeMode == rhs.resizeMode &&
            lhs.referenceDimension == rhs.referenceDimension &&
            lhs.referencePixels == rhs.referencePixels &&
            lhs.exactWidthPixels == rhs.exactWidthPixels &&
            lhs.exactHeightPixels == rhs.exactHeightPixels &&
            lhs.exactResizeStrategy == rhs.exactResizeStrategy &&
            lhs.compression == rhs.compression &&
            lhs.backgroundRemoval == rhs.backgroundRemoval
    }
}
