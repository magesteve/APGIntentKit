// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APGIntentKit",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "APGIntentKit",
            targets: ["APGIntentKit"]),
    ],
    targets: [
        .target(
            name: "APGIntentKit"),
        .testTarget(
            name: "APGIntentKitTests",
            dependencies: ["APGIntentKit"]
        ),
    ]
)
