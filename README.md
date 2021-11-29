# CBORCoding

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d30d31c29f17449481b97a04610ff5b9)](https://app.codacy.com/app/SomeRandomiOSDev/CBORCoding?utm_source=github.com&utm_medium=referral&utm_content=SomeRandomiOSDev/CBORCoding&utm_campaign=Badge_Grade_Dashboard)
[![License MIT](https://img.shields.io/cocoapods/l/CBORCoding.svg)](https://cocoapods.org/pods/CBORCoding)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CBORCoding.svg)](https://cocoapods.org/pods/CBORCoding) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Platform](https://img.shields.io/cocoapods/p/CBORCoding.svg)](https://cocoapods.org/pods/CBORCoding)
[![Code Coverage](https://codecov.io/gh/SomeRandomiOSDev/CBORCoding/branch/master/graph/badge.svg)](https://codecov.io/gh/SomeRandomiOSDev/CBORCoding)

[![Carthage](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/carthage.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/carthage.yml)
[![Cocoapods](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/cocoapods.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/cocoapods.yml)
[![Documentation](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/documentation.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/documentation.yml)
[![Swift Package](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/swift-package.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/swift-package.yml)
[![SwiftLint](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/swiftlint.yml)
[![XCFramework](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/xcframework.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/xcframework.yml)
[![Xcode Project](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/xcodebuild.yml/badge.svg)](https://github.com/SomeRandomiOSDev/CBORCoding/actions/workflows/xcodebuild.yml)

**CBORCoding** is a lightweight framework containing a coder pair for encoding and decoding `Codable` conforming types to and from [CBOR](https://cbor.io) document format for iOS, macOS, tvOS, and watchOS.

## Installation

**CBORCoding** is available through [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and the [Swift Package Manager](https://swift.org/package-manager/). 

To install via CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'CBORCoding'
```

To install via Carthage, simply add the following line to your Cartfile:

```ruby
github "SomeRandomiOSDev/CBORCoding"
```

To install via the Swift Package Manager add the following line to your `Package.swift` file's `dependencies`:

```swift
.package(url: "https://github.com/SomeRandomiOSDev/CBORCoding.git", from: "1.0.0")
```

## Usage

First import **CBORCoding** at the top of your Swift file:

```swift
import CBORCoding
```

After importing, the use is nearly identical to that of the `JSONEncoder`/`JSONDecoder` class pair provided by the Swift Foundation library. This example shows how to encode an instance of a simple `Car` type to a CBOR object: 

```swift
struct Car: Codable {
    var manufacturer: String
    var model: String
    var horsePower: Int
    var description: String?
}

let stinger = Car(manufacturer: "Kia", model: "Stinger GT2", horsePower: 365, description: nil)  
let encoder = CBOREncoder()

let encodedData = try encoder.encode(stinger)
print("CBOR: \(hexString(encodedData))")

/* Prints:
 CBOR: 0xA36C6D616E756661637475726572634B6961656D6F64656C6B5374696E676572204754326A686F727365506F77657219016D
*/
```

This example shows how to decode that encoded `Car` value at a later time: 

```swift
let decoder = CBORDecoder()
let stinger = try decoder.decode(Car.self, from: encodedData)
```

## CBOR

**Concise Binary Object Representation** is a data format for being able to encode formatted data with a goal of a having as small a message size as possible.

While this framework implements as much of the specification as possible, there are a few notable exceptions:

* CBOR supports keys of any defined type, however, since `Codable` relies on `CodingKey` for encoding/decoding its keyed containers, this framework is limited in its supported key types to `Int` and `String`.
* CBOR supports DecimalFractions and Bigfloats whose mantissa is a Bignum. With the current implementation, this is limited to Bignums whose content fits into either a `Int64` or `UInt64` type.

For more information about the CBOR format see: [CBOR](https://cbor.io) & [RFC 8949](https://datatracker.ietf.org/doc/html/rfc8949).

## Contributing

Whether it's submitting a feature request, reporting a bug, or writing code yourself, all contributions to this library are welcome! Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more information on how you can contribute.

## Author

Joe Newton, somerandomiosdev@gmail.com

## Credits

**CBORCoding** is based heavily on the `JSONEncoder`/`JSONDecoder` classes provided by Swift. See `ATTRIBUTIONS` for more details.

## License

**CBORCoding** is available under the MIT license. See the `LICENSE` file for more info.
