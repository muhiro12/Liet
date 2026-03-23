import SwiftUI
import TipKit

struct SelectImagesTip: Tip {
    @Parameter static var hasCompletedImportStep: Bool = false

    var title: Text {
        Text("Start with a batch")
    }

    var message: Text? {
        Text("Pick one or more photos. Liet applies the same resize and compression settings to every selected image.")
    }

    var image: Image? {
        Image(systemName: "photo.on.rectangle.angled")
    }

    var rules: [Rule] {
        #Rule(Self.$hasCompletedImportStep) {
            $0 == false
        }
    }
}

struct ProcessingSetupTip: Tip {
    var title: Text {
        Text("Choose one setting set")
    }

    var message: Text? {
        Text("Set the long edge once, then pick a quality level. JPEG and HEIC use the quality setting. PNG keeps its format. Originals stay untouched.")
    }

    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }

    var rules: [Rule] {
        #Rule(RunProcessingTip.$hasCompletedProcessStep) {
            $0 == false
        }
    }
}

struct RunProcessingTip: Tip {
    @Parameter static var hasCompletedProcessStep: Bool = false

    var title: Text {
        Text("Process everything together")
    }

    var message: Text? {
        Text("When the settings look right, run one batch. Liet creates new files and never overwrites the originals.")
    }

    var image: Image? {
        Image(systemName: "play.circle")
    }

    var rules: [Rule] {
        #Rule(Self.$hasCompletedProcessStep) {
            $0 == false
        }
    }
}

struct ProcessedResultsTip: Tip {
    var title: Text {
        Text("Review the batch result")
    }

    var message: Text? {
        Text("Successful outputs are ready even if some images failed. You can save only the new processed files from here.")
    }

    var image: Image? {
        Image(systemName: "photo.stack")
    }

    var rules: [Rule] {
        #Rule(SaveDestinationTip.$hasSavedToFiles) {
            $0 == false
        }
        #Rule(SaveDestinationTip.$hasSavedToPhotos) {
            $0 == false
        }
    }
}

struct SaveDestinationTip: Tip {
    @Parameter static var hasSavedToFiles: Bool = false
    @Parameter static var hasSavedToPhotos: Bool = false

    var title: Text {
        Text("Pick where the new files go")
    }

    var message: Text? {
        Text("Use Files to choose a folder in the Files app. Use Photos to add the processed images to your photo library as new items.")
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.down")
    }

    var rules: [Rule] {
        #Rule(Self.$hasSavedToFiles) {
            $0 == false
        }
        #Rule(Self.$hasSavedToPhotos) {
            $0 == false
        }
    }
}
