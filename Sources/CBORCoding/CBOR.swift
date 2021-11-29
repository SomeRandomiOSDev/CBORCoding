//
//  CBOR.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - CBOR Definition

/// A top level type for encapsulating types specific to the CBOR specification
public enum CBOR {

    // MARK: Public Types

    /**
     Type value for encoding/decoding Undefined values as outlined in [RFC 8949
     Section 5.7](https://datatracker.ietf.org/doc/html/rfc8949#section-5.7).
     */
    public struct Undefined { }

    /**
     CBOR supports encoding negative values normally outside of the range `Int64`.
     `NegativeUInt64` fulfils the remaining values not representable by `Int64`. The
     encoded value is equal to `-1 - rawValue`.

     This is provided as a means of reflecting the range of the `UInt64` into the
     negative side of the number spectrum. Pairing this type with `UInt64` & `Int64`
     the range of representable numbers is as follows:

     ```
     (-1 - UInt64.max) ... Int64.min ... -1, 0 ... Int64.max ... UInt64.max
     ------------NegativeUInt64------------  ------------UInt64------------
                           --------------Int64--------------
     ```
     */
    public struct NegativeUInt64: RawRepresentable {

        // MARK: Public Constants

        /// The maximum value this type can represent: `-1`
        public static let max = NegativeUInt64(rawValue: 0)

        /// The minimum value this type can represent: `-18446744073709551616`
        public static let min = NegativeUInt64(rawValue: .max)

        // MARK: RawRepresentable Protocol Requirements

        /// The raw value of this negative integer. This value is representative of a purely
        /// negative value computed by: `-1 - rawValue`.
        public var rawValue: UInt64

        /**
         Creates a new `NegativeUInt64` with a specified value.

         - Parameters:
           - rawValue: The value for this negative integer.

         - Returns: The newly initialized negative integer.
         */
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }

    /**
     CBOR Major Type 7 specifies multiple codes for simple data types (bool, floating
     point numbers, etc.). Many of the codes under major type 7 aren't yet assigned
     to any particular type/value. `SimpleValue` fills this gap by returning the
     exact encoded value for those codes that are unassigned or unused.
     */
    public struct SimpleValue: RawRepresentable {

        // MARK: RawRepresentable Protocol Requirements

        /// The raw value for this type.
        public var rawValue: UInt8

        /**
         Initializes a new `SimpleValue` with the given value.

         - Parameters:
           - rawValue: The raw value for this type.

         - Returns: The newly initialized simple value.
         */
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    /**
     Type value for encoding/decoding Big numbers as outlined in [RFC 8949 Section
     3.4.3](https://datatracker.ietf.org/doc/html/rfc8949#section-3.4.3).
     */
    public struct Bignum {

        // MARK: Public Properties

        /// A flag indicating whether this number is positive or negative.
        public var isPositive: Bool

        /// The binary content of the number.
        public var content: Data

        // MARK: Initialization

        /**
         Initializes a new big number with the specified parameters.

         - Parameters:
           - isPositive: A flag indicating whether this number is positive or negative.
           - content: The binary content of the number.

         - Returns: The newly initialized number.
         */
        public init(isPositive: Bool, content: Data) {
            self.isPositive = isPositive
            self.content = content
        }
    }

    /**
     Type value for encoding/decoding Decimal Fractions as outlined in [RFC 8949
     Section 3.4.4](https://datatracker.ietf.org/doc/html/rfc8949#section-3.4.4). The
     value of this type is computed as follows: `mantissa * (10 ^ exponent)`
     */
    public struct DecimalFraction<I1, I2> where I1: FixedWidthInteger, I2: FixedWidthInteger {

        // MARK: Public Properties

        /// The exponent of the fraction.
        public var exponent: I1

        /// The mantissa of the fraction.
        public var mantissa: I2

        // MARK: Initialization

        /**
         Initializes a new decimal fraction with the specified parameters.

         - Parameters:
           - exponent: The exponent of the fraction.
           - mantissa: The mantissa of the fraction.

         - Returns: The newly initialized decimal fraction.
         */
        public init(exponent: I1, mantissa: I2) {
            self.exponent = exponent
            self.mantissa = mantissa
        }
    }

    /**
     Type value for encoding/decoding Big floats as outlined in [RFC 8949 Section
     3.4.4](https://datatracker.ietf.org/doc/html/rfc8949#section-3.4.4). The value
     of this type is computed as follows: `mantissa * (2 ^ exponent)`
     */
    public struct Bigfloat<I1, I2> where I1: FixedWidthInteger, I2: FixedWidthInteger {

        // MARK: Public Properties

        /// The exponent of the float.
        public var exponent: I1

