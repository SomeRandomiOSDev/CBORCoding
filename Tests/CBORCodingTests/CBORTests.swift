//
//  CBORTests.swift
//  CBORCodingTests
//
//  Created by Joseph Newton on 5/18/19.
//  Copyright © 2019 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable comma nesting force_try implicitly_unwrapped_optional

@testable import CBORCoding
import XCTest

// MARK: - CBORTests Definition

class CBORTests: XCTestCase {

    // MARK: Test Methods

    func testIndefiniteLengthDataInitialization() {
        let data = Data([UInt8(0), 1, 2, 3, 4, 5, 6, 7, 8, 9])

        let ilData1 = CBOR.IndefiniteLengthData(wrapping: [Data(data[0 ..< 6]), Data(data[6...])])
        let ilData2 = CBOR.IndefiniteLengthData(wrapping: data, chunkSize: 6)

        XCTAssertEqual(ilData1.chunks, ilData2.chunks)
    }

    func testIndefiniteLengthStringInitialization() {
        let string = "CBORCoding"

        let ilString1 = CBOR.IndefiniteLengthString(wrapping: ["CBORCod", "ing"])
        let ilString2 = CBOR.IndefiniteLengthString(wrapping: string, chunkSize: 7)

        XCTAssertEqual(ilString1.chunks, ilString2.chunks)
        XCTAssertEqual(ilString1.stringValue, string)
    }

    func testTagValues() {
        XCTAssertEqual(CBOR.Tag.standardDateTime.bits[0],    CBOR.MajorType.tag.rawValue | 0)
        XCTAssertEqual(CBOR.Tag.epochDateTime.bits[0],       CBOR.MajorType.tag.rawValue | 1)
        XCTAssertEqual(CBOR.Tag.positiveBignum.bits[0],      CBOR.MajorType.tag.rawValue | 2)
        XCTAssertEqual(CBOR.Tag.negativeBignum.bits[0],      CBOR.MajorType.tag.rawValue | 3)
        XCTAssertEqual(CBOR.Tag.decimalFraction.bits[0],     CBOR.MajorType.tag.rawValue | 4)
        XCTAssertEqual(CBOR.Tag.bigfloat.bits[0],            CBOR.MajorType.tag.rawValue | 5)
        XCTAssertEqual(CBOR.Tag.base64URLConversion.bits[0], CBOR.MajorType.tag.rawValue | 21)
        XCTAssertEqual(CBOR.Tag.base64Conversion.bits[0],    CBOR.MajorType.tag.rawValue | 22)
        XCTAssertEqual(CBOR.Tag.base16Conversion.bits[0],    CBOR.MajorType.tag.rawValue | 23)
        XCTAssertEqual(CBOR.Tag.encodedCBORData.bits[0],     CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.encodedCBORData.bits[1],                                   24)
        XCTAssertEqual(CBOR.Tag.uri.bits[0],                 CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.uri.bits[1],                                               32)
        XCTAssertEqual(CBOR.Tag.base64URL.bits[0],           CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.base64URL.bits[1],                                         33)
        XCTAssertEqual(CBOR.Tag.base64.bits[0],              CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.base64.bits[1],                                            34)
        XCTAssertEqual(CBOR.Tag.regularExpression.bits[0],   CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.regularExpression.bits[1],                                 35)
        XCTAssertEqual(CBOR.Tag.mimeMessage.bits[0],         CBOR.MajorType.tag.rawValue | 24)
        XCTAssertEqual(CBOR.Tag.mimeMessage.bits[1],                                       36)
        XCTAssertEqual(CBOR.Tag.selfDescribedCBOR.bits[0],   CBOR.MajorType.tag.rawValue | 25)
        XCTAssertEqual(CBOR.Tag.selfDescribedCBOR.bits[1],                                 0xD9)
        XCTAssertEqual(CBOR.Tag.selfDescribedCBOR.bits[2],                                 0xF7)
    }

