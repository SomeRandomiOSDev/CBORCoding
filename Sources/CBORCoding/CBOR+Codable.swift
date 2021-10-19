//
//  CBOR+Codable.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - CBOR.Undefined Extension

extension CBOR.Undefined: Codable {

    // MARK: Private Constants

    private static let encodedStringValue = "__undefined"

    // MARK: Codable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            let encoded = CBOR.CBOREncoded(encodedData: CBOREncoder.encodeUndefined())

            try container.encode(encoded)
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(CBOR.Undefined.encodedStringValue)
        }
    }

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()
            self = try container.decode(CBOR.Undefined.self)
        } else {
            let container = try decoder.singleValueContainer()
            let decodedValue = try container.decode(String.self)

            guard decodedValue == CBOR.Undefined.encodedStringValue else {
                throw DecodingError.typeMismatch(CBOR.Undefined.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode \(CBOR.Undefined.self) but found \(String.self) instead."))
            }
        }
    }
}

// MARK: - CBOR.NegativeUInt64 Extension

extension CBOR.NegativeUInt64: Codable {

    // MARK: Codable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            try container.encode(self)
        } else {
            try rawValue.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if decoder is __CBORDecoder {
            self = try container.decode(CBOR.NegativeUInt64.self)
        } else {
            rawValue = try container.decode(UInt64.self)
        }
    }
}

// MARK: - CBOR.SimpleValue Extension

extension CBOR.SimpleValue: Codable {

    // MARK: Codable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            let encoded = CBOREncoder.encodeSimpleValue(rawValue)

            try container.encode(encoded)
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if decoder is __CBORDecoder {
            self = try container.decode(CBOR.SimpleValue.self)
        } else {
            rawValue = try container.decode(UInt8.self)
        }
    }
}

// MARK: - CBOR.Bignum Extension

extension CBOR.Bignum: Codable {

    // MARK: Codable Protocol Requirements

    private enum CodingKeys: String, Swift.CodingKey {
        case isPositive
        case content
    }

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            let encoded = try CBOREncoder.encode(content, forTag: isPositive ? .positiveBignum : .negativeBignum)

            try container.encode(encoded)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(isPositive, forKey: .isPositive)
            try container.encode(content, forKey: .content)
        }
    }

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()
            self = try container.decode(CBOR.Bignum.self)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            isPositive = try container.decode(Bool.self, forKey: .isPositive)
            content = try container.decode(Data.self, forKey: .content)
        }
    }
}

// MARK: - CBOR.DecimalFraction Extension

extension CBOR.DecimalFraction: Encodable where I1: Encodable, I2: Encodable {

    // MARK: Encodable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            let encoded = try CBOREncoder.encode([exponent, mantissa], forTag: .decimalFraction)

            try container.encode(encoded)
        } else {
            var container = encoder.unkeyedContainer()
            try container.encode(exponent)
            try container.encode(mantissa)
        }
    }
}

// MARK: - CBOR.DecimalFraction Extension

extension CBOR.DecimalFraction: Decodable where I1: Decodable, I2: Decodable {

    // MARK: Decodable Protocol Requirements

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()

            // swiftlint:disable force_cast
            assert(container is __CBORDecoder)
            self = try (container as! __CBORDecoder).decode(CBOR.DecimalFraction<I1, I2>.self)
            // swiftlint:enable force_cast
        } else {
            var container = try decoder.unkeyedContainer()

            exponent = try container.decode(I1.self)
            mantissa = try container.decode(I2.self)
        }
    }
}

// MARK: - CBOR.Bigfloat Extension

extension CBOR.Bigfloat: Encodable where I1: Encodable, I2: Encodable {

    // MARK: Encodable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            let encoded = try CBOREncoder.encode([exponent, mantissa], forTag: .bigfloat)

            try container.encode(encoded)
        } else {
            var container = encoder.unkeyedContainer()
            try container.encode(exponent)
            try container.encode(mantissa)
        }
    }
}

// MARK: - CBOR.Bigfloat Extension

extension CBOR.Bigfloat: Decodable where I1: Decodable, I2: Decodable {

    // MARK: Decodable Protocol Requirements

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()

            // swiftlint:disable force_cast
            assert(container is __CBORDecoder)
            self = try (container as! __CBORDecoder).decode(CBOR.Bigfloat<I1, I2>.self)
            // swiftlint:enable force_cast
        } else {
            var container = try decoder.unkeyedContainer()

            exponent = try container.decode(I1.self)
            mantissa = try container.decode(I2.self)
        }
    }
}

// MARK: - CBOR.IndefiniteLengthArray Extension

extension CBOR.IndefiniteLengthArray: Encodable where Element: Encodable {

    // MARK: - Encodable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            try encoder.indefiniteLengthContainerContext {
                try array.encode(to: encoder)
            }
        } else {
            try array.encode(to: encoder)
        }
    }
}

// MARK: - CBOR.IndefiniteLengthArray Extension

extension CBOR.IndefiniteLengthArray: Decodable where Element: Decodable {

    // MARK: - Decodable Protocol Requirements

    public init(from decoder: Decoder) throws {
        array = try [Element](from: decoder)
    }
}

// MARK: - CBOR.IndefiniteLengthMap Extension

extension CBOR.IndefiniteLengthMap: Encodable where Key: Encodable, Value: Encodable {

    // MARK: - Encodable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            try encoder.indefiniteLengthContainerContext {
                try map.encode(to: encoder)
            }
        } else {
            try map.encode(to: encoder)
        }
    }
}

// MARK: - CBOR.IndefiniteLengthMap Extension

extension CBOR.IndefiniteLengthMap: Decodable where Key: Decodable, Value: Decodable {

    // MARK: - Decodable Protocol Requirements

    public init(from decoder: Decoder) throws {
        map = try [Key: Value](from: decoder)
    }
}

// MARK: - CBOR.IndefiniteLengthData Extension

extension CBOR.IndefiniteLengthData: Codable {

    // MARK: - Codable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            try container.encode(self)
        } else {
            try chunks.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()
            self = try container.decode(CBOR.IndefiniteLengthData.self)
        } else {
            chunks = try [Data](from: decoder)
        }
    }
}

// MARK: - CBOR.IndefiniteLengthString Extension

extension CBOR.IndefiniteLengthString: Codable {

    // MARK: - Codable Protocol Requirements

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            try container.encode(self)
        } else {
            try chunks.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? __CBORDecoder {
            let container = try decoder.singleValueContainer()
            self = try container.decode(CBOR.IndefiniteLengthString.self)
        } else {
            chunks = try [Data](from: decoder)
        }
    }
}

// MARK: - CBOR.CBOREncoded Extension

extension CBOR.CBOREncoded: Encodable {

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? __CBOREncoder {
            var container = encoder.singleValueContainer()
            try container.encode(self)
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(encodedData)
        }
    }
}
