# ``CBORCoding/CBOREncoderProtocol``

## Overview

This protocol is provided as a means to add keyed and unkeyed containers in a way specfic to the CBOR specification: indefinite length containers. The specification provides indefinite length contains as a way to begin encoding a container of a particular type when the total amount of items that will be encoded is initially unknown. 

When using ``CBOREncoder`` for encoding types, this isn't necessarily the case. Still, the receiver of CBOR encoded data may expect containers encoded in a specfic format so this protocol provides a way of creating indefinite length containers while encoding values.

The following example showcases how this protocol might be used in practice to modifiy how containers' lengths will be encoded using the ``CBOREncoder``:

```swift
struct MyStruct<T>: Encodable where T: Encodable {

    var containersToEncode: [[T]]

    func encode(to encoder: Encoder) throws {
        // When encoding this type (or any type) with a CBOREncoder, the `encoder`
        // parameter to this method will conform to CBOREncoderProtocol.

        // Only encode this type for CBOR encoders
        guard let encoder = encoder as? CBOREncoderProtocol else { return }

        // All top-level containers, and nested containers due to the
        // `includingSubcontainers` flag being set to `true`, will be encoded with indefinite
        // length.
        try encoder.indefiniteLengthContainerContext(includingSubcontainers: true) {
            var encoderContainer = encoder.unkeyedContainer()

            // Encode all of the evenly indexed nested containers with definite length
            for (i, container) in containersToEncode.enumerated() {
                if (i % 2) == 0 {
                    try encoder.definiteLengthContainerContext() { // `includingSubcontainers` is `false`
                        try encoderContainer.encode(container)
                    }
                } else {
                    try encoderContainer.encode(container)
                }
            }
        }
    }
}

// When `containers` is encoded the arrays will be encoded with the following lengths:
let containers: [[Int]] = [ // Top-Level: indefinite length
    [1],                    // Index 0: definite length
    [2, 3],                 // Index 1: indefinite length
    [4, 5, 6],              // Index 2: definite length
    [7, 8, 9, 10],          // Index 3: indefinite length
    [11, 12, 13, 14, 15]    // Index 4: definite length
]

let encoder = CBOREncoder()
let myStruct = MyStruct(containersToEncode: containers)
let encodedContainers = try encoder.encode(myStruct)
```

## Topics

### Creating Containers of Specific Lengths

- ``indefiniteLengthContainerContext(includingSubcontainers:_:)-7195t``
- ``definiteLengthContainerContext(includingSubcontainers:_:)-4guss``

## See Also

- [CBOR Specification](https://datatracker.ietf.org/doc/html/rfc8949)
- [CBOR Indefinite-Length Byte Strings and Text Strings](https://datatracker.ietf.org/doc/html/rfc8949#section-3.2.3)
