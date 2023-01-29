// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .macCatalyst(.v14),
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
