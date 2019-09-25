//
//  CBOR.swift
//  CBORCoding
//
//  Created by Joseph Newton on 5/18/19.
//  Copyright © 2019 Some Random iOS Dev. All rights reserved.
//

import Foundation

// MARK: - CBOR Definition

public struct CBOR {

    // MARK: Public Types

    /// Type value for encoding/decoding Undefined values as outlined in RFC 7049
    /// section 3.8: https://tools.ietf.org/html/rfc7049#section-3.8
    public struct Undefined { }

    /// CBOR supports encoding negative values normally outside of the range `Int64`.
    /// `NegativeUInt64` fulfils the remaining values not representable by `Int64`. The
    /// encoded value is equal to -1 - `rawValue`
    public struct NegativeUInt64: RawRepresentable {

        // MARK: RawRepresentable Protocol Requirements

        public var rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }

    /// CBOR Major Type 7 specifies multiple codes for simple data types (bool, floating
    /// point numbers, etc.). Many of the codes under major type 7 aren't yet assigned
    /// to any particular type/value. `SimpleValue` fills this gap by returning the
    /// exact encoded value for those codes that are unassigned or unused.
    public struct SimpleValue: RawRepresentable {

        // MARK: RawRepresentable Protocol Requirements

        public var rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    /// Type value for encoding/decoding Big numbers as outlined in RFC 7049
    /// section 2.4.2: https://tools.ietf.org/html/rfc7049#section-2.4.2
    public struct Bignum {

        // MARK: Public Fields

        var isPositive: Bool
        var content: Data
    }

    /// Type value for encoding/decoding Decimal Fractions as outlined in RFC 7049
    /// section 2.4.3: https://tools.ietf.org/html/rfc7049#section-2.4.3
    public struct DecimalFraction<I1, I2> where I1: FixedWidthInteger, I2: FixedWidthInteger {

        // MARK: Public Fields

        var exponent: I1
        var mantissa: I2
    }

    /// Type value for encoding/decoding Big floats as outlined in RFC 7049 section
    /// 2.4.3: https://tools.ietf.org/html/rfc7049#section-2.4.3
    public struct Bigfloat<I1, I2> where I1: FixedWidthInteger, I2: FixedWidthInteger {

        // MARK: Public Fields

        var exponent: I1
        var mantissa: I2
    }

    /// CBOR supports containers whose length isn't defined at the time of encoding.
    /// `IndefiniteLengthArray` provides support for encoding (homogeneous) arrays
    /// whose length is undefined. This may be useful for sending to decoders that
    /// expect array lengths to be undefined.
    /// https://tools.ietf.org/html/rfc7049#section-2.2.1
    public struct IndefiniteLengthArray<Element> {

        // MARK: Public Properties

        public var array: [Element]

        // MARK: Initialization

        public init(wrapping array: [Element] = []) {
            self.array = array
        }
    }

    /// CBOR supports containers whose length isn't defined at the time of encoding.
    /// `IndefiniteLengthMap` provides support for encoding (homogeneous) dictionaries
    /// whose length is undefined. This may be useful for sending to decoders that
    /// expect map lengths to be undefined.
    /// https://tools.ietf.org/html/rfc7049#section-2.2.1
    public struct IndefiniteLengthMap<Key, Value> where Key: Hashable {

        // MARK: Public Properties

        public var map: [Key: Value]

        // MARK: Initialization

        public init(wrapping map: [Key: Value] = [:]) {
            self.map = map
        }
    }

    /// CBOR supports byte data whose length isn't defined at the time of encoding. This
    /// is achieved by encoding definite length "chunks" of byte data wrapped in a byte
    /// data header specifying indefinite length. `IndefiniteLengthData` provides
    /// support for encoding byte data in this way. This may be useful for sending to
    /// decoders that expect byte data lengths to be undefined.
    public struct IndefiniteLengthData {

        // MARK: Public Properties

        public var chunks: [Data]

