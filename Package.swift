// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("11.0"),
        .macOS("10.10"),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],

    targets: [
        .target(name: "CBORCoding", dependencies: ["Half"]),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding", "Half"])
    ],

    swiftLanguageVersions: [.version("4.2"), .version("5")]
)
