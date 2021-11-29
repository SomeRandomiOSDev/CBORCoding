# ``CBORCoding``

A simple library for encoding and decoding `Codable` types to and from CBOR encoded objects.

## Overview

This library provides two top-level coders, ``CBOREncoder`` and ``CBORDecoder``, for encoding and decoding (respectively) CBOR encoded objects to/from [Codable](https://developer.apple.com/documentation/swift/codable) types. These coders are modeled closely to Foundation's own [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder) types for the sake of familiarity and ease of use.

The example below shows to how one might change a value in an encoded CBOR object:

```swift
struct Vehicle: Codable {
    var numberOfWheels: Int
    var color: String
    var mpg: Int
}

// JSON Equivalent: { "numberOfWheels": 4, "color": "black", "mpg": 17 }
let cborData = Data(fromHexString: "0xA36E6E756D6265724F66576865656C730465636F6C6F7265626C61636B636D706711")
let decoder = CBORDecoder()

var vehicle = try decoder.decode(Vehicle.self, from: cborData)
vehicle.color = "red"

let updatedCBORData = try encoder.encode(vehicle)
print("CBOR: \(hexString(updatedCBORData))")

/* Prints:
 CBOR: 0xA36E6E756D6265724F66576865656C730465636F6C6F7263726564636D706711
*/
```

## Topics

### Coders

- ``CBOREncoder``
- ``CBORDecoder``

### Custom Encoding

- ``CBOREncoderProtocol``

### CBOR Types

- ``CBOR/Undefined``
- ``CBOR/NegativeUInt64``
- ``CBOR/SimpleValue``
- ``CBOR/Bignum``
- ``CBOR/DecimalFraction``
- ``CBOR/Bigfloat``
- ``CBOR/IndefiniteLengthArray``
- ``CBOR/IndefiniteLengthMap``
- ``CBOR/IndefiniteLengthData``
- ``CBOR/IndefiniteLengthString``
- ``CBOR/CBOREncoded``

### Namespaces

- ``CBOR``

## See Also

- [CBOR Specification](https://datatracker.ietf.org/doc/html/rfc8949)
