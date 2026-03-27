import Foundation
@testable import LietLibrary
import Testing

struct BatchImageArchiveBuilderTests {
    @Test
    func empty_entries_create_an_empty_zip_archive() throws {
        let builder: BatchImageArchiveBuilder = .init()
        let archiveData = try builder.makeArchiveData(for: [])
        let archive = try ZIPArchiveFixture(
            archiveData: archiveData
        )

        #expect(archive.entries.isEmpty)
        #expect(archiveData.count == ZIPArchiveFixture.endOfCentralDirectorySize)
    }

    @Test
    func stored_entries_preserve_filename_order_and_contents() throws {
        let builder: BatchImageArchiveBuilder = .init()
        let expectedEntries: [BatchImageArchiveBuilder.Entry] = [
            .init(
                filename: "first-Liet.jpeg",
                data: Data([0x01, 0x02, 0x03, 0x04])
            ),
            .init(
                filename: "second-Liet.png",
                data: Data([0x05, 0x06, 0x07])
            )
        ]

        let archiveData = try builder.makeArchiveData(
            for: expectedEntries
        )
        let archive = try ZIPArchiveFixture(
            archiveData: archiveData
        )

        #expect(
            archive.entries.map(\.filename) == expectedEntries.map(\.filename)
        )
        #expect(
            archive.entries.map(\.data) == expectedEntries.map(\.data)
        )
        #expect(
            archive.entries.allSatisfy { entry in
                entry.compressionMethod == ZIPArchiveFixture.storedCompressionMethod
            }
        )
        #expect(
            archive.entries.allSatisfy { entry in
                entry.generalPurposeFlag == ZIPArchiveFixture.utf8FilenameFlag
            }
        )
    }
}
