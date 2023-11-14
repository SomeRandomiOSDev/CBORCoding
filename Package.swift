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

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.4.0")
    ],

    targets: [
        .target(name: "CBORCoding", dependencies: ["Half"]),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding", "Half"])
    ]
)
