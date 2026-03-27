import Foundation
import Testing

struct ZIPArchiveFixture {
    private enum RecordOffsets {
        static let centralDirectoryCommentLength = 32
        static let centralDirectoryCompressionMethod = 10
        static let centralDirectoryCompressedSize = 20
        static let centralDirectoryExtraLength = 30
        static let centralDirectoryFilenameLength = 28
        static let centralDirectoryFilenameOffset = 46
        static let centralDirectoryGeneralPurposeFlag = 8
        static let centralDirectoryLocalHeaderOffset = 42
        static let endOfCentralDirectoryEntryCount = 10
        static let endOfCentralDirectoryOffset = 16
        static let localFileDataOffset = 30
        static let localFileExtraLength = 28
        static let localFileFilenameLength = 26
        static let uint16ByteCount = 2
        static let uint32ByteCount = 4
    }

    struct Entry: Equatable {
        let compressionMethod: UInt16
        let data: Data
        let filename: String
        let generalPurposeFlag: UInt16
    }

    static let centralDirectoryHeaderSignature: UInt32 = 0x02014B50
    static let endOfCentralDirectorySize = 22
    static let endOfCentralDirectorySignature: UInt32 = 0x06054B50
    static let localFileHeaderSignature: UInt32 = 0x04034B50
    static let storedCompressionMethod: UInt16 = 0
    static let utf8FilenameFlag: UInt16 = 0x0800

    let entries: [Entry]

    init(
        archiveData: Data
    ) throws {
        let locator = try Self.endOfCentralDirectoryLocator(
            in: archiveData
        )
        entries = try Self.parseEntries(
            in: archiveData,
            from: locator
        )
    }
}

private extension ZIPArchiveFixture {
    struct EndOfCentralDirectoryLocator {
        let centralDirectoryOffset: Int
        let entryCount: Int
    }

    struct CentralDirectoryEntryRecord {
        let commentLength: Int
        let compressedSize: Int
        let compressionMethod: UInt16
        let extraLength: Int
        let filenameData: Data
        let filenameLength: Int
        let generalPurposeFlag: UInt16
        let localHeaderOffset: Int
    }

    static func endOfCentralDirectoryLocator(
        in archiveData: Data
    ) throws -> EndOfCentralDirectoryLocator {
        let offset = archiveData.count - Self.endOfCentralDirectorySize

        #expect(
            try uint32(
                in: archiveData,
                at: offset
            ) == Self.endOfCentralDirectorySignature
        )

