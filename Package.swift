// swift-tools-version:5.0
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
    dependencies: [],

    targets: [
        .target(name: "CBORCoding", dependencies: []),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding"])
    ]
)
