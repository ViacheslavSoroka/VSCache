// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "VSCache",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "VSCache",
            targets: ["VSCache"]),
    ],
    targets: [
        .target(
            name: "VSCache",
            path: ".",
            sources: ["Source/VSCache.m"],
            publicHeadersPath: "Source",
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]
        )
    ]
)
