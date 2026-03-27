import Foundation

/// Builds a simple ZIP archive for processed batch-image exports.
public struct BatchImageArchiveBuilder: Sendable {
    private enum ZIPFormat {
        static let bitsPerByte = 8
        static let centralDirectoryHeaderSignature: UInt32 = 0x02014B50
        static let compressionMethodStore: UInt16 = 0
        static let crcLeastSignificantBitMask: UInt32 = 1
        static let crcPolynomial: UInt32 = 0xEDB88320
        static let endOfCentralDirectorySignature: UInt32 = 0x06054B50
        static let headerVersion: UInt16 = 20
        static let localFileHeaderSignature: UInt32 = 0x04034B50
        static let maximumEntryCount = Int(UInt16.max)
        static let maximumEntrySize = Int(UInt32.max)
        static let maximumFilenameSize = Int(UInt16.max)
        static let utf8FilenameFlag: UInt16 = 0x0800
        static let zeroUInt16: UInt16 = 0
        static let zeroUInt32: UInt32 = 0
    }

    private struct StoredEntryRecord {
        let centralDirectoryRecord: Data
        let localFileRecord: Data
    }

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

    /// Creates a ZIP archive builder.
    public init() {
        // Intentionally empty.
    }
}

public extension BatchImageArchiveBuilder {
    /// Returns ZIP archive data for the provided entries, preserving entry order.
    func makeArchiveData(
        for entries: [Entry]
    ) throws -> Data {
        guard entries.count <= ZIPFormat.maximumEntryCount else {
            throw BuildError.tooManyEntries
        }

        var archiveData = Data()
        var centralDirectoryData = Data()

        for entry in entries {
            let record = try storedEntryRecord(
                for: entry,
                localHeaderOffset: archiveData.count
            )
            archiveData.append(record.localFileRecord)
            centralDirectoryData.append(record.centralDirectoryRecord)
        }

        let endOfCentralDirectory = try endOfCentralDirectoryData(
            entryCount: entries.count,
            centralDirectorySize: centralDirectoryData.count,
            centralDirectoryOffset: archiveData.count
        )

        archiveData.append(centralDirectoryData)
        archiveData.append(endOfCentralDirectory)

        return archiveData
    }
}

private extension BatchImageArchiveBuilder {
    private func storedEntryRecord(
        for entry: Entry,
        localHeaderOffset: Int
    ) throws -> StoredEntryRecord {
        let filenameData = try filenameData(
            for: entry.filename
        )
        let fileSize = try uint32(
            entry.data.count,
            error: .entryTooLarge
        )
        let resolvedLocalHeaderOffset = try uint32(
            localHeaderOffset,
            error: .archiveTooLarge
        )
        let resolvedCRC32 = crc32(
            for: entry.data
        )

        return .init(
            centralDirectoryRecord: try centralDirectoryRecordData(
                filenameData: filenameData,
                fileSize: fileSize,
                crc32: resolvedCRC32,
                localHeaderOffset: resolvedLocalHeaderOffset
            ),
            localFileRecord: try localFileRecordData(
                filenameData: filenameData,
                fileData: entry.data,
                fileSize: fileSize,
                crc32: resolvedCRC32
            )
        )
    }

    func localFileRecordData(
        filenameData: Data,
        fileData: Data,
        fileSize: UInt32,
        crc32: UInt32
    ) throws -> Data {
        var data = Data()

        data.appendLittleEndian(
            ZIPFormat.localFileHeaderSignature
        )
        data.appendLittleEndian(
            ZIPFormat.headerVersion
        )
        data.appendLittleEndian(
            ZIPFormat.utf8FilenameFlag
        )
        data.appendLittleEndian(
            ZIPFormat.compressionMethodStore
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(crc32)
        data.appendLittleEndian(fileSize)
        data.appendLittleEndian(fileSize)
        data.appendLittleEndian(
            try uint16(
                filenameData.count,
                error: .filenameTooLong
            )
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.append(filenameData)
        data.append(fileData)

        return data
    }

    func centralDirectoryRecordData(
        filenameData: Data,
        fileSize: UInt32,
        crc32: UInt32,
        localHeaderOffset: UInt32
    ) throws -> Data {
        var data = Data()

        data.appendLittleEndian(
            ZIPFormat.centralDirectoryHeaderSignature
        )
        data.appendLittleEndian(
            ZIPFormat.headerVersion
        )
        data.appendLittleEndian(
            ZIPFormat.headerVersion
        )
        data.appendLittleEndian(
            ZIPFormat.utf8FilenameFlag
        )
        data.appendLittleEndian(
            ZIPFormat.compressionMethodStore
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(crc32)
        data.appendLittleEndian(fileSize)
        data.appendLittleEndian(fileSize)
        data.appendLittleEndian(
            try uint16(
                filenameData.count,
                error: .filenameTooLong
            )
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt32
        )
        data.appendLittleEndian(localHeaderOffset)
        data.append(filenameData)

        return data
    }

    func endOfCentralDirectoryData(
        entryCount: Int,
        centralDirectorySize: Int,
        centralDirectoryOffset: Int
    ) throws -> Data {
        let resolvedEntryCount = try uint16(
            entryCount,
            error: .tooManyEntries
        )
        let resolvedCentralDirectorySize = try uint32(
            centralDirectorySize,
            error: .archiveTooLarge
        )
        let resolvedCentralDirectoryOffset = try uint32(
            centralDirectoryOffset,
            error: .archiveTooLarge
        )
        var data = Data()

        data.appendLittleEndian(
            ZIPFormat.endOfCentralDirectorySignature
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )
        data.appendLittleEndian(resolvedEntryCount)
        data.appendLittleEndian(resolvedEntryCount)
        data.appendLittleEndian(resolvedCentralDirectorySize)
        data.appendLittleEndian(resolvedCentralDirectoryOffset)
        data.appendLittleEndian(
            ZIPFormat.zeroUInt16
        )

        return data
    }

    func crc32(
        for data: Data
    ) -> UInt32 {
        var crc = UInt32.max

        for byte in data {
            crc ^= UInt32(byte)

            for _ in 0..<ZIPFormat.bitsPerByte {
                if crc & ZIPFormat.crcLeastSignificantBitMask == .zero {
                    crc >>= 1
                } else {
                    crc = (crc >> 1) ^ ZIPFormat.crcPolynomial
                }
            }
        }

        return crc ^ UInt32.max
    }

    func filenameData(
        for filename: String
    ) throws -> Data {
        let data = Data(filename.utf8)

        guard data.count <= ZIPFormat.maximumFilenameSize else {
            throw BuildError.filenameTooLong
        }

        return data
    }

    func uint16(
        _ value: Int,
        error: BuildError
    ) throws -> UInt16 {
        guard value <= Int(UInt16.max) else {
            throw error
        }

        return UInt16(value)
    }

    func uint32(
        _ value: Int,
        error: BuildError
    ) throws -> UInt32 {
        guard value <= ZIPFormat.maximumEntrySize else {
            throw error
        }

        return UInt32(value)
    }
}

private extension Data {
    mutating func appendLittleEndian(
        _ value: UInt16
    ) {
        var resolvedValue = value.littleEndian
        Swift.withUnsafeBytes(
            of: &resolvedValue
        ) { bytes in
            append(contentsOf: bytes)
        }
    }

    mutating func appendLittleEndian(
        _ value: UInt32
    ) {
        var resolvedValue = value.littleEndian
        Swift.withUnsafeBytes(
            of: &resolvedValue
        ) { bytes in
            append(contentsOf: bytes)
        }
    }
}