        // MARK: Initialization

        public init(wrapping chunks: [Data] = []) {
            self.chunks = chunks
        }

        public init(wrapping data: Data = Data(), chunkSize: Int = 128 /* 1kb */) {
            precondition(chunkSize > 0, "Chunk size must be greater than or equal to zero")

            let numberOfBytes = data.count
            let numberOfChunks = Int(ceil(Double(numberOfBytes) / Double(chunkSize)))

            var chunks: [Data] = []
            chunks.reserveCapacity(numberOfChunks)

            for i in 0 ..< numberOfChunks {
                let range = ((i * chunkSize) ..< ((i + 1) * chunkSize)).clamped(to: 0 ..< numberOfBytes)

                chunks.append(Data(data[range]))
            }

            self.chunks = chunks
        }
    }

    /// CBOR supports byte strings whose length isn't defined at the time of encoding.
    /// This is achieved by encoding definite length "chunks" of byte strings wrapped in
    /// a byte string header specifying indefinite length. `IndefiniteLengthString`
    /// provides support for encoding byte strings in this way. This may be useful for
    /// sending to decoders that expect byte string lengths to be undefined.
    public struct IndefiniteLengthString {

        // MARK: Public Properties

        // Chunk type is `Data` since in splitting a string we might split a multi-byte
        // unicode character into multiple chunks, creating two (potentially invalid)
        // characters instead of the desired one
        public var chunks: [Data]

        public var stringValue: String? {
            let totalLength: Int = chunks.reduce(into: 0) { $0 += $1.count }
            return String(data: chunks.reduce(into: Data(capacity: totalLength)) { $0.append($1) }, encoding: .utf8)
        }

        // MARK: Initialization

        public init(wrapping chunks: [String] = []) {
            self.chunks = chunks.map { Data($0.utf8) }
        }

        public init(wrapping string: String = "", chunkSize: Int = 128 /* 1kb */) {
            precondition(chunkSize > 0, "Chunk size must be greater than or equal to zero")

            let data = Data(string.utf8)
            let numberOfBytes = data.count
            let numberOfChunks = Int(ceil(Double(numberOfBytes) / Double(chunkSize)))

            var chunks: [Data] = []
            chunks.reserveCapacity(numberOfChunks)

            for i in 0 ..< numberOfChunks {
                let range = ((i * chunkSize) ..< ((i + 1) * chunkSize)).clamped(to: 0 ..< numberOfBytes)

                chunks.append(Data(data[range]))
            }

            self.chunks = chunks
        }
    }

    /// A type that asserts its data is already in CBOR encoded format. No additional
    /// encoding is done on the contained byte data
    public struct CBOREncoded {

        // MARK: - Fields

        public let encodedData: Data

        // MARK: - Initialization

        public init(encodedData: Data) {
            self.encodedData = encodedData
        }
    }
}

// MARK: - CBOR Extension

extension CBOR {

    // MARK: Internal Types

    /// `Null` type for encoding
    internal struct Null: Encodable { }

    /// `Break` code for ending indefinite length types. This is only used for
    /// type-mismatch error messages
    internal struct Break { }

    // swiftlint:disable operator_usage_whitespace
    /// A byte mask used for splitting the major type bits from the additional
    /// information bits
    internal enum ByteMask: UInt8 {

        // MARK: Cases

        case majorType      = 0b111_00000
        case additionalInfo = 0b000_11111
    }

    /// CBOR Major Type
    internal enum MajorType: UInt8 {

        // MARK: Cases

        case unsigned  = 0b000_00000
        case negative  = 0b001_00000
        case bytes     = 0b010_00000
        case string    = 0b011_00000
        case array     = 0b100_00000
        case map       = 0b101_00000
        case tag       = 0b110_00000
        case additonal = 0b111_00000
    }

    /// Major Type 7 defined bits
    internal enum Bits: UInt8 {

        // MARK: Cases

