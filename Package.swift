// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("12.0"),
        .macOS("10.13"),
        .tvOS("12.0"),
        .watchOS("4.0")
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.4.2")
    ],

    targets: [
        .target(
            name: "CBORCoding",
            dependencies: ["Half"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CBORCodingTests",
            dependencies: ["CBORCoding", "Half"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
