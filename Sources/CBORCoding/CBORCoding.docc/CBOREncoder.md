# ``CBORCoding/CBOREncoder``

## Overview

The example below shows to how to encode an instance of a simple `Car` type to an encoded CBOR object. The type adopts [Codable](https://developer.apple.com/documentation/swift/codable) so that it's encodable using a `CBOREncoder` instance.

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

## Topics

### Creating A Encoder

- ``init(dateEncodingStrategy:includeCBORTag:keySorter:userInfo:)``

### Configuring The Encoder

- ``dateEncodingStrategy-swift.property``
- ``DateEncodingStrategy-swift.enum``
- ``includeCBORTag``
- ``keySorter``
- ``userInfo``

### Using The Encoder

- ``encode(_:)``

## See Also

- [CBOR Specification](https://datatracker.ietf.org/doc/html/rfc8949)