        case `false`   = 0xF4 // 20
        case `true`    = 0xF5 // 21
        case null      = 0xF6 // 22
        case undefined = 0xF7 // 23
        case half      = 0xF9 // 25
        case float     = 0xFA // 26
        case double    = 0xFB // 27
        case `break`   = 0xFF // 31
    }
    // swiftlint:enable operator_usage_whitespace

    /// Optional CBOR Tags described by RFC 7049 section 2.4
    /// https://tools.ietf.org/html/rfc7049#section-2.4
    internal enum Tag: CustomStringConvertible {

        // MARK: Cases

        case standardDateTime
        case epochDateTime
        case positiveBignum
        case negativeBignum
        case decimalFraction
        case bigfloat
        case base64URLConversion
        case base64Conversion
        case base16Conversion
        case encodedCBORData
        case uri
        case base64URL
        case base64
        case regularExpression
        case mimeMessage
        case selfDescribedCBOR

        // MARK: Initialization

        init?(bits: Data) {
            guard !bits.isEmpty else { return nil }
            guard CBOR.majorType(for: bits[0]) == .tag else { return nil }

            let additonalInfo = CBOR.additionalInfo(for: bits[0])
            switch additonalInfo {
            case 0:  self = .standardDateTime
            case 1:  self = .epochDateTime
            case 2:  self = .positiveBignum
            case 3:  self = .negativeBignum
            case 4:  self = .decimalFraction
            case 5:  self = .bigfloat
            case 21: self = .base64URLConversion
            case 22: self = .base64Conversion
            case 23: self = .base16Conversion
            case 24:
                guard bits.count >= 2 else { return nil }

                switch bits[1] {
                case 24: self = .encodedCBORData
                case 32: self = .uri
                case 33: self = .base64URL
                case 34: self = .base64
                case 35: self = .regularExpression
                case 36: self = .mimeMessage
                default: return nil
                }

            case 25:
                guard bits.count >= 3 else { return nil }

                switch (bits[1], bits[2]) {
                case (0xD9, 0xF7): self = .selfDescribedCBOR
                default:           return nil
                }

            default:
                return nil
            }
        }

        // MARK: Properties

        var bits: Data {
            switch self {
            case .standardDateTime:    return Data([MajorType.tag.rawValue | 0])
            case .epochDateTime:       return Data([MajorType.tag.rawValue | 1])
            case .positiveBignum:      return Data([MajorType.tag.rawValue | 2])
            case .negativeBignum:      return Data([MajorType.tag.rawValue | 3])
            case .decimalFraction:     return Data([MajorType.tag.rawValue | 4])
            case .bigfloat:            return Data([MajorType.tag.rawValue | 5])
            case .base64URLConversion: return Data([MajorType.tag.rawValue | 21])
            case .base64Conversion:    return Data([MajorType.tag.rawValue | 22])
            case .base16Conversion:    return Data([MajorType.tag.rawValue | 23])
            case .encodedCBORData:     return Data([MajorType.tag.rawValue | 24, 24])
            case .uri:                 return Data([MajorType.tag.rawValue | 24, 32])
            case .base64URL:           return Data([MajorType.tag.rawValue | 24, 33])
            case .base64:              return Data([MajorType.tag.rawValue | 24, 34])
            case .regularExpression:   return Data([MajorType.tag.rawValue | 24, 35])
            case .mimeMessage:         return Data([MajorType.tag.rawValue | 24, 36])
            case .selfDescribedCBOR:   return Data([MajorType.tag.rawValue | 25, 0xD9, 0xF7]) // tag | 55799
            }
        }

        // MARK: CustomStringConvertible Protocol Requirements

