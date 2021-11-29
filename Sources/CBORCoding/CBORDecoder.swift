//
//  CBOREncoder.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation
import Half

#if canImport(Combine)
import Combine
#endif // #if canImport(Combine)

// MARK: - CBORDecoder Definition

/// An object that decodes instances of a data type from CBOR objects.
open class CBORDecoder {

    // MARK: Private Types

    fileprivate struct Options {

        // MARK: Fields

        let userInfo: [CodingUserInfoKey: Any]
    }

    // MARK: Public Properties

    /// A dictionary you use to customize the decoding process by providing contextual
    /// information.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    // MARK: Private Properties

    private var options: Options {
        return Options(userInfo: userInfo)
    }

    // MARK: Initialization

    /**
     Creates a new, reusable CBOR decoder.

     - Parameters:
       - userInfo: A default dictionary usecd to customize the decoding process.

     - Returns: The newly initialized decoder.
     */
    public init(userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.userInfo = userInfo
    }

    // MARK: Public Methods

   // swiftlint:disable function_default_parameter_at_end
    /**
     Returns an instance of a given type decoded from a CBOR-encoded representation
     of the type.

     If there's a problem decoding the given type, this method throws an error based
     on the type of problem.

     - Parameters:
       - type: The type to decode
       - data: The CBOR-encoded data from which to decode the type

     - Throws: Rethrows any errors thrown by the type to decode (or any nested
               values) or throws any errors encountered during decoding.

     - Returns: An instance of `type` decoded from the CBOR-encoded data.
     */
    open func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        guard !data.isEmpty else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode \(type) from empty data."))
        }

        let topLevel: Any
        do {
            // swiftlint:disable force_unwrapping
            topLevel = try CBORParser.parse(data)!
            // swiftlint:enable force_unwrapping
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid CBOR.", underlyingError: error))
        }

        let decoder = __CBORDecoder(referencing: topLevel, options: options)
        return try decoder.decode(type)
    }
    // swiftlint:enable function_default_parameter_at_end
}

// MARK: - __CBORDecoder Definition

internal class __CBORDecoder: Decoder, SingleValueDecodingContainer {

    // MARK: - Properties

    fileprivate var storage: CBORDecodingStorage
    fileprivate let options: CBORDecoder.Options

    // MARK: Initialization

    fileprivate init(referencing container: Any, options: CBORDecoder.Options, at codingPath: [CodingKey] = []) {
        self.storage = CBORDecodingStorage()
        self.storage.push(container: container)

        self.codingPath = codingPath
        self.options = options
    }

