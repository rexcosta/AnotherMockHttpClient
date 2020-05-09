// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnotherMockHttpClient",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AnotherMockHttpClient",
            targets: ["AnotherMockHttpClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/rexcosta/AnotherSwiftCommonLib.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "AnotherMockHttpClient",
            dependencies: ["AnotherSwiftCommonLib"]
        ),
        .testTarget(
            name: "AnotherMockHttpClientTests",
            dependencies: ["AnotherMockHttpClient"]
        ),
    ]
)
