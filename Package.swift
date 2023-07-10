// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "SystemKit",
    platforms: [
        // Relevant platforms.
        .iOS(.v15), .macOS(.v12), .tvOS(.v15)
    ],
    products: [
        .library(name: "SystemKit", targets: ["SystemKit"])
    ],
    dependencies: [
        // It's a good thing to keep things relatively
        // independent, but add any dependencies here.
    ],
    targets: [
        .target(
            name: "SystemKit",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(name: "SystemKitTests", dependencies: ["SystemKit"]),
    ]
)