    // MARK: Decoder Protocol Requirements

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(storage.topContainer is CBOR.Null) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let topContainer = storage.topContainer as? CodingKeyDictionary<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: storage.topContainer)
        }

        let container = __CBORKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(storage.topContainer is CBOR.Null) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        guard let topContainer = storage.topContainer as? ArrayWrapper<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: storage.topContainer)
        }

        return __CBORUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }

    // MARK: SingleValueDecodingContainer Protocol Requirements

    func decodeNil() -> Bool {
        return storage.topContainer is CBOR.Null
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(type)
        return try decode(storage.topContainer, as: type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(type)
        return try decodeFloatingPoint(storage.topContainer, as: type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(type)
        return try decodeFloatingPoint(storage.topContainer, as: type)
    }

    func decode(_ type: String.Type) throws -> String {
        try expectNonNull(type)
        let decodedString: CBORDecodedString

        do {
            decodedString = try decode(storage.topContainer, as: CBORDecodedString.self)
        } catch {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: storage.topContainer)
        }

        return try decodedString.decodedStringValue()
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try decode(storage.topContainer, as: type)
    }

    // MARK: Internal Methods

    internal func decode<I1, I2>(_ type: CBOR.DecimalFraction<I1, I2>.Type) throws -> CBOR.DecimalFraction<I1, I2> where I1: FixedWidthInteger & Decodable, I2: FixedWidthInteger & Decodable {
        try expectNonNull(type)

        guard let array = storage.topContainer as? [Any], array.count == 3,
              let tag = array[0] as? CBOR.Tag, (tag == .decimalFraction || tag == .bigfloat) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: storage.topContainer)
        }
        guard tag == .decimalFraction else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: CBOR.Bigfloat(exponent: 0, mantissa: 0))
        }

        let exponent: I1 = try decodeExponent(from: array[1], decodedTypeDescription: "Decimal Fraction")
        let mantissa: I2 = try decodeMantissa(from: array[2], decodedTypeDescription: "Decimal Fraction")

        return CBOR.DecimalFraction(exponent: exponent, mantissa: mantissa)
    }

    internal func decode<I1, I2>(_ type: CBOR.Bigfloat<I1, I2>.Type) throws -> CBOR.Bigfloat<I1, I2> where I1: FixedWidthInteger & Decodable, I2: FixedWidthInteger & Decodable {
        try expectNonNull(type)

        guard let array = storage.topContainer as? [Any], array.count == 3,
            let tag = array[0] as? CBOR.Tag, (tag == .decimalFraction || tag == .bigfloat) else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: storage.topContainer)
        }
        guard tag == .bigfloat else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: CBOR.Bigfloat(exponent: 0, mantissa: 0))
        }

        let exponent: I1 = try decodeExponent(from: array[1], decodedTypeDescription: "Bigfloat")
        let mantissa: I2 = try decodeMantissa(from: array[2], decodedTypeDescription: "Bigfloat")

        return CBOR.Bigfloat(exponent: exponent, mantissa: mantissa)
    }

    // MARK: Fileprivate Methods

    fileprivate func decode<T>(_ value: Any, as type: T.Type) throws -> T {
        guard let decodedValue = value as? T else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return decodedValue
    }

    fileprivate func decode<T: Decodable>(_ value: Any, as type: T.Type) throws -> T {
        let result: T

        // swiftlint:disable force_cast
        if type == Data.self, let value = value as? CBORDecodedData {
            result = value.decodedDataValue() as! T
        } else if type == String.self, let value = value as? CBORDecodedString {
            result = try value.decodedStringValue() as! T
        } else if type == CBOR.NegativeUInt64.self {
            result = try decode(value, as: CBOR.NegativeUInt64.self) as! T
        } else if type == CBOR.Undefined.self {
            guard let decodedValue = value as? T else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
            }

            result = decodedValue
        } else if let decodedValue = value as? T {
            result = decodedValue
        } else if type == Half.self {
            result = try decodeFloatingPoint(value, as: Half.self) as! T
        } else {
            storage.push(container: value)
            defer { storage.popContainer() }

            result = try type.init(from: self)
        }
        // swiftlint:enable force_cast

        return result
    }

    //

    fileprivate func decode(_ value: Any, as type: Bool.Type) throws -> Bool {
        guard let decodedValue = value as? Bool else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return decodedValue
    }

    fileprivate func decode<T>(_ value: Any, as type: T.Type) throws -> T where T: UnsignedInteger, T: FixedWidthInteger {
        let unsigned: T
        if let uint64 = value as? UInt64 {
            guard let value = T(exactly: uint64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(uint64)> does not fit in \(type)."))
            }

            unsigned = value
        } else if let int64 = value as? Int64 {
            assert(int64 < 0)
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(int64)> does not fit in \(type)."))
        } else if let negativeUInt64 = value as? CBOR.NegativeUInt64 {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in \(type)."))
        } else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return unsigned
    }

    fileprivate func decode<T>(_ value: Any, as type: T.Type) throws -> T where T: SignedInteger, T: FixedWidthInteger {
        let signed: T
        if let int64 = value as? Int64 {
            guard let value = T(exactly: int64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(int64)> does not fit in \(type)."))
            }

            signed = value
        } else if let uint64 = value as? UInt64 {
            guard let value = T(exactly: uint64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(uint64)> does not fit in \(type)."))
            }

            signed = value
        } else if let negativeUInt64 = value as? CBOR.NegativeUInt64 {
            guard negativeUInt64.rawValue <= UInt64(T.max) + 1 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in \(type)."))
            }

            if negativeUInt64.rawValue == UInt64(T.max) + 1 {
                signed = T.min
            } else {
                signed = -T(negativeUInt64.rawValue)
            }
        } else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return signed
    }

    fileprivate func decodeFloatingPoint<T>(_ value: Any, as type: T.Type) throws -> T where T: BinaryFloatingPoint {
        let floatingPoint: T
        if let half = value as? Half {
            if half.isNaN {
                if half.isSignalingNaN {
                    floatingPoint = .signalingNaN
                } else {
                    floatingPoint = .nan
                }
            } else {
                guard let value = T(exactly: half) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(half)> does not fit in \(type)."))
                }

                floatingPoint = value
            }
        } else if let float = value as? Float {
            if float.isNaN {
                if float.isSignalingNaN {
                    floatingPoint = .signalingNaN
                } else {
                    floatingPoint = .nan
                }
            } else {
                guard let value = T(exactly: float) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(float)> does not fit in \(type)."))
                }

                floatingPoint = value
            }
        } else if let double = value as? Double {
            if double.isNaN {
                if double.isSignalingNaN {
                    floatingPoint = .signalingNaN
                } else {
                    floatingPoint = .nan
                }
            } else {
                guard let value = T(exactly: double) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(double)> does not fit in \(type)."))
                }

                floatingPoint = value
            }
        } else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return floatingPoint
    }

    fileprivate func decode(_ value: Any, as type: CBOR.NegativeUInt64.Type) throws -> CBOR.NegativeUInt64 {
        let result: CBOR.NegativeUInt64
        if let int64 = value as? Int64 {
            assert(int64 < 0)
            result = CBOR.NegativeUInt64(rawValue: UInt64(-1 - int64))
        } else if let uint64 = value as? UInt64 {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number <\(uint64)> does not fit in \(type)."))
        } else if let negativeUInt64 = value as? CBOR.NegativeUInt64 {
            result = negativeUInt64
        } else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return result
    }

    fileprivate func decode(_ value: Any, as type: String.Type) throws -> String {
        guard let decodedValue = value as? String else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return decodedValue
    }

    // MARK: Private Methods

    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    // swiftlint:disable function_body_length
    private func decodeExponent<I>(from value: Any, decodedTypeDescription type: String) throws -> I where I: FixedWidthInteger {
        let exponent: I

        if let int64 = value as? Int64 {
            guard let value = I(exactly: int64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) exponent <\(int64)> does not fit in \(I.self)."))
            }

            exponent = value
        } else if let uint64 = value as? UInt64 {
            guard let value = I(exactly: uint64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) exponent <\(uint64)> does not fit in \(I.self)."))
            }

            exponent = value
        } else if let negativeUInt64 = value as? CBOR.NegativeUInt64 {
            guard I.isSigned && negativeUInt64.rawValue <= UInt64(I.max) + 1 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) exponent <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in \(I.self)."))
            }

            if negativeUInt64.rawValue == UInt64(I.max) + 1 {
                exponent = I.min
            } else {
                exponent = -1 - I(negativeUInt64.rawValue)
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid decoded CBOR number for \(type) exponent."))
        }

        return exponent
    }

    private func decodeMantissa<I>(from value: Any, decodedTypeDescription type: String) throws -> I where I: FixedWidthInteger {
        let mantissa: I

        if let int64 = value as? Int64 {
            guard let value = I(exactly: int64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) mantissa <\(int64)> does not fit in \(I.self)."))
            }

            mantissa = value
        } else if let uint64 = value as? UInt64 {
            guard let value = I(exactly: uint64) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) mantissa <\(uint64)> does not fit in \(I.self)."))
            }

            mantissa = value
        } else if let negativeUInt64 = value as? CBOR.NegativeUInt64 {
            guard I.isSigned && negativeUInt64.rawValue <= UInt64(I.max) + 1 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded CBOR number for \(type) mantissa <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in \(I.self)."))
            }

            if negativeUInt64.rawValue == UInt64(I.max) + 1 {
                mantissa = I.min
            } else {
                mantissa = -1 - I(negativeUInt64.rawValue)
            }
        } else if let bignum = value as? CBOR.Bignum {
            guard bignum.content.count <= (I.bitWidth / 8) else {
                throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number for \(type) mantissa <\(bignum.isPositive ? "" : "-")0x\(bignum.content.map({ String(format: "%02X", $0) }).joined())> does not fit in \(I.self)")
            }

            if bignum.isPositive {
                let uint64: UInt64
                // swiftlint:disable force_unwrapping
                if bignum.content.count == 8 {
                    uint64 = bignum.content.reversed().withUnsafeBytes { $0.bindMemory(to: UInt64.self).baseAddress!.pointee }
                } else {
                    let padded = Data(count: 8 - bignum.content.count) + bignum.content
                    uint64 = padded.reversed().withUnsafeBytes { $0.bindMemory(to: UInt64.self).baseAddress!.pointee }
                }
                // swiftlint:enable force_unwrapping

                guard let value = I(exactly: uint64) else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number for \(type) mantissa <\(uint64)> does not fit in \(I.self)")
                }

                mantissa = value
            } else {
                let negativeUInt64: CBOR.NegativeUInt64
                // swiftlint:disable force_unwrapping
                if bignum.content.count == 8 {
                    negativeUInt64 = CBOR.NegativeUInt64(rawValue: bignum.content.reversed().withUnsafeBytes { $0.bindMemory(to: UInt64.self).baseAddress!.pointee })
                } else {
                    let padded = Data(count: 8 - bignum.content.count) + bignum.content
                    negativeUInt64 = CBOR.NegativeUInt64(rawValue: padded.reversed().withUnsafeBytes { $0.bindMemory(to: UInt64.self).baseAddress!.pointee })
                }
                // swiftlint:enable force_unwrapping

                guard I.isSigned && negativeUInt64.rawValue <= UInt64(I.max) + 1 else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number for \(type) mantissa <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in \(I.self)")
                }

                if negativeUInt64.rawValue == UInt64(I.max) + 1 {
                    mantissa = I.min
                } else {
                    mantissa = -1 - I(negativeUInt64.rawValue)
                }
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid decoded CBOR number for \(type) mantissa."))
        }

        return mantissa
    }
    // swiftlint:enable function_body_length
}

