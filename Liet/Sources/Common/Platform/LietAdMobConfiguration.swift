enum LietAdMobConfiguration {
    static let nativeAdUnitIDDebug = "ca-app-pub-3940256099942544/3986624511"
    static let nativeAdUnitIDRelease = "ca-app-pub-2619807738023307/2680546993"

    static var nativeAdUnitID: String {
        #if DEBUG
        nativeAdUnitIDDebug
        #else
        nativeAdUnitIDRelease
        #endif
    }
}