        /// The mantissa of the float.
        public var mantissa: I2

        // MARK: Initialization

        /**
         Initializes a new big float with the specified parameters.

         - Parameters:
           - exponent: The exponent of the float.
           - mantissa: The mantissa of the float.

         - Returns: The newly initialized big float.
         */
        public init(exponent: I1, mantissa: I2) {
            self.exponent = exponent
            self.mantissa = mantissa
        }
    }

    /**
     CBOR supports containers whose length isn't defined at the time of encoding.
     `IndefiniteLengthArray` provides support for encoding (homogeneous) arrays whose
     length is undefined. This may be useful for sending to decoders that expect
     array lengths to be undefined.
     */
    public struct IndefiniteLengthArray<Element> {

        // MARK: Public Properties

        /// The wrapped array. This array (but not nested containers) will be encoded with
        /// an indefinite length.
        public var array: [Element]

        // MARK: Initialization

        /**
         Initializes a new indefinite length array that wraps a given array.

         - Parameters:
           - array: The array whose length is to be encoded as indefinite.

         - Returns: The newly initialized indefinite length array.
         */
        public init(wrapping array: [Element] = []) {
            self.array = array
        }
    }

    /**
     CBOR supports containers whose length isn't defined at the time of encoding.
     `IndefiniteLengthMap` provides support for encoding (homogeneous) dictionaries
     whose length is undefined. This may be useful for sending to decoders that
     expect map lengths to be undefined.
     */
    public struct IndefiniteLengthMap<Key, Value> where Key: Hashable {

        // MARK: Public Properties

        /// The wrapped dictionary. This dictionary (but not nested containers) will be
        /// encoded with an indefinite length.
        public var map: [Key: Value]

        // MARK: Initialization

        /**
         Initializes a new indefinite length map that wraps a given dictionary.

         - Parameters:
           - map: The dictionary whose length is to be encoded as indefinite.

         - Returns: The newly initialized indefinite length map.
         */
        public init(wrapping map: [Key: Value] = [:]) {
            self.map = map
        }
    }

    /**
     CBOR supports byte data whose length isn't defined at the time of encoding. This
     is achieved by encoding definite length "chunks" of byte data wrapped in a byte
     data header specifying indefinite length. `IndefiniteLengthData` provides
     support for encoding byte data in this way. This may be useful for sending to
     decoders that expect byte data lengths to be undefined.
     */
    public struct IndefiniteLengthData {

        // MARK: Public Properties

        /// The data chunks that make up this indefinite length data. The chunks themselves will
        /// be encoded with a definite length whereas the enclosing type will be encoded
        /// with an indefinite length.
        public var chunks: [Data]

        // MARK: Initialization

        /**
         Initializes a new indefinite length data wrapping a given array of data chunks.

         - Parameters:
           - chunks: The chunks of data that make up this indefinite length data.

         - Returns: The newly initialized indefinite length data.
         */
        public init(wrapping chunks: [Data] = []) {
            self.chunks = chunks
        }

        /**
         Initializes a new indefinite length data by breaking up a single data object
         into smaller chunks.

         - Parameters:
           - data: The data to be broken up into smaller chunks.
           - chunkSize: The maximum size (in bytes) of each chunk.

         - Returns: The newly initialized indefinite length data.
         */
        public init(wrapping data: Data = Data(), chunkSize: Int = 128 /* 1kb */) {
            precondition(chunkSize > 0, "Chunk size must be greater than or equal to zero")

            let numberOfBytes = data.count
            let numberOfChunks = Int(ceil(Double(numberOfBytes) / Double(chunkSize)))

            var chunks: [Data] = []
            chunks.reserveCapacity(numberOfChunks)

            for i in 0 ..< numberOfChunks {
                let lowerBound = data.index(data.startIndex, offsetBy: i * chunkSize)
                let upperBound = data.index(data.startIndex, offsetBy: (i + 1) * chunkSize, limitedBy: data.endIndex) ?? data.endIndex

                chunks.append(Data(data[lowerBound ..< upperBound]))
            }

            self.chunks = chunks
        }
    }

    /**
     CBOR supports byte strings whose length isn't defined at the time of encoding.
     This is achieved by encoding definite length "chunks" of byte strings wrapped in
     a byte string header specifying indefinite length. `IndefiniteLengthString`
     provides support for encoding byte strings in this way. This may be useful for
     sending to decoders that expect byte string lengths to be undefined.
     */
    public struct IndefiniteLengthString {

        // MARK: Public Properties

        /// The data chunks that make up this indefinite length string. The chunks
        /// themselves will be encoded with a definite length whereas the enclosing type
        /// will be encoded with an indefinite length.
        public var chunks: [Data]

