import LietLibrary
import SwiftUI
import TipKit

struct BatchResizeModeInputView: View {
    let keepsAspectRatio: Bool
    @Binding var referenceDimension: BatchResizeReferenceDimension
    @Binding var referencePixels: String
    @Binding var resizeWidth: String
    @Binding var resizeHeight: String
    @Binding var exactResizeStrategy: BatchExactResizeStrategy
    let resizeMethodTip: ResizeMethodTip

    @Namespace private var resizeModeNamespace

    var body: some View {
        ZStack(alignment: .topLeading) {
            if keepsAspectRatio {
                BatchAspectRatioResizeInputView(
                    referenceDimension: $referenceDimension,
                    referencePixels: $referencePixels
                )
                .matchedGeometryEffect(
                    id: "processing.resize.mode",
                    in: resizeModeNamespace
                )
                .transition(BatchProcessingAnimation.sectionRevealTransition)
            } else {
                BatchExactResizeInputView(
                    resizeWidth: $resizeWidth,
                    resizeHeight: $resizeHeight,
                    exactResizeStrategy: $exactResizeStrategy,
                    resizeMethodTip: resizeMethodTip
                )
                .matchedGeometryEffect(
                    id: "processing.resize.mode",
                    in: resizeModeNamespace
                )
                .transition(BatchProcessingAnimation.sectionRevealTransition)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
