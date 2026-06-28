// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HXCollectionKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "HXCollectionKit",
            targets: ["HXCollectionKit"]
        )
    ],
    targets: [
        .target(
            name: "HXCollectionKit",
            path: "Sources"
        ),
        .testTarget(
            name: "HXCollectionKitTests",
            dependencies: ["HXCollectionKit"],
            path: "HXCollectionKit/Tests/HXCollectionKitTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