// MARK: - CBORDecodingStorage Definition

private struct CBORDecodingStorage {

    // MARK: Properties

    private(set) var containers: [Any] = []

    var topContainer: Any {
        precondition(!containers.isEmpty, "Empty container stack.")
        // swiftlint:disable force_unwrapping
        return containers.last!
        // swiftlint:enable force_unwrapping
    }

    // MARK: Initialization

    init() { /* Nothing to do */ }

    // MARK: Methods

    mutating func push(container: Any) {
        containers.append(container)
    }

    mutating func popContainer() {
        precondition(!containers.isEmpty, "Empty container stack.")
        containers.removeLast()
    }
}

// MARK: - __CBORKeyedDecodingContainer Definition

private struct __CBORKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    // MARK: Type Definitions

    typealias Key = K

    // MARK: Private Properties

    private let decoder: __CBORDecoder
    private let container: CodingKeyDictionary<Any>

    // MARK: Initialization

    init(referencing decoder: __CBORDecoder, wrapping container: CodingKeyDictionary<Any>) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    // MARK: KeyedDecodingContainerProtocol Protocol Requirements

    private(set) var codingPath: [CodingKey]

    var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0.stringValue) }
    }

    func contains(_ key: Key) -> Bool {
        return container[key] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let entry = container[key] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(description(of: key))."))
        }

        return entry is CBOR.Null
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try decodeValue(forKey: key) { value in
            try expectNonNull(value, type)
            return try decoder.decode(value, as: type)
        }
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let entry = container[key] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(description(of: key))."))
        }

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        try expectNonNull(entry, type)
        return try decoder.decode(entry, as: type)
    }

    //

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value = container[key] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(description(of: key))"))
        }

        guard let dictionary = value as? CodingKeyDictionary<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        let keyedContainer = __CBORKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(keyedContainer)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value = container[key] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(description(of: key))"))
        }

        guard let array = value as? ArrayWrapper<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }

        return __CBORUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }

    //

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: CBOR.CodingKey.super)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }

    // MARK: Private Methods

    private func description(of key: Key) -> String {
        return "\(key) (\"\(key.stringValue)\")"
    }

    private func expectNonNull<T>(_ value: Any, _ type: T.Type) throws {
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    private func decodeValue<T>(forKey key: Key, decode: (Any) throws -> T) throws -> T {
        guard let entry = container[key] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(description(of: key))."))
        }

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        return try decode(entry)
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let value: Any = container[key] ?? CBOR.Null()
        return __CBORDecoder(referencing: value, options: decoder.options, at: decoder.codingPath)
    }
}

