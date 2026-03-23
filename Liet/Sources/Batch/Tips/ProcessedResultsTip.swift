import SwiftUI
import TipKit

struct ProcessedResultsTip: Tip {
    var title: Text {
        Text("Review the batch result")
    }

    var message: Text? {
        Text(
            "Successful outputs are ready even if some images failed. " +
                "You can save only the new processed files from here."
        )
    }

    var image: Image? {
        Image(systemName: "photo.stack")
    }

    var rules: [Rule] {
        #Rule(SaveDestinationTip.$hasSavedToFiles) { hasSavedToFiles in
            hasSavedToFiles == false
        }
        #Rule(SaveDestinationTip.$hasSavedToPhotos) { hasSavedToPhotos in
            hasSavedToPhotos == false
        }
    }
}
