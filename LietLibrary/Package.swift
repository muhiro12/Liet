// swift-tools-version: 6.2

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "LietLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "LietLibrary",
            targets: ["LietLibrary"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/muhiro12/SwiftUtilities",
            "1.0.0"..<"2.0.0"
        ),
        .package(
            url: "https://github.com/muhiro12/MHPlatform",
            "1.0.0"..<"2.0.0"
        )
    ],
    targets: [
        .target(
            name: "LietLibrary",
            dependencies: [
                .product(
                    name: "SwiftUtilities",
                    package: "SwiftUtilities"
                ),
                .product(
                    name: "MHPlatformCore",
                    package: "MHPlatform"
                )
            ],
            path: ".",
            sources: [
                "Sources"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LietLibraryTests",
            dependencies: ["LietLibrary"],
            path: "Tests/Default"
        )
    ]
)
