// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-pixela",
    products: [
        .library(name: "Pixela", targets: ["Pixela"]),
    ],
    dependencies: [
        .package(url: "https://github.com/google/promises.git", from: "1.2.7"),
    ],
    targets: [
        .target(name: "Pixela", dependencies: ["Promises"]),
        .testTarget(name: "PixelaTests", dependencies: ["Pixela"]),
    ]
)