// MARK: - __CBORUnkeyedDecodingContainer Definition

private struct __CBORUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    // MARK: Private Properties

    private let decoder: __CBORDecoder
    private let container: ArrayWrapper<Any>

    // MARK: Properties

    private(set) var codingPath: [CodingKey]
    private(set) var currentIndex: Int

    // MARK: Initialization

    init(referencing decoder: __CBORDecoder, wrapping container: ArrayWrapper<Any>) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }

    // MARK: UnkeyedDecodingContainer Protocol Requirements

    var count: Int? {
        return container.count
    }

    var isAtEnd: Bool {
        return currentIndex >= container.count
    }

    //

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        let isNil: Bool
        if container[currentIndex] is CBOR.Null {
            currentIndex += 1
            isNil = true
        } else {
            isNil = false
        }

        return isNil
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try decodeCurrentFloatingPointValue(as: type)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try decodeCurrentFloatingPointValue(as: type)
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try decodeCurrentValue(as: type)
    }

    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try decodeCurrentValue(as: type)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let dictionary = value as? CodingKeyDictionary<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        currentIndex += 1
        return KeyedDecodingContainer(__CBORKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let array = value as? ArrayWrapper<Any> else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }

        currentIndex += 1
        return __CBORUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }

    //

    mutating func superDecoder() throws -> Decoder {
        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }

        let value = container[currentIndex]

        currentIndex += 1
        return __CBORDecoder(referencing: value, options: decoder.options, at: decoder.codingPath)
    }

    // MARK: Private Methods

    private mutating func decodeCurrentValue<T>(as type: T.Type) throws -> T where T: Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Expected \(T.self) but found null instead."))
        }

        let decodedValue = try decoder.decode(value, as: type)

        currentIndex += 1
        return decodedValue
    }

    private mutating func decodeCurrentValue<T>(as type: T.Type) throws -> T where T: UnsignedInteger, T: FixedWidthInteger {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Expected \(T.self) but found null instead."))
        }

        let decodedValue = try decoder.decode(value, as: type)

        currentIndex += 1
        return decodedValue
    }

    private mutating func decodeCurrentValue<T>(as type: T.Type) throws -> T where T: SignedInteger, T: FixedWidthInteger {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Expected \(T.self) but found null instead."))
        }

        let decodedValue = try decoder.decode(value, as: type)

        currentIndex += 1
        return decodedValue
    }

    private mutating func decodeCurrentFloatingPointValue<T>(as type: T.Type) throws -> T where T: BinaryFloatingPoint {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        decoder.codingPath.append(CBOR.CodingKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let value = container[currentIndex]
        guard !(value is CBOR.Null) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: decoder.codingPath + [CBOR.CodingKey(index: currentIndex)], debugDescription: "Expected \(T.self) but found null instead."))
        }

        let decodedValue = try decoder.decodeFloatingPoint(value, as: type)

        currentIndex += 1
        return decodedValue
    }
}

// MARK: - DecodingError Extension

extension DecodingError {

    fileprivate static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }
}

// MARK: - CBORDecoder Extension

#if canImport(Combine)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CBORDecoder: TopLevelDecoder {

    public typealias Input = Data
}
#endif // #if canImport(Combine)
