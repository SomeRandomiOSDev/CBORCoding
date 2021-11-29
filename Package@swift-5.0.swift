// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("9.0"),
        .macOS("10.10"),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.3.1")
    ],

    targets: [
        .target(name: "CBORCoding", dependencies: ["Half"]),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding", "Half"])
    ],

    swiftLanguageVersions: [.version("4.2"), .version("5")]
)
