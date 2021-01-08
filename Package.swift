// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DSMKit",
    products: [
        .library(
            name: "DSMKit",
            targets: [
                "DSMKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "DSMKit", path: "DSMKit/Classes"),
    ]
)
