import SwiftUI

struct BatchSaveToPhotosButtonLabel: View {
    let isSaving: Bool

    var body: some View {
        if isSaving {
            ProgressView("Saving to Photos")
                .frame(maxWidth: .infinity)
        } else {
            Label("Save to Photos", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
    }
}
