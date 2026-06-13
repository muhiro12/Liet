import MHDesign
import SwiftUI

struct BatchFeatureChooserView: View {
    let selectFeature: (BatchFeatureKind) -> Void

    var body: some View {
        List {
            Section {
                BatchFeatureChooserHeader()
            }

            Section {
                ForEach(BatchFeatureKind.allCases) { feature in
                    BatchFeatureChooserRow(
                        feature: feature,
                        selectFeature: selectFeature
                    )
                }
            }

            Section {
                AdvertisementSection(.small)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
    }
}
