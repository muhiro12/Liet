@testable import LietLibrary
import Testing

struct BatchImageImportFilenamePolicyTests {
    @Test
    func still_image_resources_are_preferred_over_paired_video_names() {
        let candidates: [BatchImageImportFilenameCandidate] = [
            .init(
                resourceKind: .pairedVideo,
                originalFilename: "IMG_1234.MOV"
            ),
            .init(
                resourceKind: .photo,
                originalFilename: "IMG_1234.HEIC"
            )
        ]

        #expect(
            BatchImageImportFilenamePolicy.preferredOriginalFilename(
                from: candidates
            ) == "IMG_1234.HEIC"
        )
    }

    @Test
    func unusable_or_blank_candidates_are_ignored_when_choosing_names() {
        let candidates: [BatchImageImportFilenameCandidate] = [
            .init(
                resourceKind: .audio,
                originalFilename: "IMG_1234.M4A"
            ),
            .init(
                resourceKind: .other,
                originalFilename: "   "
            ),
            .init(
                resourceKind: .fullSizePhoto,
                originalFilename: "  IMG_1234.HEIC  "
            )
        ]

        #expect(
            BatchImageImportFilenamePolicy.preferredOriginalFilename(
                from: candidates
            ) == "IMG_1234.HEIC"
        )
    }

    @Test
    func transferred_filenames_use_their_basename_and_allow_empty_fallback() {
        #expect(
            BatchImageImportFilenamePolicy.originalFilename(
                fromTransferredFilename: "/tmp/IMG_1234.HEIC"
            ) == "IMG_1234.HEIC"
        )
        #expect(
            BatchImageImportFilenamePolicy.originalFilename(
                fromTransferredFilename: "   "
            ) == nil
        )
        #expect(
            BatchImageImportFilenamePolicy.originalFilename(
                fromTransferredFilename: nil
            ) == nil
        )
    }
}
