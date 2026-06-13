import SwiftUI

struct BatchSaveToPhotosButton: View {
    let isSaving: Bool
    let saveToPhotos: () async -> Void

    var body: some View {
        Button {
            Task {
                await saveToPhotos()
            }
        } label: {
            BatchSaveToPhotosButtonLabel(
                isSaving: isSaving
            )
        }
        .buttonStyle(.bordered)
        .disabled(isSaving)
    }
}
