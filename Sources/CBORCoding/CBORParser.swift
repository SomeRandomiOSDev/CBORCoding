//
//  CBORParser.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation
import Half

// MARK: - CBORParser Definition

internal class CBORParser {

    // MARK: Internal Methods

    // swiftlint:disable function_body_length
    internal class func parse(_ data: Data, codingPath: [CodingKey] = []) throws -> Any? {
        guard !data.isEmpty else { return nil }

        var storage = Storage()
        var index = data.startIndex

        do {
            while index < data.endIndex {
                let majorType = CBOR.majorType(for: data[index])

                switch majorType {
                case .unsigned:
                    let unsigned = try decode(UInt64.self, from: data[index...])
                    try storage.append(unsigned.value)

                    index += unsigned.decodedBytes

                case .negative:
                    let signed: (value: Any, decodedBytes: Int)

                    do {
                        let result = try decode(Int64.self, from: data[index...])
                        signed = (result.value, result.decodedBytes)
                    } catch let firstError {
                        do {
                            let result = try decode(CBOR.NegativeUInt64.self, from: data[index...])
                            signed = (result.value, result.decodedBytes)
                        } catch {
                            throw firstError
                        }
                    }

                    try storage.append(signed.value)
                    index += signed.decodedBytes

                case .bytes:
                    let bytes = try decode(Data.self, from: data[index...])
                    try storage.append(bytes.value)

                    index += bytes.decodedBytes

                case .string:
                    let string = try decode(String.self, from: data[index...])
                    try storage.append(string.value)

                    index += string.decodedBytes

                case .array:
                    let additionalInfo = CBOR.additionalInfo(for: data[index])
                    if additionalInfo == 31 { // Indefinite length array
                        try storage.startUnkeyedContainer(ofLength: nil)

                        index += 1
                    } else {
                        let unsigned = try decode(UInt64.self, from: data[index...], knownMajorType: majorType)
                        try storage.startUnkeyedContainer(ofLength: unsigned.value)

                        index += unsigned.decodedBytes
                    }

                case .map:
                    let additionalInfo = CBOR.additionalInfo(for: data[index])
                    if additionalInfo == 31 { // Indefinite length map
                        try storage.startKeyedContainer(ofLength: nil)

                        index += 1
                    } else {
                        let unsigned = try decode(UInt64.self, from: data[index...], knownMajorType: majorType)
                        try storage.startKeyedContainer(ofLength: unsigned.value)

                        index += unsigned.decodedBytes
                    }

                case .tag:
                    if let tag = CBOR.Tag(bits: data[index...]) {
                        index += tag.bits.count

                        switch tag {
                        case .standardDateTime, .epochDateTime:
                            let date = try decode(Date.self, tag: tag, from: data[index...])
                            try storage.append(date.value)

                            index += date.decodedBytes

                        case .positiveBignum, .negativeBignum:
                            let bignum = try decode(CBOR.Bignum.self, tag: tag, from: data[index...])
                            try storage.append(bignum.value)

                            index += bignum.decodedBytes

                        case .decimalFraction:
                            let decimal = try decode(CBOR.DecimalFraction<Int64, Int64>.self, from: data[index...])
                            try storage.append(decimal.value)

                            index += decimal.decodedBytes

                        case .bigfloat:
                            let bigfloat = try decode(CBOR.Bigfloat<Int64, Int64>.self, from: data[index...])
                            try storage.append(bigfloat.value)

                            index += bigfloat.decodedBytes

                        case .base64URLConversion, .base64Conversion, .base16Conversion:
                            do {
                                let string = try decode(String.self, from: data[index...])
                                try storage.append(string.value)

                                index += string.decodedBytes
                            } catch {
                                do {
                                    let bytes = try decode(Data.self, from: data[index...])
                                    try storage.append(bytes.value)

                                    index += bytes.decodedBytes
                                } catch {
                                    throw CBOR.DecodingError.dataCorrupted(description: "Unable to decode string or data for tag \"\(tag.description)\"")
                                }
                            }

                        case .encodedCBORData:
                            let bytes = try decode(Data.self, from: data[index...])
                            try storage.append(bytes.value)

                            index += bytes.decodedBytes

                        case .uri:
                            let url = try decode(URL.self, from: data[index...])
                            try storage.append(url.value)

                            index += url.decodedBytes

                        case .base64URL, .base64, .regularExpression:
                            let string = try decode(String.self, from: data[index...])
                            let decodedString = try string.value.decodedStringValue()

                            if tag == .base64URL {
                                let data = Data(base64Encoded: decodedString.replacingOccurrences(of: "-", with: "+")
                                                                            .replacingOccurrences(of: "_", with: "/")
                                                                            .appending(String(repeating: "=", count: decodedString.count % 4)))

                                guard let validatedData = data else {
                                    throw CBOR.DecodingError.dataCorrupted(description: "Invalid Base64-URL encoded string")
                                }

                                try storage.append(validatedData)
                            } else if tag == .base64 {
                                guard let data = Data(base64Encoded: decodedString) else {
                                    throw CBOR.DecodingError.dataCorrupted(description: "Invalid Base64 encoded string")
                                }

                                try storage.append(data)
                            } else /* if tag == .regularExpression */ {
                                guard (try? NSRegularExpression(pattern: decodedString, options: [])) != nil else {
                                    throw CBOR.DecodingError.dataCorrupted(description: "Invalid Regular Expression")
                                }

                                try storage.append(decodedString)
                            }

                            index += string.decodedBytes

                        case .mimeMessage:
                            let string = try decode(String.self, from: data[index...])
                            try storage.append(string.value)

                            index += string.decodedBytes

                        case .selfDescribedCBOR:
                            break // skip the tag and continue
                        }
                    } else {
                        let unsigned: UInt64
                        do {
                            unsigned = try decode(UInt64.self, from: data[index...], knownMajorType: .tag).value
                        } catch {
                            throw CBOR.DecodingError.dataCorrupted(description: "Invalid CBOR tag")
                        }

                        throw CBOR.DecodingError.dataCorrupted(description: "Invalid CBOR tag <\(unsigned)>")
                    }

                case .additonal:
                    let additionalInfo = CBOR.additionalInfo(for: data[index])
                    switch additionalInfo {
                    case 0...19:
                        try storage.append(CBOR.SimpleValue(rawValue: additionalInfo))
                        index += 1

                    case 20:
                        try storage.append(false)
                        index += 1

                    case 21:
                        try storage.append(true)
                        index += 1

                    case 22:
                        try storage.append(CBOR.Null())
                        index += 1

                    case 23:
                        try storage.append(CBOR.Undefined())
                        index += 1

                    case 24:
                        let simple = try decode(CBOR.SimpleValue.self, from: data[index...])
                        try storage.append(simple.value)

                        index += simple.decodedBytes

                    case 25:
                        let half = try decode(Half.self, from: data[index...])
                        try storage.append(half.value)

                        index += half.decodedBytes

                    case 26:
                        let float = try decode(Float.self, from: data[index...])
                        try storage.append(float.value)

                        index += float.decodedBytes

                    case 27:
                        let double = try decode(Double.self, from: data[index...])
                        try storage.append(double.value)

                        index += double.decodedBytes

                    case 31: // Break
                        try storage.endCurrentContainer()
                        index += 1

                    default:
                        throw CBOR.DecodingError.dataCorrupted(description: "Invalid decoded value for major type 7 (\(additionalInfo))")
                    }
                }
            }
        } catch let error as CBOR.DecodingError {
            throw Swift.DecodingError(internalError: error, at: codingPath)
        }

