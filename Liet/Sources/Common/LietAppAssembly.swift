import MHPlatform

/// App-side composition root for MHPlatform bootstrap ownership.
@MainActor
struct LietAppAssembly {
    let bootstrap: MHAppRuntimeBootstrap
}

extension LietAppAssembly {
    static func live() -> Self {
        .init(
            bootstrap: .init(
                configuration: .init(
                    nativeAdUnitID: LietAdMobConfiguration.nativeAdUnitID,
                    showsLicenses: false
                )
            )
        )
    }

    static func preview() -> Self {
        .init(
            bootstrap: .init(
                runtimeOnlyConfiguration: .init(
                    nativeAdUnitID: nil,
                    showsLicenses: false
                )
            )
        )
    }
}
