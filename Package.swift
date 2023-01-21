// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("9.0"),
        .macOS(.v11),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [],

    targets: [
        .target(name: "CBORCoding", dependencies: []),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding"])
    ],

    swiftLanguageVersions: [.version("4.2"), .version("5")]
)