        return try storage.finalize()
    }

    internal class func type(for bytes: Data) throws -> Any.Type {
        do {
            guard !bytes.isEmpty else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: nil)
            }
            let type: Any.Type

            let majorType = CBOR.majorType(for: bytes[bytes.startIndex])
            let additionalInfo = CBOR.additionalInfo(for: bytes[bytes.startIndex])

            switch majorType {
            case .unsigned:
                switch additionalInfo {
                case 0...24: type = UInt8.self
                case 25:     type = UInt16.self
                case 26:     type = UInt32.self
                case 27:     type = UInt64.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded length for expected unsigned integer")
                }

            case .negative:
                switch additionalInfo {
                case 0...24: type = Int8.self
                case 25:     type = Int16.self
                case 26:     type = Int32.self
                case 27:     type = Int64.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded length for expected signed integer")
                }

            case .bytes:
                switch additionalInfo {
                case 0...27: type = Data.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded byte length for expected data")
                }

            case .string:
                switch additionalInfo {
                case 0...27: type = String.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded byte length for expected string")
                }

            case .array:
                switch additionalInfo {
                case 0...27: type = Array<Any>.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded byte length for expected array")
                }

            case .map:
                switch additionalInfo {
                case 0...27: type = Dictionary<String, Any>.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded byte length for expected map")
                }

            case .tag:
                switch additionalInfo {
                case 0, 1:    type = Date.self
                case 2, 3:    type = Data.self
                case 4, 5:    type = Array<Int>.self
                case 21...23: type = Data.self
                case 24:
                    guard bytes.count > 1 else {
                        throw CBOR.DecodingError.insufficientEncodedBytes(expected: nil)
                    }

                    switch bytes[bytes.index(after: bytes.startIndex)] {
                    case 24:      type = Data.self
                    case 32...36: type = String.self
                    default:      throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded tag")
                    }

                case 25:
                    guard bytes.count > 2 else {
                        throw CBOR.DecodingError.insufficientEncodedBytes(expected: nil)
                    }

                    switch (bytes[bytes.index(bytes.startIndex, offsetBy: 1)], bytes[bytes.index(bytes.startIndex, offsetBy: 2)]) {
                    case (0xD9, 0xF7): type = Data.self
                    default:           throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded tag")
                    }

                default:
                    throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded tag")
                }

            case .additonal:
                switch additionalInfo {
                case 0...19: type = CBOR.SimpleValue.self
                case 20, 21: type = Bool.self
                case 22:     type = CBOR.Null.self
                case 23:     type = CBOR.Undefined.self
                case 24:     type = CBOR.SimpleValue.self
                case 25, 26: type = Float.self
                case 27:     type = Double.self
                case 31:     type = CBOR.Break.self
                default:     throw CBOR.DecodingError.dataCorrupted(description: "Invalid encoded data type")
                }
            }

