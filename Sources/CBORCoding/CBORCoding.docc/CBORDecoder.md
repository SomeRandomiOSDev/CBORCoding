# ``CBORCoding/CBORDecoder``

## Overview

The example below shows to how to decode an instance of a simple `Car` type from an encoded CBOR object. The type adopts [Codable](https://developer.apple.com/documentation/swift/codable) so that it's decodable using a `CBORDecoder` instance.

```swift
struct Car: Codable {
    var manufacturer: String
    var model: String
    var horsePower: Int
    var description: String?
}

// JSON Equivalent: { "manufacturer": "Kia", "model": "Stinger GT2", "horsePower": 365 }
let encodedData = Data(fromHexString: "0xA36C6D616E756661637475726572634B6961656D6F64656C6B5374696E676572204754326A686F727365506F77657219016D")
let decoder = CBORDecoder()

let car = try decoder.decode(Car.self, from: encodedData)

/* 
car.manufacturer == "Kia"
car.model == "Stinger GT2"
car.horsePower == 365
car.description == nil
*/
```

## Topics

### Creating A Decoder

- ``init(userInfo:)``

### Configuring The Decoder

- ``userInfo``

### Using The Decoder

- ``decode(_:from:)``

## See Also

- [CBOR Specification](https://datatracker.ietf.org/doc/html/rfc8949)
