import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var model: BatchImageHomeModel = .init()
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            BatchImageHomeView(
                model: model,
                selectedItems: $selectedItems
            )
            .navigationDestination(
                isPresented: Binding(
                    get: {
                        model.resultModel != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            model.resultModel = nil
                        }
                    }
                )
            ) {
                if let resultModel = model.resultModel {
                    BatchImageResultView(model: resultModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
