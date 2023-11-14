// swift-tools-version:5.5
import PackageDescription

#if arch(x86_64)
let macOS = SupportedPlatform.macOS(.v10_10)
let macCatalyst = SupportedPlatform.macCatalyst(.v13)
#else
let macOS = SupportedPlatform.macOS(.v11)
let macCatalyst = SupportedPlatform.macCatalyst(.v14)
#endif

#if (os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)
// We still need Half
let halfTarget: [Target.Dependency] = ["Half"]
#else
let halfTarget: [Target.Dependency] = []
#endif

let halfPackage: [Package.Dependency] = [
  .package(url: "https://github.com/SomeRandomiOSDev/Half", from: "1.3.1")
]

let package = Package(
    name: "CBORCoding",

    platforms: [
        .iOS(.v14),
        macOS,
        .tvOS(.v14),
        .watchOS(.v7),
        macCatalyst
    ],

    products: [
        .library(name: "CBORCoding", targets: ["CBORCoding"])
    ],

    dependencies: halfPackage,

    targets: [
        .target(name: "CBORCoding", dependencies: halfTarget),
        .testTarget(name: "CBORCodingTests", dependencies: ["CBORCoding"] + halfTarget)
    ],

    swiftLanguageVersions: [.version("4.2"), .version("5")]
)
