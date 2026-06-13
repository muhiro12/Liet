import Foundation

/// Processed-image archive use cases called by delivery surfaces.
public enum BatchImageArchiveOperations {
    /// One file that should be stored inside the archive.
    public struct Entry: Equatable, Sendable {
        /// The filename to write inside the archive.
        public let filename: String
        /// The file contents to store for the filename.
        public let data: Data

        /// Creates an archive entry from a filename and file contents.
        public init(
            filename: String,
            data: Data
        ) {
            self.filename = filename
            self.data = data
        }
    }

    /// Errors that can occur while building an archive.
    public enum BuildError: Error, Equatable, Sendable {
        case archiveTooLarge
        case entryTooLarge
        case filenameTooLong
        case tooManyEntries
    }
}

public extension BatchImageArchiveOperations {
    /// Returns ZIP archive data for the provided entries, preserving entry order.
    static func makeArchiveData(
        for entries: [Entry]
    ) throws -> Data {
        try BatchImageArchiveBuilder().makeArchiveData(
            for: entries
        )
    }
}