            return type
        } catch let error as CBOR.DecodingError {
            throw Swift.DecodingError(internalError: error, at: [])
        }
    }
    // swiftlint:enable function_body_length

    // MARK: Private Methods

    // swiftlint:disable function_body_length
    private class func decode(_ type: String.Type, from data: Data) throws -> (value: CBORDecodedString, decodedBytes: Int) {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .string else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let additionalInfo = CBOR.additionalInfo(for: data[data.startIndex])
        let result: (value: CBORDecodedString, decodedBytes: Int)

        if additionalInfo == 31 {
            // Indefinite length string

            guard data.count > 1 else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }

            var index = data.index(after: data.startIndex)
            var resultString = CBOR.IndefiniteLengthString()

            while true {
                guard index < data.endIndex else {
                    throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
                }
                guard data[index] != CBOR.Bits.break.rawValue else {
                    index = data.index(after: index) // for the `break` byte
                    break
                }

                let count = try decode(UInt64.self, from: Data(data[index...]), knownMajorType: majorType)
                if count.value == 0 {
                    resultString.chunks.append(Data())
                    index += count.decodedBytes
                } else {
                    guard let nextIndex = data.index(index, offsetBy: count.decodedBytes + Int(count.value), limitedBy: data.endIndex), data.endIndex > nextIndex else {
                        throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
                    }

                    let utf8Data = Data(data[data.index(index, offsetBy: count.decodedBytes) ..< nextIndex])

                    resultString.chunks.append(utf8Data)
                    index = nextIndex
                }
            }

            result = (resultString, data.distance(from: data.startIndex, to: index))
        } else {
            // Definite length string

            let count = try decode(UInt64.self, from: data, knownMajorType: majorType)
            if count.value == 0 {
                result = ("", count.decodedBytes)
            } else {
                guard let nextIndex = data.index(data.startIndex, offsetBy: Int(count.value + UInt64(count.decodedBytes)), limitedBy: data.endIndex), data.endIndex >= nextIndex else {
                    throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
                }

                let utf8Data = Data(data[data.index(data.startIndex, offsetBy: count.decodedBytes) ..< nextIndex])
                guard let string = String(data: utf8Data, encoding: .utf8) else {
                    throw CBOR.DecodingError.invalidUTF8String
                }

                result = (string, count.decodedBytes + Int(count.value))
            }
        }

        return result
    }
    // swiftlint:enable function_body_length

    private class func decode(_ type: Data.Type, from data: Data) throws -> (value: CBORDecodedData, decodedBytes: Int) {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .bytes else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let additionalInfo = CBOR.additionalInfo(for: data[data.startIndex])
        let result: (value: CBORDecodedData, decodedBytes: Int)

        if additionalInfo == 31 {
            // Indefinite length byte data

            guard data.count > 1 else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }

            var index = data.index(after: data.startIndex)
            var resultData = CBOR.IndefiniteLengthData()

            repeat {
                guard index < data.endIndex else {
                    throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
                }
                guard data[index] != CBOR.Bits.break.rawValue else {
                    index = data.index(after: index) // for the `break` byte
                    break
                }

                let decoded = try decode(type, from: Data(data[index...]))

                resultData.chunks.append(decoded.value.decodedDataValue())
                index = data.index(index, offsetBy: decoded.decodedBytes)
            } while true

            result = (resultData, data.distance(from: data.startIndex, to: index))
        } else {
            // Definite length byte data

            let count = try decode(UInt64.self, from: data, knownMajorType: majorType)
            if count.value == 0 {
                result = (Data(), count.decodedBytes)
            } else {
                guard let nextIndex = data.index(data.startIndex, offsetBy: count.decodedBytes + Int(count.value), limitedBy: data.endIndex), data.endIndex >= nextIndex else {
                    throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
                }

                result = (data[data.index(data.startIndex, offsetBy: count.decodedBytes) ..< nextIndex], count.decodedBytes + Int(count.value))
            }
        }

        return result
    }

    private class func decode(_ type: Date.Type, tag: CBOR.Tag, from data: Data) throws -> (value: Date, decodedBytes: Int) {
        precondition(tag == .standardDateTime || tag == .epochDateTime)

        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let result: (value: Date, decodedBytes: Int)
        if tag == .standardDateTime { // RFC3339
            let dateString = try decode(String.self, from: data)

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            guard let date = formatter.date(from: try dateString.value.decodedStringValue()) else {
                throw CBOR.DecodingError.invalidRFC3339DateString
            }

            result = (date, dateString.decodedBytes)
        } else /* if tag == .epochDateTime */ { // Epoch
            do {
                let timeInterval = try decode(Double.self, from: data)
                result = (Date(timeIntervalSince1970: TimeInterval(timeInterval.value)), timeInterval.decodedBytes)
            } catch {
                do {
                    let timeInterval = try decode(Int64.self, from: data)
                    result = (Date(timeIntervalSince1970: TimeInterval(timeInterval.value)), timeInterval.decodedBytes)
                } catch {
                    do {
                        let timeInterval = try decode(UInt64.self, from: data)
                        result = (Date(timeIntervalSince1970: TimeInterval(timeInterval.value)), timeInterval.decodedBytes)
                    } catch {
                        throw CBOR.DecodingError.typeMismatch(expected: [TimeInterval.self, Int.self, UInt.self], actual: try self.type(for: data))
                    }
                }
            }
        }

        return result
    }

    private class func decode(_ type: URL.Type, from data: Data) throws -> (value: URL, decodedBytes: Int) {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .string else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let string = try decode(String.self, from: data)

        guard let url = URL(string: try string.value.decodedStringValue()) else {
            throw CBOR.DecodingError.dataCorrupted(description: "Invalid URL string.")
        }

        return (url, string.decodedBytes)
    }

    private class func decode(_ type: CBOR.NegativeUInt64.Type, from data: Data) throws -> (value: CBOR.NegativeUInt64, decodedBytes: Int) {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .negative else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let unsigned = try decode(UInt64.self, from: data, knownMajorType: majorType)

        return (CBOR.NegativeUInt64(rawValue: unsigned.value == .max ? .min : (unsigned.value + 1)), unsigned.decodedBytes)
    }

    private class func decode(_ type: CBOR.SimpleValue.Type, from data: Data) throws -> (value: CBOR.SimpleValue, decodedBytes: Int) {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .additonal else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let additionalInfo = CBOR.additionalInfo(for: data[data.startIndex])
        let result: (value: CBOR.SimpleValue, decodedBytes: Int)

        switch additionalInfo {
        case 24:
            guard data.count > 1 else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }

            result = (CBOR.SimpleValue(rawValue: data[data.index(after: data.startIndex)]), 2)

        default:
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        return result
    }

    private class func decode(_ type: CBOR.Bignum.Type, tag: CBOR.Tag, from data: Data) throws -> (value: CBOR.Bignum, decodedBytes: Int) {
        precondition(tag == .positiveBignum || tag == .negativeBignum)

        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let bytes = try decode(Data.self, from: data)

        return (CBOR.Bignum(isPositive: tag == .positiveBignum, content: bytes.value.decodedDataValue()), bytes.decodedBytes)
    }

    // swiftlint:disable function_body_length
    private class func decode<T>(_ type: T.Type, from data: Data) throws -> (value: T, decodedBytes: Int) where T: BinaryFloatingPoint, T.RawExponent: FixedWidthInteger, T.RawSignificand: FixedWidthInteger {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let header = data[data.startIndex]
        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .additonal else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let result: (value: T, decodedBytes: Int)
        if header == CBOR.Bits.half.rawValue { // Half
            if data.count >= 3 {
                // swiftlint:disable force_unwrapping
                let half = data[data.index(data.startIndex, offsetBy: 1) ..< data.index(data.startIndex, offsetBy: 3)].reversed().withUnsafeBytes { $0.bindMemory(to: Half.self).baseAddress!.pointee }
                // swiftlint:enable force_unwrapping

                if half.isNaN {
                    if half.isSignalingNaN {
                        result = (.signalingNaN, 3)
                    } else {
                        result = (.nan, 3)
                    }
                } else if let value = T(exactly: half) {
                    result = (value, 3)
                } else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded number <\(half)> does not fit in \(type).")
                }
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else if header == CBOR.Bits.float.rawValue { // Single
            if data.count >= 5 {
                // swiftlint:disable force_unwrapping
                let float = data[data.index(data.startIndex, offsetBy: 1) ..< data.index(data.startIndex, offsetBy: 5)].reversed().withUnsafeBytes { $0.bindMemory(to: Float.self).baseAddress!.pointee }
                // swiftlint:enable force_unwrapping

                if float.isNaN {
                    if float.isSignalingNaN {
                        result = (.signalingNaN, 5)
                    } else {
                        result = (.nan, 5)
                    }
                } else if let value = T(exactly: float) {
                    result = (value, 5)
                } else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded number <\(float)> does not fit in \(type).")
                }
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else if header == CBOR.Bits.double.rawValue { // Double
            if data.count >= 9 {
                // swiftlint:disable force_unwrapping
                let double = data[data.index(data.startIndex, offsetBy: 1) ..< data.index(data.startIndex, offsetBy: 9)].reversed().withUnsafeBytes { $0.bindMemory(to: Double.self).baseAddress!.pointee }
                // swiftlint:enable force_unwrapping

                if double.isNaN {
                    if double.isSignalingNaN {
                        result = (.signalingNaN, 9)
                    } else {
                        result = (.nan, 9)
                    }
                } else if let value = T(exactly: double) {
                    result = (value, 9)
                } else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded number <\(double)> does not fit in \(type).")
                }
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        return result
    }

    private class func decode<T>(_ type: T.Type, from data: Data, knownMajorType: CBOR.MajorType = .unsigned) throws -> (value: T, decodedBytes: Int) where T: UnsignedInteger & FixedWidthInteger {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == knownMajorType else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let additionalInfo = CBOR.additionalInfo(for: data[data.startIndex])
        let result: (value: T?, decodedBytes: Int)

        if additionalInfo <= 23 {
            result = (T(exactly: additionalInfo), 1)
        } else if additionalInfo == 24 {
            if data.count >= 2 {
                result = (T(exactly: data[data.index(data.startIndex, offsetBy: 1)]), 2)
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else if additionalInfo == 25 {
            if data.count >= 3 {
                result = (T(exactly: UInt16(data[data.index(data.startIndex, offsetBy: 1)]) << 8 |
                                     UInt16(data[data.index(data.startIndex, offsetBy: 2)])), 3)
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else if additionalInfo == 26 {
            if data.count >= 5 {
                let upper = UInt32(data[data.index(data.startIndex, offsetBy: 1)]) << 24 |
                            UInt32(data[data.index(data.startIndex, offsetBy: 2)]) << 16
                let lower = UInt32(data[data.index(data.startIndex, offsetBy: 3)]) << 8  |
                            UInt32(data[data.index(data.startIndex, offsetBy: 4)])

                result = (T(exactly: upper | lower), 5)
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else if additionalInfo == 27 {
            if data.count >= 9 {
                let upper: UInt64, lower: UInt64
                do {
                    let upper1 = UInt64(data[data.index(data.startIndex, offsetBy: 1)]) << 56 |
                                 UInt64(data[data.index(data.startIndex, offsetBy: 2)]) << 48
                    let upper2 = UInt64(data[data.index(data.startIndex, offsetBy: 3)]) << 40 |
                                 UInt64(data[data.index(data.startIndex, offsetBy: 4)]) << 32

                    upper = upper1 | upper2
                }
                do {
                    let lower1 = UInt64(data[data.index(data.startIndex, offsetBy: 5)]) << 24 |
                                 UInt64(data[data.index(data.startIndex, offsetBy: 6)]) << 16
                    let lower2 = UInt64(data[data.index(data.startIndex, offsetBy: 7)]) << 8  |
                                 UInt64(data[data.index(data.startIndex, offsetBy: 8)])

                    lower = lower1 | lower2
                }

                result = (T(exactly: upper | lower), 9)
            } else {
                throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
            }
        } else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        guard let value = result.value else {
            throw CBOR.DecodingError.dataCorrupted(description: "Decoded number does not fit in \(type).")
        }

        return (value, result.decodedBytes)
    }
    // swiftlint:enable function_body_length

    private class func decode<T>(_ type: T.Type, from data: Data) throws -> (value: T, decodedBytes: Int) where T: SignedInteger & FixedWidthInteger {
        guard !data.isEmpty else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        let majorType = CBOR.majorType(for: data[data.startIndex])
        guard majorType == .negative else {
            throw CBOR.DecodingError.typeMismatch(expected: [type], actual: try self.type(for: data))
        }

        let result: (value: T?, decodedBytes: Int)
        do {
            let unsigned = try decode(UInt64.self, from: data, knownMajorType: .negative)

            result = (T(exactly: unsigned.value), unsigned.decodedBytes)
        } catch CBOR.DecodingError.insufficientEncodedBytes {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: type)
        }

        guard let value = result.value else {
            let error: CBOR.DecodingError
            if T.bitWidth == 64 {
                error = CBOR.DecodingError.dataCorrupted(description: "Decoded number does not fit in \(type). Try using \(CBOR.NegativeUInt64.self) instead")
            } else {
                error = CBOR.DecodingError.dataCorrupted(description: "Decoded number does not fit in \(type).")
            }

            throw error
        }

        return (value == .max ? .min : (-1 - value), result.decodedBytes)
    }

    // swiftlint:disable function_body_length
    private class func decode<I1, I2>(_: CBOR.DecimalFraction<I1, I2>.Type, from data: Data) throws -> (value: [Any], decodedBytes: Int) where I1: FixedWidthInteger, I2: FixedWidthInteger {
        guard data.count >= 3 else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: Array<Any>.self)
        }

        guard CBOR.majorType(for: data[data.startIndex]) == .array else {
            throw CBOR.DecodingError.typeMismatch(expected: [Array<Any>.self], actual: try self.type(for: data))
        }
        guard CBOR.additionalInfo(for: data[data.startIndex]) == 2 else {
            throw CBOR.DecodingError.dataCorrupted(description: "Expected to decode array containing exactly two elements, found array containing \((try? decode(UInt64.self, from: data, knownMajorType: .array))?.value ?? 0) elements")
        }

        var result: (value: [Any], decodedBytes: Int) = ([CBOR.Tag.decimalFraction], 1)
        var majorType = CBOR.majorType(for: data[data.index(after: data.startIndex)])

        switch majorType {
        case .unsigned:
            let unsigned = try decode(UInt64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

            result.value.append(unsigned.value)
            result.decodedBytes += unsigned.decodedBytes

        case .negative:
            do {
                let signed = try decode(Int64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

                result.value.append(signed.value)
                result.decodedBytes += signed.decodedBytes
            } catch let int64Error {
                do {
                    let signed = try decode(CBOR.NegativeUInt64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

                    result.value.append(signed.value)
                    result.decodedBytes += signed.decodedBytes
                } catch {
                    throw int64Error
                }
            }

        default:
            throw CBOR.DecodingError.typeMismatch(expected: [UInt64.self, Int64.self], actual: try self.type(for: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...])))
        }

        guard data.count > result.decodedBytes else {
            throw CBOR.DecodingError.insufficientEncodedBytes(expected: Array<Any>.self)
        }

        majorType = CBOR.majorType(for: data[data.index(data.startIndex, offsetBy: result.decodedBytes)])

        switch majorType {
        case .unsigned:
            let unsigned = try decode(UInt64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

            result.value.append(unsigned.value)
            result.decodedBytes += unsigned.decodedBytes

        case .negative:
            do {
                let signed = try decode(Int64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

                result.value.append(signed.value)
                result.decodedBytes += signed.decodedBytes
            } catch let int64Error {
                do {
                    let signed = try decode(CBOR.NegativeUInt64.self, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

                    result.value.append(signed.value)
                    result.decodedBytes += signed.decodedBytes
                } catch {
                    throw int64Error
                }
            }

        case .tag:
            guard let tag = CBOR.Tag(bits: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...])) else {
                throw CBOR.DecodingError.dataCorrupted(description: "Invalid CBOR tag")
            }

            switch tag {
            case .positiveBignum, .negativeBignum:
                guard data.count > result.decodedBytes + tag.bits.count else {
                    throw CBOR.DecodingError.insufficientEncodedBytes(expected: Array<Any>.self)
                }

                result.decodedBytes += tag.bits.count

                let bignum = try decode(CBOR.Bignum.self, tag: tag, from: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...]))

                result.value.append(bignum.value)
                result.decodedBytes += bignum.decodedBytes

            default:
                throw CBOR.DecodingError.typeMismatch(expected: [UInt64.self, Int64.self, CBOR.Bignum.self], actual: try self.type(for: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...])))
            }

        default:
            throw CBOR.DecodingError.typeMismatch(expected: [UInt64.self, Int64.self, CBOR.Bignum.self], actual: try self.type(for: Data(data[data.index(data.startIndex, offsetBy: result.decodedBytes)...])))
        }

        return result
    }
    // swiftlint:enable function_body_length

    private class func decode<I1, I2>(_: CBOR.Bigfloat<I1, I2>.Type, from data: Data) throws -> (value: [Any], decodedBytes: Int) where I1: FixedWidthInteger, I2: FixedWidthInteger {
        var result = try decode(CBOR.DecimalFraction<I1, I2>.self, from: data)
        result.value[0] = CBOR.Tag.bigfloat

        return result
    }

    // MARK: Unit Testing

    #if DEBUG
    // The only method that the consumer of CBORParser should be able to call is
    // `parse(_:)` but we'd still like to be able to unit test the private method.
    // These proxies will allow us to directly test edge cases inside of the private
    // methods without exposing the private methods to any consumer of the class

    internal class func testDecode(_ type: String.Type, from data: Data) throws -> (value: CBORDecodedString, decodedBytes: Int) {
        return try decode(type, from: data)
    }

    internal class func testDecode(_ type: Data.Type, from data: Data) throws -> (value: CBORDecodedData, decodedBytes: Int) {
        return try decode(type, from: data)
    }

    internal class func testDecode(_ type: Date.Type, tag: CBOR.Tag, from data: Data) throws -> (value: Date, decodedBytes: Int) {
        return try decode(type, tag: tag, from: data)
    }

    internal class func testDecode(_ type: URL.Type, from data: Data) throws -> (value: URL, decodedBytes: Int) {
        return try decode(type, from: data)
    }

    internal class func testDecode(_ type: CBOR.NegativeUInt64.Type, from data: Data) throws -> (value: CBOR.NegativeUInt64, decodedBytes: Int) {
        return try decode(type, from: data)
    }

    internal class func testDecode(_ type: CBOR.SimpleValue.Type, from data: Data) throws -> (value: CBOR.SimpleValue, decodedBytes: Int) {
        return try decode(type, from: data)
    }

    internal class func testDecode(_ type: CBOR.Bignum.Type, tag: CBOR.Tag, from data: Data) throws -> (value: CBOR.Bignum, decodedBytes: Int) {
        return try decode(type, tag: tag, from: data)
    }

    internal class func testDecode<T>(_ type: T.Type, from data: Data) throws -> (value: T, decodedBytes: Int) where T: BinaryFloatingPoint, T.RawExponent: FixedWidthInteger, T.RawSignificand: FixedWidthInteger {
        return try decode(type, from: data)
    }

    internal class func testDecode<T>(_ type: T.Type, from data: Data, knownMajorType: CBOR.MajorType = .unsigned) throws -> (value: T, decodedBytes: Int) where T: UnsignedInteger & FixedWidthInteger {
        return try decode(type, from: data, knownMajorType: knownMajorType)
    }

    internal class func testDecode<T>(_ type: T.Type, from data: Data) throws -> (value: T, decodedBytes: Int) where T: SignedInteger & FixedWidthInteger {
        return try decode(type, from: data)
    }

    internal class func testDecode<I1, I2>(_ type: CBOR.DecimalFraction<I1, I2>.Type, from data: Data) throws -> (value: [Any], decodedBytes: Int) where I1: FixedWidthInteger, I2: FixedWidthInteger {
        return try decode(type, from: data)
    }

    internal class func testDecode<I1, I2>(_ type: CBOR.Bigfloat<I1, I2>.Type, from data: Data) throws -> (value: [Any], decodedBytes: Int) where I1: FixedWidthInteger, I2: FixedWidthInteger {
        return try decode(type, from: data)
    }

    internal class func testCreateCodingKey(from value: Any) throws -> Swift.CodingKey {
        var storage = Storage()

        try storage.startKeyedContainer()
        try storage.append(value) // Key
        try storage.append(value) // Value
        try storage.endCurrentContainer()

        // swiftlint:disable force_cast force_unwrapping
        let dictionary = try storage.finalize()! as! CodingKeyDictionary<Any>
        // swiftlint:enable force_cast force_unwrapping
        return dictionary.keys[dictionary.keys.startIndex]
    }
    #endif // #if DEBUG

    // MARK: Private Types

    private struct Storage {

        // MARK: Private Fields

        private var containers: [(container: Any, length: UInt64?)] = []
        private var codingKey: CodingKey?

        private var topLevel: Any?
        private var isValid = true

        // MARK: Methods

        mutating func append(_ value: Any) throws {
            precondition(isValid)

            try append(value, cleanStack: true)
        }

        mutating func startUnkeyedContainer(ofLength length: UInt64? = nil) throws {
            precondition(isValid)

            let array = ArrayWrapper<Any>(indefiniteLength: length == nil)
            try append(array, length: length, cleanStack: false)

            cleanTopOfStack()
        }

        mutating func startKeyedContainer(ofLength length: UInt64? = nil) throws {
            precondition(isValid)

            let dictionary = CodingKeyDictionary<Any>(indefiniteLength: length == nil)
            try append(dictionary, length: length, cleanStack: false)

            cleanTopOfStack()
        }

        mutating func endCurrentContainer() throws {
            precondition(isValid)

            guard let last = containers.last, last.length == nil else {
                throw CBOR.DecodingError.dataCorrupted(description: "Invalid context for \"break\" code")
            }

            _ = containers.popLast()
            cleanTopOfStack()
        }

        mutating func finalize() throws -> Any? {
            precondition(isValid)

            cleanTopOfStack()
            guard containers.isEmpty else {
                // swiftlint:disable force_unwrapping
                let (container, length) = containers.last!

                let containerType = (container is ArrayWrapper<Any>) ? "array" : "map"
                let containerCount = (container as? ArrayWrapper<Any>)?.count ?? (container as? CodingKeyDictionary<Any>)!.count
                // swiftlint:enable force_unwrapping

                let error: CBOR.DecodingError
                if let length = length {
                    error = .dataCorrupted(description: "Expected to decode \(UInt64(containerCount) + length) elements for \(containerType), found only \(containerCount) elements")
                } else {
                    error = .dataCorrupted(description: "Reached end of data before finding \"break\" code for \(containerType)")
                }

                throw error
            }

            isValid = false
            return topLevel
        }

        // MARK: Private Methods

        private mutating func append(_ value: Any, length: UInt64? = nil, cleanStack: Bool = true) throws {
            if topLevel == nil {
                topLevel = value

                if value is ArrayWrapper<Any> || value is CodingKeyDictionary<Any> {
                    containers.append((value, length))
                }
            } else {
                guard !containers.isEmpty else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Cannot decode multiple objects outside of the context of a container")
                }

                let index = containers.index(before: containers.endIndex)

                if let array = containers[index] as? (container: ArrayWrapper<Any>, length: UInt64?) {
                    array.container.append(value)
                    containers[index].length -= 1
                } else if let dictionary = containers[index] as? (container: CodingKeyDictionary<Any>, length: UInt64?) {
                    if let codingKey = self.codingKey {
                        dictionary.container[codingKey] = value
                        containers[index].length -= 1

                        self.codingKey = nil
                    } else {
                        self.codingKey = try codingKey(from: value)
                    }
                }

                if value is ArrayWrapper<Any> || value is CodingKeyDictionary<Any> {
                    containers.append((value, length))
                }

                if cleanStack {
                    cleanTopOfStack()
                }
            }
        }

        private mutating func cleanTopOfStack() {
            while let container = containers.last {
                if let length = container.length, length == 0 {
                    _ = containers.popLast()
                } else {
                    break
                }
            }
        }

        // swiftlint:disable function_body_length implicitly_unwrapped_optional
        private func codingKey(from value: Any) throws -> CodingKey {
            let codingKey: CodingKey!

            if let value = value as? String {
                codingKey = CBOR.CodingKey(stringValue: value)
            } else if let value = value as? Int8 {
                codingKey = CBOR.CodingKey(intValue: Int(value))
            } else if let value = value as? Int16 {
                codingKey = CBOR.CodingKey(intValue: Int(value))
            } else if let value = value as? Int32 {
                codingKey = CBOR.CodingKey(intValue: Int(value))
            } else if let value = value as? Int64 {
                #if arch(arm) || arch(i386)
                guard let intValue = Int(exactly: value) else {
                    // Only reachable when architecture is 32-bit
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <\(value)> does not fit in CodingKey type \(Int.self)")
                }
                #else
                let intValue = Int(value)
                #endif // #if arch(arm) || arch(i386)

                codingKey = CBOR.CodingKey(intValue: intValue)
            } else if let value = value as? CBOR.NegativeUInt64 {
                guard let uintValue = UInt(exactly: value.rawValue), uintValue <= UInt(Int.max) + 1 else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <-\(value.rawValue == .max ? .max : (value.rawValue + 1))> does not fit in CodingKey type \(Int.self)")
                }

                if uintValue == UInt(Int.max) + 1 {
                    codingKey = CBOR.CodingKey(intValue: .min)
                } else {
                    codingKey = CBOR.CodingKey(intValue: -Int(uintValue))
                }
            } else if let value = value as? UInt8 {
                codingKey = CBOR.CodingKey(intValue: Int(value))
            } else if let value = value as? UInt16 {
                codingKey = CBOR.CodingKey(intValue: Int(value))
            } else if let value = value as? UInt32 {
                #if arch(arm) || arch(i386)
                guard let intValue = Int(exactly: value) else {
                    // Only reachable when architecture is 32-bit
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <\(value)> does not fit in CodingKey type \(Int.self)")
                }
                #else
                let intValue = Int(value)
                #endif // #if arch(arm) || arch(i386)

                codingKey = CBOR.CodingKey(intValue: intValue)
            } else if let value = value as? UInt64 {
                guard let intValue = Int(exactly: value) else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <\(value)> does not fit in CodingKey type \(Int.self)")
                }

                codingKey = CBOR.CodingKey(intValue: intValue)
            } else if let value = value as? CBOR.Bignum {
                guard value.content.count <= 8 else {
                    throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <\(value.isPositive ? "" : "-")0x\(value.content.map({ String(format: "%02X", $0) }).joined())> does not fit in CodingKey type \(Int.self)")
                }

                if value.isPositive {
                    let uint64: UInt64
                    // swiftlint:disable force_unwrapping
                    if value.content.count == 8 {
                        uint64 = value.content.reversed().withUnsafeBytes({ $0.bindMemory(to: UInt64.self).baseAddress!.pointee })
                    } else {
                        let padded = Data(count: 8 - value.content.count) + value.content
                        uint64 = padded.reversed().withUnsafeBytes({ $0.bindMemory(to: UInt64.self).baseAddress!.pointee })
                    }
                    // swiftlint:enable force_unwrapping

                    guard let intValue = Int(exactly: uint64) else {
                        throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <\(value)> does not fit in CodingKey type \(Int.self)")
                    }

                    codingKey = CBOR.CodingKey(intValue: intValue)
                } else {
                    let negativeUInt64: CBOR.NegativeUInt64
                    // swiftlint:disable force_unwrapping
                    if value.content.count == 8 {
                        negativeUInt64 = CBOR.NegativeUInt64(rawValue: value.content.reversed().withUnsafeBytes({ $0.bindMemory(to: UInt64.self).baseAddress!.pointee }))
                    } else {
                        let padded = Data(count: 8 - value.content.count) + value.content
                        negativeUInt64 = CBOR.NegativeUInt64(rawValue: padded.reversed().withUnsafeBytes({ $0.bindMemory(to: UInt64.self).baseAddress!.pointee }))
                    }
                    // swiftlint:enable force_unwrapping

                    guard let uintValue = UInt(exactly: negativeUInt64.rawValue), uintValue <= UInt(Int.max) + 1 else {
                        throw CBOR.DecodingError.dataCorrupted(description: "Decoded CBOR number <-\(negativeUInt64.rawValue == .max ? .max : (negativeUInt64.rawValue + 1))> does not fit in CodingKey type \(Int.self)")
                    }

                    if uintValue == UInt(Int.max) + 1 {
                        codingKey = CBOR.CodingKey(intValue: .min)
                    } else {
                        codingKey = CBOR.CodingKey(intValue: -1 - Int(uintValue))
                    }
                }
            } else {
                throw CBOR.DecodingError.dataCorrupted(description: "Keys of type \(Swift.type(of: value)) are currently unsupported")
            }

            return codingKey
        }
        // swiftlint:enable function_body_length implicitly_unwrapped_optional
    }
}

// MARK: - Optional Extension

extension Optional where Wrapped == UInt64 {

    fileprivate static func -= (lhs: inout Wrapped?, rhs: Wrapped) {
        if let value = lhs {
            lhs = value - rhs
        }
    }
}

// MARK: - CBORDecodedData Definition/Adoption

internal protocol CBORDecodedData {

    func decodedDataValue() -> Data
}

extension Data: CBORDecodedData {

    func decodedDataValue() -> Data {
        return self
    }
}

extension CBOR.IndefiniteLengthData: CBORDecodedData {

    func decodedDataValue() -> Data {
        let totalLength: Int = chunks.reduce(into: 0) { $0 += $1.count }
        return chunks.reduce(into: Data(capacity: totalLength)) { $0.append($1) }
    }
}

// MARK: - CBORDecodedString Definition/Adoption

internal protocol CBORDecodedString {

    func decodedStringValue() throws -> String
}

extension String: CBORDecodedString {

    func decodedStringValue() throws -> String {
        return self
    }
}

extension CBOR.IndefiniteLengthString: CBORDecodedString {

    func decodedStringValue() throws -> String {
        guard let string = stringValue else {
            throw CBOR.DecodingError.invalidUTF8String
        }

        return string
    }
}
