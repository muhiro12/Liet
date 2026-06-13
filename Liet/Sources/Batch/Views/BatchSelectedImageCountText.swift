import SwiftUI

struct BatchSelectedImageCountText: View {
    let importedImageCount: Int

    var body: some View {
        text.batchTextStyle(.bodyStrong)
    }
}

private extension BatchSelectedImageCountText {
    var text: Text {
        if importedImageCount == 1 {
            Text("1 image selected")
        } else {
            Text("\(importedImageCount) images selected")
        }
    }
}
