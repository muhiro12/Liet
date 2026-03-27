import Foundation

/// The prefix template used when generating output filenames.
public enum BatchImageNamingTemplate: String, CaseIterable, Codable, Sendable {
    case img
    case processed
    case custom

    func resolvedPrefix(
        customPrefix: String
    ) -> String? {
        switch self {
        case .img:
            return "IMG"
        case .processed:
            return "processed"
        case .custom:
            let normalizedPrefix = ProcessedImageNaming.normalizedFilenameStem(
                from: customPrefix
            )

            guard !normalizedPrefix.isEmpty else {
                return nil
            }

            return normalizedPrefix
        }
    }
}
