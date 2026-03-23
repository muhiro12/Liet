import Foundation
@testable import Liet
import Testing

struct PhotoImportServiceTests {
    @Test
    func original_filename_uses_transferred_file_basename_when_available() {
        let transferredFileURL = URL(fileURLWithPath: "/tmp/IMG_1234.HEIC")

        #expect(
            PhotoImportService.originalFilename(
                from: transferredFileURL
            ) == "IMG_1234.HEIC"
        )
    }

    @Test
    func original_filename_falls_back_to_nil_when_missing() {
        #expect(
            PhotoImportService.originalFilename(
                from: nil
            ) == nil
        )
    }
}