        var description: String {
            switch self {
            case .standardDateTime:    return "Standard Date/Time String (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .epochDateTime:       return "Epoch-based Date/Time (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .positiveBignum:      return "Positive Bignum (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .negativeBignum:      return "Negative Bignum (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .decimalFraction:     return "Decimal Fraction (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .bigfloat:            return "Bigfloat (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .base64URLConversion: return "Expected Base64 URL Conversion (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .base64Conversion:    return "Expected Base64 Conversion (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .base16Conversion:    return "Expected Base16 Conversion (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .encodedCBORData:     return "Encoded CBOR Data (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .uri:                 return "URI (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .base64URL:           return "Base64 URL (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .base64:              return "Base64 (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .regularExpression:   return "Regular Expression (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .mimeMessage:         return "MIME Message (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            case .selfDescribedCBOR:   return "Self-Described CBOR (\(bits.map({ String(format: "%02X", $0) }).joined()))"
            }
        }
    }

    /// CodingKey type used for keying `CodingKeyDictionary` instances and for
    /// constructing the `codingPath` property of the `__CBOREncoder` and
    /// `__CBORDecoder` instances
    internal struct CodingKey: Swift.CodingKey {

        // MARK: Swift.CodingKey Protocol Requirements

        internal var stringValue: String
        internal var intValue: Int?

        internal init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        internal init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        // MARK: Initialization

        internal init(index: Int) {
            self.stringValue = "Index \(index)"
            self.intValue = index
        }

        // MARK: Constants

        // swiftlint:disable force_unwrapping
        internal static let `super` = CodingKey(stringValue: "super")!
        // swiftlint:enable force_unwrapping
    }

    // MARK: Internal Methods

    internal static func majorType(for byte: UInt8) -> MajorType {
        // swiftlint:disable force_unwrapping
        return MajorType(rawValue: byte & ByteMask.majorType.rawValue)!
        // swiftlint:enable force_unwrapping
    }

    internal static func additionalInfo(for byte: UInt8) -> UInt8 {
        return byte & ByteMask.additionalInfo.rawValue
    }

    // MARK: Error Handling

    internal enum InternalError: Swift.Error {
        case preconditionFailure(message: String, file: StaticString, line: UInt)
    }

    internal static func preconditionFailure(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) throws {
        throw InternalError.preconditionFailure(message: message(), file: file, line: line)
    }

    //

    internal enum DecodingError: Error {

        // MARK: - Cases

        case typeMismatch(expected: [Any.Type], actual: Any.Type)
        case dataCorrupted(description: String)
        case insufficientEncodedBytes(expected: Any.Type?)
        case invalidRFC3339DateString
        case invalidUTF8String
    }
}

// MARK: - DecodingError Extension

extension DecodingError {

    // MARK: Initialization

    internal init(internalError: CBOR.DecodingError, at path: [CodingKey]) {
        switch internalError {
        case let .typeMismatch(expected, actual):
            let expectedTypes: String
            if expected.count > 2 {
                var types = expected.map { "\($0)" }
                types[types.endIndex - 1] = "or " + types[types.endIndex - 1]

                expectedTypes = types.joined(separator: ", ")
            } else if expected.count > 1 {
                expectedTypes = expected.map({ "\($0)" }).joined(separator: " or ")
            } else {
                expectedTypes = "\(expected[0])"
            }

            self = .typeMismatch(expected[0], Context(codingPath: path, debugDescription: "Expected to decode \(expectedTypes) but found \(actual) instead."))

        case let .dataCorrupted(description):
            self = .dataCorrupted(Context(codingPath: path, debugDescription: description))

        case let .insufficientEncodedBytes(expected):
            if let expected = expected {
                self = .dataCorrupted(Context(codingPath: path, debugDescription: "Insufficient number of encoded bytes to decode expected type \(expected)"))
            } else {
                self = .dataCorrupted(Context(codingPath: path, debugDescription: "Insufficient number of encoded bytes"))
            }

        case .invalidUTF8String:
            self = .dataCorrupted(Context(codingPath: path, debugDescription: "Invalid UTF8 string"))

        case .invalidRFC3339DateString:
            self = .dataCorrupted(Context(codingPath: path, debugDescription: "Invalid RFC3339 encoded date string"))
        }
    }
}
