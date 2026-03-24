import Foundation

enum PersistedBatchResizeMode: String, Codable, Equatable {
    case aspectRatioPreserved = "aspect_ratio_preserved"
    case exactSize = "exact_size"
}