        return .init(
            centralDirectoryOffset: try Int(
                Self.uint32(
                    in: archiveData,
                    at: offset + RecordOffsets.endOfCentralDirectoryOffset
                )
            ),
            entryCount: try Int(
                Self.uint16(
                    in: archiveData,
                    at: offset + RecordOffsets.endOfCentralDirectoryEntryCount
                )
            )
        )
    }

    static func parseEntries(
        in archiveData: Data,
        from locator: EndOfCentralDirectoryLocator
    ) throws -> [Entry] {
        var entries: [Entry] = []
        var offset = locator.centralDirectoryOffset

        for _ in 0..<locator.entryCount {
            let parsedEntry = try Self.parseEntry(
                in: archiveData,
                at: offset
            )
            entries.append(parsedEntry.entry)
            offset = parsedEntry.nextOffset
        }

        return entries
    }

    static func parseEntry(
        in archiveData: Data,
        at offset: Int
    ) throws -> (entry: Entry, nextOffset: Int) {
        let centralDirectoryEntry = try Self.centralDirectoryEntryRecord(
            in: archiveData,
            at: offset
        )
        let localDataOffset = try Self.localFileDataOffset(
            in: archiveData,
            at: centralDirectoryEntry.localHeaderOffset
        )
        let entry = try Entry(
            compressionMethod: centralDirectoryEntry.compressionMethod,
            data: archiveData.subdata(
                in: localDataOffset..<localDataOffset + centralDirectoryEntry.compressedSize
            ),
            filename: Self.decodedFilename(
                from: centralDirectoryEntry.filenameData
            ),
            generalPurposeFlag: centralDirectoryEntry.generalPurposeFlag
        )
        let nextOffset = offset +
            RecordOffsets.centralDirectoryFilenameOffset +
            centralDirectoryEntry.filenameLength +
            centralDirectoryEntry.extraLength +
            centralDirectoryEntry.commentLength

        return (entry, nextOffset)
    }

    static func centralDirectoryEntryRecord(
        in archiveData: Data,
        at offset: Int
    ) throws -> CentralDirectoryEntryRecord {
        try Self.expectRecordSignature(
            in: archiveData,
            at: offset,
            expected: Self.centralDirectoryHeaderSignature
        )

        let filenameLength = try Self.centralDirectoryFilenameLength(
            in: archiveData,
            at: offset
        )

        return .init(
            commentLength: try Int(
                Self.uint16(
                    in: archiveData,
                    at: offset + RecordOffsets.centralDirectoryCommentLength
                )
            ),
            compressedSize: try Int(
                Self.uint32(
                    in: archiveData,
                    at: offset + RecordOffsets.centralDirectoryCompressedSize
                )
            ),
            compressionMethod: try Self.centralDirectoryCompressionMethod(
                in: archiveData,
                at: offset
            ),
            extraLength: try Int(
                Self.uint16(
                    in: archiveData,
                    at: offset + RecordOffsets.centralDirectoryExtraLength
                )
            ),
            filenameData: Self.centralDirectoryFilenameData(
                in: archiveData,
                at: offset,
                filenameLength: filenameLength
            ),
            filenameLength: filenameLength,
            generalPurposeFlag: try Self.centralDirectoryGeneralPurposeFlag(
                in: archiveData,
                at: offset
            ),
            localHeaderOffset: try Int(
                Self.uint32(
                    in: archiveData,
                    at: offset + RecordOffsets.centralDirectoryLocalHeaderOffset
                )
            )
        )
    }

    static func localFileDataOffset(
        in archiveData: Data,
        at offset: Int
    ) throws -> Int {
        try Self.expectRecordSignature(
            in: archiveData,
            at: offset,
            expected: Self.localFileHeaderSignature
        )

        let localFilenameLength = try Int(
            Self.uint16(
                in: archiveData,
                at: offset + RecordOffsets.localFileFilenameLength
            )
        )
        let localExtraLength = try Int(
            Self.uint16(
                in: archiveData,
                at: offset + RecordOffsets.localFileExtraLength
            )
        )

        return offset +
            RecordOffsets.localFileDataOffset +
            localFilenameLength +
            localExtraLength
    }

    static func centralDirectoryFilenameData(
        in archiveData: Data,
        at offset: Int,
        filenameLength: Int
    ) -> Data {
        let filenameStartOffset = offset + RecordOffsets.centralDirectoryFilenameOffset
        let filenameEndOffset = filenameStartOffset + filenameLength

        return archiveData.subdata(
            in: filenameStartOffset..<filenameEndOffset
        )
    }

    static func centralDirectoryCompressionMethod(
        in archiveData: Data,
        at offset: Int
    ) throws -> UInt16 {
        try Self.uint16(
            in: archiveData,
            at: offset + RecordOffsets.centralDirectoryCompressionMethod
        )
    }

    static func centralDirectoryGeneralPurposeFlag(
        in archiveData: Data,
        at offset: Int
    ) throws -> UInt16 {
        try Self.uint16(
            in: archiveData,
            at: offset + RecordOffsets.centralDirectoryGeneralPurposeFlag
        )
    }

    static func centralDirectoryFilenameLength(
        in archiveData: Data,
        at offset: Int
    ) throws -> Int {
        try Int(
            Self.uint16(
                in: archiveData,
                at: offset + RecordOffsets.centralDirectoryFilenameLength
            )
        )
    }

    static func expectRecordSignature(
        in archiveData: Data,
        at offset: Int,
        expected signature: UInt32
    ) throws {
        #expect(
            try Self.uint32(
                in: archiveData,
                at: offset
            ) == signature
        )
    }

    static func decodedFilename(
        from data: Data
    ) throws -> String {
        guard let filename = String(
            bytes: data,
            encoding: .utf8
        ) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }

        return filename
    }

    static func uint16(
        in data: Data,
        at offset: Int
    ) throws -> UInt16 {
        guard offset + RecordOffsets.uint16ByteCount <= data.count else {
            throw CocoaError(.coderReadCorrupt)
        }

        return try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw CocoaError(.coderReadCorrupt)
            }

            let pointer = baseAddress.advanced(by: offset)
            return pointer.loadUnaligned(as: UInt16.self).littleEndian
        }
    }

    static func uint32(
        in data: Data,
        at offset: Int
    ) throws -> UInt32 {
        guard offset + RecordOffsets.uint32ByteCount <= data.count else {
            throw CocoaError(.coderReadCorrupt)
        }

        return try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw CocoaError(.coderReadCorrupt)
            }

            let pointer = baseAddress.advanced(by: offset)
            return pointer.loadUnaligned(as: UInt32.self).littleEndian
        }
    }
}