    func testTagInitialization() {
        // Valid Tag Values
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 0])))              // .standardDateTime
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 1])))              // .epochDateTime
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 2])))              // .positiveBignum
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 3])))              // .negativeBignum
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 4])))              // .decimalFraction
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 5])))              // .bigfloat
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 21])))             // .base64URLConversion
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 22])))             // .base64Conversion
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 23])))             // .base16Conversion
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 24])))         // .encodedCBORData
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 32])))         // .uri
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 33])))         // .base64URL
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 34])))         // .base64
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 35])))         // .regularExpression
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 36])))         // .mimeMessage
        XCTAssertNotNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 25, 0xD9, 0xF7]))) // .selfDescribedCBOR

        // Invalid Tag Values
        XCTAssertNil(CBOR.Tag(bits: Data()))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.unsigned.rawValue])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 25])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 26])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 24, 25])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 25, 25])))
        XCTAssertNil(CBOR.Tag(bits: Data([CBOR.MajorType.tag.rawValue | 25, 25, 25])))
    }

    func testDirectlyEncodeUndefined() {
        struct Test: Encodable {
            func encode(to encoder: Encoder) throws {
                try CBOR.Undefined().encode(to: encoder)
            }
        }

        let encoder = CBOREncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(Test()))
        XCTAssertNoThrow(encoded2 = try encoder.encode(CBOR.Undefined()))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDirectlyDecodeUndefined() {
        struct Test: Decodable {
            init(from decoder: Decoder) throws {
                _ = try CBOR.Undefined(from: decoder)
            }
        }

        XCTAssertThrowsError(try CBORDecoder().decode(Test.self, from: convertFromHexString("0xF6")))
    }

    func testEncodeUndefinedWithOtherEncoder() {
        // Success
        do {
            let encoded = try JSONEncoder().encode([CBOR.Undefined()])
            _ = try JSONDecoder().decode([CBOR.Undefined].self, from: encoded)
        } catch { XCTFail(error.localizedDescription) }

        // Failure
        let encoded = try! JSONEncoder().encode(["Some random string"])
        XCTAssertThrowsError(try JSONDecoder().decode([CBOR.Undefined].self, from: encoded))
    }

    func testEncodeIndefiniteLengthArrayWithOtherEncoder() {
        let array = CBOR.IndefiniteLengthArray(wrapping: [0, 1, 2, 3])

        let encoder = JSONEncoder()
        var encoded = Data(), encodedIL = Data()

        XCTAssertNoThrow(encoded = try encoder.encode(array))
        XCTAssertNoThrow(encodedIL = try encoder.encode(array.array))
        XCTAssertEqual(encoded, encodedIL)
    }

    func testDirectlyDecodeIndefiniteLengthArray() {
        struct Test: Decodable {

            let value: CBOR.IndefiniteLengthArray<Int>

            init(from decoder: Decoder) throws {
                value = try CBOR.IndefiniteLengthArray(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0x9F00010203040506070809FF")))
        XCTAssertEqual(test.value, CBOR.IndefiniteLengthArray(wrapping: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]))
    }

    func testEncodeIndefiniteLengthMapWithOtherEncoder() {
        let map = CBOR.IndefiniteLengthMap(wrapping: ["a": 0])

        let encoder = JSONEncoder()
        var encoded = Data(), encodedIL = Data()

        XCTAssertNoThrow(encoded = try encoder.encode(map))
        XCTAssertNoThrow(encodedIL = try encoder.encode(map.map))
        XCTAssertEqual(encoded, encodedIL)
    }

    func testDirectlyDecodeIndefiniteLengthMap() {
        struct Test: Decodable {

            let value: CBOR.IndefiniteLengthMap<String, Int>

            init(from decoder: Decoder) throws {
                value = try CBOR.IndefiniteLengthMap(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0xBF616100616201616302616403616504FF")))
        XCTAssertEqual(test.value, CBOR.IndefiniteLengthMap(wrapping: ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4]))
    }

    func testEncodeIndefiniteLengthDataWithOtherEncoder() {
        let data = CBOR.IndefiniteLengthData(wrapping: Data([UInt8(0), 1, 2, 3, 4, 5, 6, 7, 8, 9]), chunkSize: 6)

        let encoder = JSONEncoder()
        var encoded = Data(), encodedIL = Data()

        XCTAssertNoThrow(encoded = try encoder.encode(data))
        XCTAssertNoThrow(encodedIL = try encoder.encode(data.chunks))
        XCTAssertEqual(encoded, encodedIL)
    }

    func testDecodeIndefiniteLengthDataWithOtherEncoder() {
        let value = CBOR.IndefiniteLengthData(wrapping: convertFromHexString("0x00010203040506070809"), chunkSize: 5)

        do {
            let encoded = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CBOR.IndefiniteLengthData.self, from: encoded)

            XCTAssertEqual(value, decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodeIndefiniteLengthStringWithOtherEncoder() {
        let string = CBOR.IndefiniteLengthString(wrapping: "CBORCoding", chunkSize: 6)

        let encoder = JSONEncoder()
        var encoded = Data(), encodedIL = Data()

        XCTAssertNoThrow(encoded = try encoder.encode(string))
        XCTAssertNoThrow(encodedIL = try encoder.encode(string.chunks))
        XCTAssertEqual(encoded, encodedIL)
    }

    func testDecodeIndefiniteLengthStringWithOtherEncoder() {
        let value = CBOR.IndefiniteLengthString(wrapping: "CBORCoding", chunkSize: 5)

        do {
            let encoded = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CBOR.IndefiniteLengthString.self, from: encoded)

            XCTAssertEqual(value, decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDirectlyEncodeIndefiniteLengthData() {
        struct Test: Encodable {

            static let data = CBOR.IndefiniteLengthData(wrapping: Data([UInt8(0), 1, 2, 3, 4, 5, 6, 7, 8, 9]), chunkSize: 6)

            func encode(to encoder: Encoder) throws {
                try Test.data.encode(to: encoder)
            }
        }

        let encoder = CBOREncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(Test()))
        XCTAssertNoThrow(encoded2 = try encoder.encode(Test.data))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDirectlyDecodeIndefiniteLengthData() {
        struct Test: Decodable {

            let data: CBOR.IndefiniteLengthData

            init(from decoder: Decoder) throws {
                data = try CBOR.IndefiniteLengthData(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0x5F460001020304054406070809FF")))
        XCTAssertEqual(test.data.chunks, [convertFromHexString("0x000102030405"), convertFromHexString("0x06070809")])
    }

    func testDirectlyEncodeIndefiniteLengthString() {
        struct Test: Encodable {

            static let string = CBOR.IndefiniteLengthString(wrapping: "CBORCoding", chunkSize: 6)

            func encode(to encoder: Encoder) throws {
                try Test.string.encode(to: encoder)
            }
        }

        let encoder = CBOREncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(Test()))
        XCTAssertNoThrow(encoded2 = try encoder.encode(Test.string))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDirectlyDecodeIndefiniteLengthString() {
        struct Test: Decodable {

            let string: CBOR.IndefiniteLengthString

            init(from decoder: Decoder) throws {
                string = try CBOR.IndefiniteLengthString(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0x7F6643424F52436F6464696E67FF")))
        XCTAssertEqual(test.string.chunks, [convertFromHexString("0x43424F52436F"), convertFromHexString("0x64696E67")])
        XCTAssertEqual(test.string.stringValue, "CBORCoding")
    }

    func testEncodeNegativeUInt64WithOtherEncoder() {
        let value = CBOR.NegativeUInt64(rawValue: 0xFF)

        let encoder = JSONEncoder()
        var encoded = Data(), encodedIL = Data()

        XCTAssertNoThrow(encoded = try encoder.encode([value.rawValue]))
        XCTAssertNoThrow(encodedIL = try encoder.encode([value]))
        XCTAssertEqual(encoded, encodedIL)
    }

    func testDirectlyEncodeNegativeUInt64() {
        struct Test: Encodable {

            static let value = CBOR.NegativeUInt64(rawValue: 0x100)

            func encode(to encoder: Encoder) throws {
                try Test.value.encode(to: encoder)
            }
        }

        let encoder = CBOREncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(Test()))
        XCTAssertNoThrow(encoded2 = try encoder.encode(Test.value))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDecodeNegativeUInt64WithOtherEncoder() {
        let value = CBOR.NegativeUInt64(rawValue: 0xFF)

        do {
            let encoded = try JSONEncoder().encode([value])
            let decoded = try JSONDecoder().decode([CBOR.NegativeUInt64].self, from: encoded)

            XCTAssertEqual([value], decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDirectlyDecodeNegativeUInt64() {
        struct Test: Decodable {

            let value: CBOR.NegativeUInt64

            init(from decoder: Decoder) throws {
                value = try CBOR.NegativeUInt64(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0x38FF")))
        XCTAssertEqual(test.value.rawValue, 0xFF)
    }

    func testEncodeSimpleValueWithOtherEncoder() {
        let simple = CBOR.SimpleValue(rawValue: 0x6E)

        let encoder = JSONEncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode([simple]))
        XCTAssertNoThrow(encoded2 = try encoder.encode([simple.rawValue]))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDirectlyDecodeSimpleValue() {
        struct Test: Decodable {

            let value: CBOR.SimpleValue

            init(from decoder: Decoder) throws {
                value = try CBOR.SimpleValue(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0xF818")))
        XCTAssertEqual(test.value.rawValue, 24)
    }

    func testDecodeSimpleValueWithOtherEncoder() {
        let value = CBOR.SimpleValue(rawValue: 0x7F)

        do {
            let encoded = try JSONEncoder().encode([value])
            let decoded = try JSONDecoder().decode([CBOR.SimpleValue].self, from: encoded)

            XCTAssertEqual([value], decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodeBignumWithOtherEncoder() {
        struct Test: Encodable {

            private enum CodingKeys: String, CodingKey {
                case isPositive
                case content
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(true, forKey: .isPositive)
                try container.encode(Data([UInt8(0x00), 0x01, 0x02, 0x03]), forKey: .content)
            }
        }

        let bignum = CBOR.Bignum(isPositive: true, content: Data([UInt8(0x00), 0x01, 0x02, 0x03]))

        let encoder = JSONEncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(bignum))
        XCTAssertNoThrow(encoded2 = try encoder.encode(Test()))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDecodeBignumWithOtherEncoder() {
        let value = CBOR.Bignum(isPositive: true , content: convertFromHexString("0x010000000000000000"))

        do {
            let encoded = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CBOR.Bignum.self, from: encoded)

            XCTAssertEqual(value, decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDirectlyDecodeBignum() {
        struct Test: Decodable {

            let value: CBOR.Bignum

            init(from decoder: Decoder) throws {
                value = try CBOR.Bignum(from: decoder)
            }
        }

        var test: Test!
        XCTAssertNoThrow(test = try CBORDecoder().decode(Test.self, from: convertFromHexString("0xC249010000000000000000")))
        XCTAssertTrue(test.value.isPositive)
        XCTAssertEqual(test.value.content, convertFromHexString("0x010000000000000000"))
    }

    func testEncodeDecimalFractionWithOtherEncoder() {
        let decimal = CBOR.DecimalFraction<Int, Int>(exponent: 9, mantissa: -3)

        let encoder = JSONEncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(decimal))
        XCTAssertNoThrow(encoded2 = try encoder.encode([decimal.exponent, decimal.mantissa]))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDecodeDecimalFractionWithOtherEncoder() {
        let value = CBOR.DecimalFraction(exponent: 1, mantissa: 15)

        do {
            let encoded = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CBOR.DecimalFraction<Int, Int>.self, from: encoded)

            XCTAssertEqual(value, decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testEncodeBigfloatWithOtherEncoder() {
        let float = CBOR.Bigfloat<Int, Int>(exponent: 9, mantissa: -3)

        let encoder = JSONEncoder()
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode(float))
        XCTAssertNoThrow(encoded2 = try encoder.encode([float.exponent, float.mantissa]))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDecodeBigfloatWithOtherEncoder() {
        let value = CBOR.Bigfloat(exponent: 1, mantissa: 15)

        do {
            let encoded = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CBOR.Bigfloat<Int, Int>.self, from: encoded)

            XCTAssertEqual(value, decoded)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testCBOREncoded() {
        let encoder = CBOREncoder()
        var data = Data(), encodedData = Data()

        XCTAssertNoThrow(data = try encoder.encode("CBOR"))
        XCTAssertNoThrow(encodedData = try encoder.encode(CBOR.CBOREncoded(encodedData: data)))
        XCTAssertEqual(data, encodedData)
    }

    func testEncodeCBOREncodedWithOtherEncoder() {
        let encoder = JSONEncoder()
        let dataToEncode = Data("CBOR".utf8)
        var encoded1 = Data(), encoded2 = Data()

        XCTAssertNoThrow(encoded1 = try encoder.encode([dataToEncode]))
        XCTAssertNoThrow(encoded2 = try encoder.encode([CBOR.CBOREncoded(encodedData: dataToEncode)]))
        XCTAssertEqual(encoded1, encoded2)
    }

    func testDirectlyEncodeCBOREncoded() {
        struct Test: Encodable {

            static var value: Data = {
                try! CBOREncoder().encode("CBOR")
            }()

            func encode(to encoder: Encoder) throws {
                try CBOR.CBOREncoded(encodedData: Test.value).encode(to: encoder)
            }
        }

        let encoder = CBOREncoder()
        var data = Data()

        XCTAssertNoThrow(data = try encoder.encode(Test()))
        XCTAssertEqual(data, Test.value)
    }

    // MARK: Private Methods

    private func convertFromHexString(_ string: String) -> Data {
        var hex = string.starts(with: "0x") ? String(string.dropFirst(2)) : string

        if (hex.count % 2) == 1 { // odd number of hex characters
            hex.insert(contentsOf: "0", at: hex.startIndex)
        }

        var data = Data(capacity: hex.count / 2)
        for i in stride(from: 0, to: hex.count, by: 2) {
            let map = { (character: Character) -> UInt8 in
                switch character {
                case "0": return 0x00
                case "1": return 0x01
                case "2": return 0x02
                case "3": return 0x03
                case "4": return 0x04
                case "5": return 0x05
                case "6": return 0x06
                case "7": return 0x07
                case "8": return 0x08
                case "9": return 0x09
                case "A": return 0x0A
                case "B": return 0x0B
                case "C": return 0x0C
                case "D": return 0x0D
                case "E": return 0x0E
                case "F": return 0x0F
                default:  preconditionFailure("Invalid hex character: \(character)")
                }
            }

            data.append(map(hex[hex.index(hex.startIndex, offsetBy: i)]) << 4 |
                map(hex[hex.index(hex.startIndex, offsetBy: i + 1)]))
        }

        return data
    }
}
