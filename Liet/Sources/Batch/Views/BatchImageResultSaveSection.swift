import SwiftUI

struct BatchImageResultSaveSection: View {
    @Bindable var model: BatchImageResultModel

    var body: some View {
        BatchSection(title: Text("Save")) {
            BatchImageResultSaveSectionView(model: model)
        }
    }
}