        /// The string composed by joining together all of the data chunks and interpreting
        /// it as a UTF8 encoded string.
        @inline(__always) public var stringValue: String? {
            return stringValue(as: .utf8)
        }

        // MARK: Initialization

        /**
         Initializes a new indefinite length string wrapping a given array of string
         chunks.

         - Parameters:
           - chunks: The chunks of strings that make up this indefinite length string.

         - Returns: The newly initialized indefinite length string.
         */
        public init(wrapping chunks: [String] = []) {
            self.chunks = chunks.map { Data($0.utf8) }
        }

        /**
         Initializes a new indefinite length string by breaking up a single string object
         into smaller chunks. The string is split on byte boundaries based on a UTF-8
         representation of the string, not on character boundaries.

         - Parameters:
           - string: The string to be broken up into smaller chunks.
           - chunkSize: The maximum size (in bytes) of each chunk.

         - Returns: The newly initialized indefinite length data.
         */
        public init(wrapping string: String = "", chunkSize: Int = 128 /* 1kb */) {
            precondition(chunkSize > 0, "Chunk size must be greater than or equal to zero")

            let data = Data(string.utf8)
            let numberOfBytes = data.count
            let numberOfChunks = Int(ceil(Double(numberOfBytes) / Double(chunkSize)))

            var chunks: [Data] = []
            chunks.reserveCapacity(numberOfChunks)

            for i in 0 ..< numberOfChunks {
                let lowerBound = data.index(data.startIndex, offsetBy: i * chunkSize)
                let upperBound = data.index(data.startIndex, offsetBy: (i + 1) * chunkSize, limitedBy: data.endIndex) ?? data.endIndex

                chunks.append(Data(data[lowerBound ..< upperBound]))
            }

            self.chunks = chunks
        }

        // MARK: Public Methods

        /**
         Composes a string by joining together all of the data chunks and interpreting it
         as a string with the given encoding.

         - Parameters:
           - encoding: The encoding of the string to use when interpreting the data.

         - Returns: The composed string value, or `nil` if unable to convert the data to
           a string with the specified encoding.
         */
        public func stringValue(as encoding: String.Encoding) -> String? {
            let totalLength: Int = chunks.reduce(into: 0) { $0 += $1.count }
            return String(data: chunks.reduce(into: Data(capacity: totalLength)) { $0.append($1) }, encoding: encoding)
        }
    }

    /**
     A type that asserts its data is already in CBOR encoded format. No additional
     encoding is done on the contained byte data.
     */
    public struct CBOREncoded {

        // MARK: - Properties

        /// The CBOR encoded data.
        public let encodedData: Data

        // MARK: - Initialization

        /**
         Initializes a new `CBOREncoded` structure with CBOR encoded data.

         - Parameters:
           - encodedData: The CBOR encoded data.

         - Returns: The newly initialized `CBOREncoded` structure.
         */
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

    /**
     Optional CBOR Tags described by [RFC 8949 Section
     3.4](https://datatracker.ietf.org/doc/html/rfc8949#section-3.4).
     */
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
            guard CBOR.majorType(for: bits[bits.startIndex]) == .tag else { return nil }

            let additonalInfo = CBOR.additionalInfo(for: bits[bits.startIndex])
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

                switch bits[bits.index(after: bits.startIndex)] {
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

                switch (bits[bits.index(bits.startIndex, offsetBy: 1)], bits[bits.index(bits.startIndex, offsetBy: 2)]) {
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

    /**
     CodingKey type used for keying `CodingKeyDictionary` instances and for
     constructing the `codingPath` property of the `__CBOREncoder` and
     `__CBORDecoder` instances
     */
    internal struct CodingKey: Swift.CodingKey {

        // MARK: Swift.CodingKey Protocol Requirements

        internal var stringValue: String
        internal var intValue: Int?

        internal init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        internal init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        // MARK: Initialization

        internal init(index: Int) {
            self.stringValue = "Index \(index)"
            self.intValue = index
        }

        // MARK: Constants

        internal static let `super` = CodingKey(stringValue: "super")
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
                types[types.index(before: types.endIndex)] = "or " + types[types.index(before: types.endIndex)]

                expectedTypes = types.joined(separator: ", ")
            } else if expected.count > 1 {
                expectedTypes = expected.map({ "\($0)" }).joined(separator: " or ")
            } else {
                expectedTypes = "\(expected[expected.startIndex])"
            }

            self = .typeMismatch(expected[expected.startIndex], Context(codingPath: path, debugDescription: "Expected to decode \(expectedTypes) but found \(actual) instead."))

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
