// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("14.0"),
        .macOS("11.0"),
        .tvOS("14.0"),
        .watchOS("7.0"),
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],
    dependencies: [],

    targets: [
        .target(name: "CBORCoding", dependencies: []),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding"])
    ],

    swiftLanguageVersions: [.v5]
)
