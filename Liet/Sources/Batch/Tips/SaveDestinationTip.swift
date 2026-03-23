import SwiftUI
import TipKit

struct SaveDestinationTip: Tip {
    @Parameter static var hasSavedToFiles: Bool = false
    @Parameter static var hasSavedToPhotos: Bool = false

    var title: Text {
        Text("Pick where the new files go")
    }

    var message: Text? {
        Text(
            """
            Use Files to choose a folder in the Files app. \
            Use Photos to add the processed images to your photo library as new items.
            """
        )
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.down")
    }

    var rules: [Rule] {
        #Rule(Self.$hasSavedToFiles) { hasSavedToFiles in
            hasSavedToFiles == false
        }
        #Rule(Self.$hasSavedToPhotos) { hasSavedToPhotos in
            hasSavedToPhotos == false
        }
    }
}
