// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-pixela",
    products: [
        .library(name: "Pixela", targets: ["Pixela"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Pixela", dependencies: []),
        .testTarget(name: "PixelaTests", dependencies: ["Pixela"]),
    ]
)
