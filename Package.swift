// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS("8.0"),
        .macOS("10.10"),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.0.0")
    ],

    targets: [
        .target(name: "CBORCoding", dependencies: ["Half"], path: "CBORCoding"),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding"], path: "CBORCodingTests")
    ]
)
