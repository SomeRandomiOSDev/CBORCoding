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

// MARK: - CBOREncoder Definition

/// An object that encodes instances of a data type as CBOR objects.
open class CBOREncoder {

    // MARK: Private Types

    fileprivate struct Options {

        // MARK: Fields

        let dateEncodingStrategy: DateEncodingStrategy
        let includeCBORTag: Bool
        let userInfo: [CodingUserInfoKey: Any]
    }

    // MARK: Public Types

    /// The strategies available for formatting dates when encoding a date as CBOR
    public enum DateEncodingStrategy {

        // MARK: Cases

        /// The strategy that formats dates as strings according to the RFC 3339 standard
        case rfc3339

        /// The strategy that formats dates in terms of seconds since midnight UTC, January 1, 1970.
        case secondsSince1970

        // MARK: Internal Properties

        internal var bits: Data {
            switch self {
            case .rfc3339:          return CBOR.Tag.standardDateTime.bits
            case .secondsSince1970: return CBOR.Tag.epochDateTime.bits
            }
        }
    }

    // MARK: Public Properties

    /// The strategy used when encoding dates as part of a CBOR object. This defaults to
    /// ``DateEncodingStrategy-swift.enum/secondsSince1970``.
    open var dateEncodingStrategy: DateEncodingStrategy

    /// A flag indicating whether or not to prepend the [Self-Described
    /// CBOR](https://datatracker.ietf.org/doc/html/rfc8949#section-3.4.6) tag to the
    /// begining of the encoded data.
    open var includeCBORTag: Bool

    /// A block to use to sort keys in any given map (dictionary). If not provided
    /// key/value pairs appear in the order in which they were encoded.
    open var keySorter: ((Any, Any) -> Bool)?

    /// A dictionary you use to customize the encoding process by providing contextual
    /// information.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    // MARK: Private Properties

    private var options: Options {
        return Options(dateEncodingStrategy: dateEncodingStrategy,
                       includeCBORTag: includeCBORTag,
                       userInfo: userInfo)
    }

    // MARK: Initializaiton

    /**
     Creates a new, reusable CBOR encoder with the specified options.

     - Parameters:
       - dateEncodingStrategy: The strategy to use when encoding dates. This defaults
         to ``CBOREncoder/DateEncodingStrategy-swift.enum/secondsSince1970``.
       - includeCBORTag: A flag that indicates whether or not to prepend the
         "Self-Described CBOR" tag to the final encoded data. Defaults to `false`.
       - keySorter: A block to use for sorting keys in any given encoded map
         (dictionary). Defaults to `nil`.
       - userInfo: A default dictionary usecd to customize the encoding process.

     - Returns: The newly initialized encoder.
     */
    public init(dateEncodingStrategy: DateEncodingStrategy = .secondsSince1970, includeCBORTag: Bool = false, keySorter: ((Any, Any) -> Bool)? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.includeCBORTag = includeCBORTag
        self.keySorter = keySorter
        self.userInfo = userInfo
    }

    // MARK: Public Methods

    /**
     Returns a CBOR-encoded representation of the value you supply.

     If there's a problem encoding the value you supply, this method throws an error
     based on the type of problem.

     - Parameters:
       - value: The value to encode

     - Throws: Rethrows any errors thrown by the value to encode (or any nested
               values) or throws any errors encountered during encoding.

     - Returns: A CBOR-encoded representation of `value`.
     */
    open func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let options = self.options
        let encoder = __CBOREncoder(options: options)

        guard let topLevel = try encoder.encodeValueToCBOR(value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }

        var encodedValue: Data
        if let data = topLevel as? Data {
            encodedValue = data
        } else if let array = topLevel as? ArrayWrapper<Any> {
            encodedValue = try parse(array, options: options)
        } else if let dictionary = topLevel as? CodingKeyDictionary<Any> {
            encodedValue = try parse(dictionary, options: options)
        } else {
            // If we come here then there's an internal issue that needs to be worked out
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unable to encode the given top-level value to CBOR.", underlyingError: nil))
        }

        if options.includeCBORTag {
            // swiftlint:disable force_try
            encodedValue = try! CBOREncoder.encode(encodedValue, forTag: .selfDescribedCBOR).encodedData
            // swiftlint:enable force_try
        }

