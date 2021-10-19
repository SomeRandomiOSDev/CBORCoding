// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "CBORCoding",

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: [
        .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.2.1")
    ],

    targets: [
        .target(name: "CBORCoding", dependencies: ["Half"]),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding", "Half"])
    ],

    swiftLanguageVersions: [.v4_2]
)
