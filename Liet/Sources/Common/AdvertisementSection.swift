import MHPlatform
import SwiftUI

struct AdvertisementSection {
    enum Size {
        case small
        case medium
    }

    @Environment(MHAppRuntime.self)
    private var appRuntime

    private let size: Size

    init(_ size: Size) {
        self.size = size
    }
}

extension AdvertisementSection: View {
    @ViewBuilder var body: some View {
        if appRuntime.adsAvailability == .available {
            appRuntime.nativeAdView(size: size.runtimeSize)
                .frame(maxWidth: .infinity)
        }
    }
}

private extension AdvertisementSection.Size {
    var runtimeSize: MHNativeAdSize {
        switch self {
        case .small:
            .small
        case .medium:
            .medium
        }
    }
}