        return encodedValue
    }

    // MARK: Internal Methods

    internal static func encodeNil() -> Data {
        return Data([CBOR.Bits.null.rawValue])
    }

    internal static func encodeUndefined() -> Data {
        return Data([CBOR.Bits.undefined.rawValue])
    }

    internal static func encode(_ value: Bool) -> Data {
        return Data([value ? CBOR.Bits.true.rawValue : CBOR.Bits.false.rawValue])
    }

    internal static func encode(_ value: CBOR.NegativeUInt64) -> Data {
        let val: UInt64 = (value.rawValue == .min ? .max : (value.rawValue - 1))

        var data = encode(UInt64(val))
        data[0] |= CBOR.MajorType.negative.rawValue

        return data
    }

    internal static func encode(_ value: Int64) -> Data {
        var data: Data

        if value >= 0 {
            data = encode(UInt64(value))
        } else {
            let val: Int64 = (value == .min ? .max : (-1 - value))

            data = encode(UInt64(val))
            data[0] |= CBOR.MajorType.negative.rawValue
        }

        return data
    }

    internal static func encode(_ value: UInt64) -> Data {
        let bytes: [UInt8]

        if value <= 23 {
            bytes = [
                UInt8(value)
            ]
        } else if value <= UInt8.max {
            bytes = [
                UInt8(24),
                UInt8(value)
            ]
        } else if value <= UInt16.max {
            bytes = [
                UInt8(25),
                UInt8((value & 0xFF00) >> 8),
                UInt8((value & 0x00FF))
            ]
        } else if value <= UInt32.max {
            bytes = [
                UInt8(26),
                UInt8((value & 0xFF000000) >> 24),
                UInt8((value & 0x00FF0000) >> 16),
                UInt8((value & 0x0000FF00) >> 8),
                UInt8((value & 0x000000FF))
            ]
        } else /*if value <= UInt64.max*/ {
            bytes = [
                UInt8(27),
                UInt8((value & 0xFF00000000000000) >> 56),
                UInt8((value & 0x00FF000000000000) >> 48),
                UInt8((value & 0x0000FF0000000000) >> 40),
                UInt8((value & 0x000000FF00000000) >> 32),
                UInt8((value & 0x00000000FF000000) >> 24),
                UInt8((value & 0x0000000000FF0000) >> 16),
                UInt8((value & 0x000000000000FF00) >> 8),
                UInt8((value & 0x00000000000000FF))
            ]
        }

        return Data(bytes)
    }

    internal static func encode(_ value: Half) -> Data {
        var half = value
        let data = Data(bytes: &half, count: MemoryLayout.size(ofValue: half))

        return Data([CBOR.Bits.half.rawValue]) + data.reversed()
    }

    internal static func encode(_ value: Float) -> Data {
        var float = value
        let data = Data(bytes: &float, count: MemoryLayout.size(ofValue: float))

        return Data([CBOR.Bits.float.rawValue]) + data.reversed()
    }

    internal static func encode(_ value: Double) -> Data {
        var double = value
        let data = Data(bytes: &double, count: MemoryLayout.size(ofValue: double))

        return Data([CBOR.Bits.double.rawValue]) + data.reversed()
    }

    internal static func encode(_ value: String) -> Data {
        let data = Data(value.utf8)
        var header = encode(UInt64(data.count))
        header[0] |= CBOR.MajorType.string.rawValue

        return header + data
    }

    internal static func encode(_ value: Data) -> Data {
        var result = encode(UInt64(value.count))
        result[0] |= CBOR.MajorType.bytes.rawValue

        if !value.isEmpty {
            result += value
        }

        return result
    }

    internal static func encode(_ value: Date, using encoding: DateEncodingStrategy) -> Data {
        let encodedDate: Data

        switch encoding {
        case .rfc3339:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            encodedDate = encode(formatter.string(from: value))

        case .secondsSince1970:
            let interval = value.timeIntervalSince1970

            if TimeInterval(Int64(interval)) == interval {
                encodedDate = encode(Int64(interval))
            } else {
                encodedDate = encode(interval)
            }
        }

        return encoding.bits + encodedDate
    }

    internal static func encodeSimpleValue(_ value: UInt8) -> CBOR.CBOREncoded {
        let result: Data
        if value <= 23 {
            result = Data([CBOR.MajorType.additonal.rawValue | value])
        } else {
            result = Data([CBOR.MajorType.additonal.rawValue | 24, value])
        }

        return CBOR.CBOREncoded(encodedData: result)
    }

    // swiftlint:disable function_body_length
    internal static func encode(_ value: Any, forTag tag: CBOR.Tag) throws -> CBOR.CBOREncoded {
        var result = Data()

        switch tag {
        case .standardDateTime:
            if let date = value as? Date {
                result = encode(date, using: .rfc3339)
            } else if let string = value as? String {
                result = tag.bits + encode(string)
            } else {
                try CBOR.preconditionFailure("Expected to encode string for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .epochDateTime:
            if let date = value as? Date {
                result = encode(date, using: .secondsSince1970)
            } else if let int = value as? Int64 {
                result = tag.bits + encode(int)
            } else if let int = value as? Int {
                result = tag.bits + encode(Int64(int))
            } else if let int = value as? Int32 {
                result = tag.bits + encode(Int64(int))
            } else if let int = value as? Int16 {
                result = tag.bits + encode(Int64(int))
            } else if let int = value as? Int8 {
                result = tag.bits + encode(Int64(int))
            } else if let uint = value as? UInt64 {
                result = tag.bits + encode(uint)
            } else if let uint = value as? UInt {
                result = tag.bits + encode(UInt64(uint))
            } else if let uint = value as? UInt32 {
                result = tag.bits + encode(UInt64(uint))
            } else if let uint = value as? UInt16 {
                result = tag.bits + encode(UInt64(uint))
            } else if let uint = value as? UInt8 {
                result = tag.bits + encode(UInt64(uint))
            } else if let float = value as? Float {
                result = tag.bits + encode(float)
            } else if let double = value as? Double {
                result = tag.bits + encode(double)
            } else {
                try CBOR.preconditionFailure("Expected to encode integer or floating point number for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .positiveBignum, .negativeBignum:
            if let data = value as? Data {
                result = tag.bits + encode(data)
            } else {
                try CBOR.preconditionFailure("Expected to encode data for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .decimalFraction, .bigfloat:
            if let array = value as? [Any] {
                if array.count == 2 {
                    let encoderBlock = { (value: Any, i: Int) throws -> Data in
                        var result = Data()

                        if let value = value as? Int {
                            result = CBOREncoder.encode(Int64(value))
                        } else if let value = value as? Int8 {
                            result = CBOREncoder.encode(Int64(value))
                        } else if let value = value as? Int16 {
                            result = CBOREncoder.encode(Int64(value))
                        } else if let value = value as? Int32 {
                            result = CBOREncoder.encode(Int64(value))
                        } else if let value = value as? Int64 {
                            result = CBOREncoder.encode(value)
                        } else if let value = value as? UInt {
                            result = CBOREncoder.encode(UInt64(value))
                        } else if let value = value as? UInt8 {
                            result = CBOREncoder.encode(UInt64(value))
                        } else if let value = value as? UInt16 {
                            result = CBOREncoder.encode(UInt64(value))
                        } else if let value = value as? UInt32 {
                            result = CBOREncoder.encode(UInt64(value))
                        } else if let value = value as? UInt64 {
                            result = CBOREncoder.encode(value)
                        } else {
                            try CBOR.preconditionFailure("Expected to encode integer from array (index \(i)) for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
                        }

                        return result
                    }

                    result = try tag.bits + Data([UInt8(0x82)]) + encoderBlock(array[0], 0) + encoderBlock(array[1], 1)
                } else {
                     try CBOR.preconditionFailure("Expected to encode array containing two integers for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
                }
            } else {
                try CBOR.preconditionFailure("Expected to encode an array containing two integers for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .base64URLConversion, .base64Conversion, .base16Conversion:
            if let data = value as? Data {
                result = tag.bits + encode(data)
            } else if let string = value as? String {
                result = tag.bits + encode(string)
            } else {
                try CBOR.preconditionFailure("String and data are currently the only supported data types for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .encodedCBORData:
            if let data = value as? Data {
                result = tag.bits + encode(data)
            } else {
                try CBOR.preconditionFailure("Expected to encode data for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .uri:
            if let url = value as? URL {
                result = tag.bits + encode(url.absoluteString)
            } else if let string = value as? String {
                result = tag.bits + encode(string)
            } else {
                try CBOR.preconditionFailure("Expected to encode string for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .base64URL, .base64, .mimeMessage:
            if let string = value as? String {
                result = tag.bits + encode(string)
            } else {
                try CBOR.preconditionFailure("Expected to encode string for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .regularExpression:
            if let regex = value as? NSRegularExpression {
                result = tag.bits + encode(regex.pattern)
            } else if let string = value as? String {
                result = tag.bits + encode(string)
            } else {
                try CBOR.preconditionFailure("Expected to encode string for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }

        case .selfDescribedCBOR:
            if let data = value as? Data {
                result = tag.bits + data
            } else {
                try CBOR.preconditionFailure("Expected to encode data for tag: \(tag.bits.map({ String(format: "%02X", $0) }))")
            }
        }

        return CBOR.CBOREncoded(encodedData: result)
    }
    // swiftlint:enable function_body_length

    // MARK: Private Methods

    private func parse(_ array: ArrayWrapper<Any>, options: Options, codingPath: [CodingKey] = []) throws -> Data {
        var result: Data
        if array.indefiniteLength {
            result = Data([CBOR.MajorType.array.rawValue | 31])
        } else {
            result = CBOREncoder.encode(UInt64(array.count))
            result[0] |= CBOR.MajorType.array.rawValue
        }

        for (i, value) in array.enumerated() {
            if let data = value as? Data {
                result += data
            } else if let array = value as? ArrayWrapper<Any> {
                result += try parse(array, options: options, codingPath: codingPath + [CBOR.CodingKey(index: i)])
            } else if let dictionary = value as? CodingKeyDictionary<Any> {
                result += try parse(dictionary, options: options, codingPath: codingPath + [CBOR.CodingKey(index: i)])
            } else {
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [CBOR.CodingKey(index: i)], debugDescription: "Unable to encode the given value to CBOR.", underlyingError: nil))
            }
        }

        if array.indefiniteLength {
            result.append(CBOR.Bits.break.rawValue)
        }

        return result
    }

    private func parse(_ dictionary: CodingKeyDictionary<Any>, options: Options, codingPath: [CodingKey] = []) throws -> Data {
        var result: Data
        if dictionary.indefiniteLength {
            result = Data([CBOR.MajorType.map.rawValue | 31])
        } else {
            result = CBOREncoder.encode(UInt64(dictionary.count))
            result[0] |= CBOR.MajorType.map.rawValue
        }

        let keys: [CodingKey]
        if let keySorter = keySorter {
            keys = dictionary.keys.sorted {
                let key1: Any = $0.intValue ?? $0.stringValue
                let key2: Any = $1.intValue ?? $1.stringValue

                return keySorter(key1, key2)
            }
        } else {
            keys = dictionary.keys
        }

        for key in keys {
            if let value = key.intValue {
                result += CBOREncoder.encode(Int64(value))
            } else {
                result += CBOREncoder.encode(key.stringValue)
            }

            // swiftlint:disable force_unwrapping
            let value = dictionary[key]!
            // swiftlint:enable force_unwrapping

            if let data = value as? Data {
                result += data
            } else if let array = value as? ArrayWrapper<Any> {
                result += try parse(array, options: options, codingPath: codingPath + [key])
            } else if let dictionary = value as? CodingKeyDictionary<Any> {
                result += try parse(dictionary, options: options, codingPath: codingPath + [key])
            } else {
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Unable to encode the given value to CBOR.", underlyingError: nil))
            }
        }

        if dictionary.indefiniteLength {
            result.append(CBOR.Bits.break.rawValue)
        }

        return result
    }
}

// MARK: - CBOREncoderProtocol Definition

/**
 A protocol that the `encoder` parameter of `encode(to:)` will conform to when
 encoding values using the ``CBOREncoder`` class.
 */
public protocol CBOREncoderProtocol: Encoder {

    /**
     Configures the receiver to encode all containers encoded within the given block
     as indefinite length containers as specified in [RFS 8949 Section 3.2](
     https://datatracker.ietf.org/doc/html/rfc8949#section-3.2).

     - Parameters:
       - includingSubcontainers: A flag that indicates whether or not nested containers
         of containers created in this block should also be encoded as indefinite length
         containers.
       - block: The block in which all containers (and optionally nested containers)
         will be encoded as indefinite length containers.

     - Throws: Rethrows any errors thrown from within `block`.

     - Returns: The value returned from `block`, if any.
     */
    func indefiniteLengthContainerContext<R>(includingSubcontainers: Bool, _ block: () throws -> R) rethrows -> R

    /**
     Configures the receiver to encode all containers encoded within the given block
     as definite length containers. This is how all containers are encoded by
     default. This method can be useful to explicitly encode a nested container as a
     definite length container from within the context of a call to
     ``indefiniteLengthContainerContext(includingSubcontainers:_:)-46exh``

     - Parameters:
       - includingSubcontainers: A flag that indicates whether or not nested containers
         of containers created in this block should also be encoded as definite length
         containers.
       - block: The block in which all containers (and optionally nested containers)
         will be encoded as definite length containers.

     - Throws: Rethrows any errors thrown from within `block`.

     - Returns: The value returned from `block`, if any.
     */
    func definiteLengthContainerContext<R>(includingSubcontainers: Bool, _ block: () throws -> R) rethrows -> R
}

extension CBOREncoderProtocol {

    public func indefiniteLengthContainerContext<R>(includingSubcontainers flag: Bool = false, _ block: () throws -> R) rethrows -> R {
        return try indefiniteLengthContainerContext(includingSubcontainers: flag, block)
    }

    public func definiteLengthContainerContext<R>(includingSubcontainers flag: Bool = false, _ block: () throws -> R) rethrows -> R {
        return try definiteLengthContainerContext(includingSubcontainers: flag, block)
    }
}

// MARK: - __CBOREncoder Definition

internal class __CBOREncoder: CBOREncoderProtocol, SingleValueEncodingContainer {

    // MARK: Private Types

    fileprivate struct ContainerLength: OptionSet {

        // MARK: OptionSet Protocol Requirements

        var rawValue: UInt

        init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: Constants

        static let indefinite           = ContainerLength(rawValue: 0x01)
        static let includeSubcontainers = ContainerLength(rawValue: 0x02)
    }

    // MARK: Properties

    fileprivate private(set) var newContainerLength: ContainerLength = []

    fileprivate var storage: CBOREncodingStorage
    fileprivate let options: CBOREncoder.Options

    fileprivate var canEncodeNewValue: Bool {
        return storage.count == codingPath.count
    }

    // MARK: Internal Properties

    internal var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    internal var codingPath: [CodingKey]

    // MARK: Initialization

    fileprivate init(options: CBOREncoder.Options, codingPath: [CodingKey] = []) {
        self.storage = CBOREncodingStorage()
        self.options = options
        self.codingPath = codingPath
    }

    // MARK: Methods

    fileprivate func encode(_ dictionary: [String: Encodable]) throws -> Any? {
        let depth = storage.count
        let container = storage.pushKeyedContainer()

        do {
            for (key, value) in dictionary {
                let codingKey = CBOR.CodingKey(stringValue: key)

                codingPath.append(codingKey)
                defer { codingPath.removeLast() }

                container[codingKey] = try encodeValueToCBOR(value)
            }
        } catch {
            if storage.count > depth {
                _ = storage.popContainer()
            }

            throw error
        }

        guard storage.count > depth else { return nil }
        return storage.popContainer()
    }

    fileprivate func encode(_ dictionary: [Int: Encodable]) throws -> Any? {
        let depth = storage.count
        let container = storage.pushKeyedContainer()

        do {
            for (key, value) in dictionary {
                let codingKey = CBOR.CodingKey(intValue: key)

                codingPath.append(codingKey)
                defer { codingPath.removeLast() }

                container[codingKey] = try encodeValueToCBOR(value)
            }
        } catch {
            if storage.count > depth {
                _ = storage.popContainer()
            }

            throw error
        }

        guard storage.count > depth else { return nil }
        return storage.popContainer()
    }

    fileprivate func encode(_ value: CBOR.IndefiniteLengthData) throws -> Any? {
        var data = Data([CBOR.MajorType.bytes.rawValue | 31])
        value.chunks.forEach { data.append(CBOREncoder.encode($0)) }
        data.append(CBOR.Bits.break.rawValue)

        return data
    }

    fileprivate func encode(_ value: CBOR.IndefiniteLengthString) throws -> Any? {
        var data = Data([CBOR.MajorType.string.rawValue | 31])
        value.chunks.forEach {
            var encodedChunk = CBOREncoder.encode($0)
            encodedChunk[0] &= ~CBOR.MajorType.bytes.rawValue
            encodedChunk[0] |= CBOR.MajorType.string.rawValue

            data.append(encodedChunk)
        }
        data.append(CBOR.Bits.break.rawValue)

        return data
    }

    fileprivate func encodeValueToCBOR(_ value: Encodable) throws -> Any? {
        let result: Any?

        if let encoded = value as? CBOR.CBOREncoded {
            result = encoded.encodedData
        } else if let date = value as? Date {
            result = CBOREncoder.encode(date, using: options.dateEncodingStrategy)
        } else if let data = value as? Data {
            result = CBOREncoder.encode(data)
        } else if let url = value as? URL {
            // swiftlint:disable force_try
            result = try! CBOREncoder.encode(url, forTag: .uri).encodedData
            // swiftlint:enable force_try
        } else if value is NSNull || value is CBOR.Null {
            result = CBOREncoder.encodeNil()
        } else if value is CBOR.Undefined {
            result = CBOREncoder.encodeUndefined()
        } else if let dict = value as? [String: Encodable] {
            result = try encode(dict)
        } else if let dict = value as? [Int: Encodable] {
            result = try encode(dict)
        } else if let data = value as? CBOR.IndefiniteLengthData {
            result = try encode(data)
        } else if let string = value as? CBOR.IndefiniteLengthString {
            result = try encode(string)
        } else if let value = value as? CBOR.NegativeUInt64 {
            result = CBOREncoder.encode(value)
        } else if let value = value as? Half {
            result = CBOREncoder.encode(value)
        } else {
            let action: () throws -> Any? = {
                let depth = self.storage.count

                do {
                    try value.encode(to: self)
                } catch {
                    if self.storage.count > depth {
                        _ = self.storage.popContainer()
                    }

                    throw error
                }

                guard self.storage.count > depth else { return nil }
                return self.storage.popContainer()
            }

            if newContainerLength.contains(.includeSubcontainers) {
                result = try action()
            } else {
                result = try definiteLengthContainerContext(action)
            }
        }

        return result
    }

    // MARK: Encoder Protocol Requirements

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let topContainer: CodingKeyDictionary<Any>
        if canEncodeNewValue {
            topContainer = storage.pushKeyedContainer(indefiniteLength: newContainerLength.contains(.indefinite))
        } else {
            guard let container = storage.containers.last as? CodingKeyDictionary<Any> else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = __CBORKeyedEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let topContainer: ArrayWrapper<Any>
        if canEncodeNewValue {
            topContainer = storage.pushUnkeyedContainer(indefiniteLength: newContainerLength.contains(.indefinite))
        } else {
            guard let container = storage.containers.last as? ArrayWrapper<Any> else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        return __CBORUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }

    // MARK: CBOREncoderProtocol Protocol Requirements

    func indefiniteLengthContainerContext<R>(includingSubcontainers: Bool, _ block: () throws -> R) rethrows -> R {
        let currentValue = newContainerLength
        newContainerLength = [.indefinite]

        if includingSubcontainers {
            newContainerLength.insert(.includeSubcontainers)
        }

        defer { newContainerLength = currentValue }
        return try block()
    }

    func definiteLengthContainerContext<R>(includingSubcontainers: Bool, _ block: () throws -> R) rethrows -> R {
        let currentValue = newContainerLength
        newContainerLength = []

        if includingSubcontainers {
            newContainerLength.insert(.includeSubcontainers)
        }

        defer { newContainerLength = currentValue }
        return try block()
    }

    // MARK: SingleValueEncodingContainer Protocol Requirements

    func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encodeNil())
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode(_ value: Int) throws {
        try encode(Int64(value))
    }

    func encode(_ value: Int8) throws {
        try encode(Int64(value))
    }

    func encode(_ value: Int16) throws {
        try encode(Int64(value))
    }

    func encode(_ value: Int32) throws {
        try encode(Int64(value))
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode(_ value: UInt) throws {
        try encode(UInt64(value))
    }

    func encode(_ value: UInt8) throws {
        try encode(UInt64(value))
    }

    func encode(_ value: UInt16) throws {
        try encode(UInt64(value))
    }

    func encode(_ value: UInt32) throws {
        try encode(UInt64(value))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: CBOREncoder.encode(value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        assertCanEncodeNewValue()

        if let container = try encodeValueToCBOR(value) {
            storage.push(container: container)
        }
    }

    // MARK: Private Methods

    private func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
}

// MARK: - CBOREncodingStorage Definition

private struct CBOREncodingStorage {

    // MARK: Properties

    // Valid element types are Data, ArrayWrapper<Any>, and CodingKeyDictionary<Any>
    private(set) var containers: [Any] = []

    var count: Int {
        return containers.count
    }

    // MARK: Initialization

    init() { /* Nothing to do */ }

    // MARK: Methods

    mutating func pushKeyedContainer(indefiniteLength: Bool = false) -> CodingKeyDictionary<Any> {
        let dictionary = CodingKeyDictionary<Any>(indefiniteLength: indefiniteLength)
        containers.append(dictionary)

        return dictionary
    }

    mutating func pushUnkeyedContainer(indefiniteLength: Bool = false) -> ArrayWrapper<Any> {
        let array = ArrayWrapper<Any>(indefiniteLength: indefiniteLength)
        containers.append(array)

        return array
    }

    mutating func push(container: Any) {
        precondition(container is Data || container is ArrayWrapper<Any> || container is CodingKeyDictionary<Any>, "Pushing a container of invalid type")
        containers.append(container)
    }

    mutating func popContainer() -> Any {
        precondition(!containers.isEmpty, "Empty container stack.")
        // swiftlint:disable force_unwrapping
        return containers.popLast()!
        // swiftlint:enable force_unwrapping
    }
}

// MARK: - __CBORKeyedEncodingContainer Definition

private struct __CBORKeyedEncodingContainer<K>: KeyedEncodingContainerProtocol where K: CodingKey {

    typealias Key = K

    // MARK: Private Properties

    private let encoder: __CBOREncoder
    private let container: CodingKeyDictionary<Any>

    // MARK: Properties

    private(set) var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing encoder: __CBOREncoder, codingPath: [CodingKey], wrapping container: CodingKeyDictionary<Any>) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: KeyedEncodingContainerProtocol Protocol Requirements

    mutating func encodeNil(forKey key: Key)               throws { container[key] = CBOREncoder.encodeNil() }
    mutating func encode(_ value: Bool, forKey key: Key)   throws { container[key] = CBOREncoder.encode(value) }
    mutating func encode(_ value: Int, forKey key: Key)    throws { container[key] = CBOREncoder.encode(Int64(value)) }
    mutating func encode(_ value: Int8, forKey key: Key)   throws { container[key] = CBOREncoder.encode(Int64(value)) }
    mutating func encode(_ value: Int16, forKey key: Key)  throws { container[key] = CBOREncoder.encode(Int64(value)) }
    mutating func encode(_ value: Int32, forKey key: Key)  throws { container[key] = CBOREncoder.encode(Int64(value)) }
    mutating func encode(_ value: Int64, forKey key: Key)  throws { container[key] = CBOREncoder.encode(value) }
    mutating func encode(_ value: UInt, forKey key: Key)   throws { container[key] = CBOREncoder.encode(UInt64(value)) }
    mutating func encode(_ value: UInt8, forKey key: Key)  throws { container[key] = CBOREncoder.encode(UInt64(value)) }
    mutating func encode(_ value: UInt16, forKey key: Key) throws { container[key] = CBOREncoder.encode(UInt64(value)) }
    mutating func encode(_ value: UInt32, forKey key: Key) throws { container[key] = CBOREncoder.encode(UInt64(value)) }
    mutating func encode(_ value: UInt64, forKey key: Key) throws { container[key] = CBOREncoder.encode(value) }
    mutating func encode(_ value: String, forKey key: Key) throws { container[key] = CBOREncoder.encode(value) }
    mutating func encode(_ value: Float, forKey key: Key)  throws { container[key] = CBOREncoder.encode(value) }
    mutating func encode(_ value: Double, forKey key: Key) throws { container[key] = CBOREncoder.encode(value) }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }

        container[key] = try encoder.encodeValueToCBOR(value)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = CodingKeyDictionary<Any>(indefiniteLength: encoder.newContainerLength.contains(.indefinite))
        container[key] = dictionary

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let keyedContainer = __CBORKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer<NestedKey>(keyedContainer)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = ArrayWrapper<Any>(indefiniteLength: encoder.newContainerLength.contains(.indefinite))
        container[key] = array

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        return __CBORUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    mutating func superEncoder() -> Encoder {
        return __CBORReferencingEncoder(referencing: encoder, at: CBOR.CodingKey.super, wrapping: container)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        return __CBORReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }
}

// MARK: - __CBORUnkeyedEncodingContainer Definition

private struct __CBORUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    // MARK: Private Properties

    private let encoder: __CBOREncoder
    private var container: ArrayWrapper<Any>

    // MARK: Properties

    private(set) var codingPath: [CodingKey]
    var count: Int {
        return container.count
    }

    // MARK: Initialization

    init(referencing encoder: __CBOREncoder, codingPath: [CodingKey], wrapping container: ArrayWrapper<Any>) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: UnkeyedEncodingContainer Protocol Requirements

    mutating func encodeNil()             throws { container.append(CBOREncoder.encodeNil()) }
    mutating func encode(_ value: Bool)   throws { container.append(CBOREncoder.encode(value)) }
    mutating func encode(_ value: Int)    throws { container.append(CBOREncoder.encode(Int64(value))) }
    mutating func encode(_ value: Int8)   throws { container.append(CBOREncoder.encode(Int64(value))) }
    mutating func encode(_ value: Int16)  throws { container.append(CBOREncoder.encode(Int64(value))) }
    mutating func encode(_ value: Int32)  throws { container.append(CBOREncoder.encode(Int64(value))) }
    mutating func encode(_ value: Int64)  throws { container.append(CBOREncoder.encode(value)) }
    mutating func encode(_ value: UInt)   throws { container.append(CBOREncoder.encode(UInt64(value))) }
    mutating func encode(_ value: UInt8)  throws { container.append(CBOREncoder.encode(UInt64(value))) }
    mutating func encode(_ value: UInt16) throws { container.append(CBOREncoder.encode(UInt64(value))) }
    mutating func encode(_ value: UInt32) throws { container.append(CBOREncoder.encode(UInt64(value))) }
    mutating func encode(_ value: UInt64) throws { container.append(CBOREncoder.encode(value)) }
    mutating func encode(_ value: String) throws { container.append(CBOREncoder.encode(value)) }
    mutating func encode(_ value: Float)  throws { container.append(CBOREncoder.encode(value)) }
    mutating func encode(_ value: Double) throws { container.append(CBOREncoder.encode(value)) }

    mutating func encode<T: Encodable>(_ value: T) throws {
        encoder.codingPath.append(CBOR.CodingKey(index: count))
        defer { encoder.codingPath.removeLast() }

        if let encodedValue = try encoder.encodeValueToCBOR(value) {
            container.append(encodedValue)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        encoder.codingPath.append(CBOR.CodingKey(index: count))
        defer { encoder.codingPath.removeLast() }

        let dictionary = CodingKeyDictionary<Any>(indefiniteLength: encoder.newContainerLength.contains(.indefinite))
        container.append(dictionary)

        let keyedContainer = __CBORKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer<NestedKey>(keyedContainer)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        encoder.codingPath.append(CBOR.CodingKey(index: count))
        defer { encoder.codingPath.removeLast() }

        let array = ArrayWrapper<Any>(indefiniteLength: encoder.newContainerLength.contains(.indefinite))
        container.append(array)

        return __CBORUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    mutating func superEncoder() -> Encoder {
        return __CBORReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }
}

// MARK: - __CBORReferencingEncoder Definition

private class __CBORReferencingEncoder: __CBOREncoder {

    // MARK: Private Types

    private enum Reference {

        // MARK: Cases

        case array(ArrayWrapper<Any>, Int)
        case dictionary(CodingKeyDictionary<Any>, String)
    }

    // MARK: Private Properties

    private let reference: Reference

    // MARK: Properties

    let encoder: __CBOREncoder

    // MARK: Initialization

    init(referencing encoder: __CBOREncoder, at index: Int, wrapping array: ArrayWrapper<Any>) {
        self.encoder = encoder
        self.reference = .array(array, index)

        super.init(options: encoder.options, codingPath: encoder.codingPath)

        codingPath.append(CBOR.CodingKey(index: index))
    }

    init(referencing encoder: __CBOREncoder, at key: CodingKey, wrapping dictionary: CodingKeyDictionary<Any>) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)

        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(key)
    }

    deinit {
        let value: Any

        switch storage.count {
        case 0:  return /* Nothing to do */
        case 1:  value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch reference {
        case let .array(array, index):
            array.insert(value, at: index)

        case let .dictionary(dictionary, key):
            dictionary[CBOR.CodingKey(stringValue: key)] = value
        }
    }

    // MARK: __CBOREncoder Overrides

    override var canEncodeNewValue: Bool {
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }
}

// MARK: - CBOREncoder Extension

#if canImport(Combine)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CBOREncoder: TopLevelEncoder {

    public typealias Output = Data
}
#endif // #if canImport(Combine)
