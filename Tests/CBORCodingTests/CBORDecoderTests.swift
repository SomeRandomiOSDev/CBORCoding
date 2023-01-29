//
//  CBORDecoderTests.swift
//  CBORCodingTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable nesting function_body_length force_cast identifier_name opening_brace comma implicitly_unwrapped_optional number_separator force_unwrapping closure_spacing

@testable import CBORCoding
import XCTest

// MARK: - CBORDecoderTests Definition

class CBORDecoderTests: XCTestCase {

    // MARK: Test Methods

    func testAppendixASimpleExamples() {
        // Test Examples taken from Appendix A of RFC 8949

        var value: Any!
        let decoder = CBORDecoder()

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x00")))
        XCTAssertEqual(value as! UInt64, 0)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x01")))
        XCTAssertEqual(value as! UInt64, 1)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x0A")))
        XCTAssertEqual(value as! UInt64, 10)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x17")))
        XCTAssertEqual(value as! UInt64, 23)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1818")))
        XCTAssertEqual(value as! UInt64, 24)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1819")))
        XCTAssertEqual(value as! UInt64, 25)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1864")))
        XCTAssertEqual(value as! UInt64, 100)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1903E8")))
        XCTAssertEqual(value as! UInt64, 1000)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1A000F4240")))
        XCTAssertEqual(value as! UInt64, 1000000)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1B000000E8D4A51000")))
        XCTAssertEqual(value as! UInt64, 1000000000000)

        XCTAssertNoThrow(value = try decoder.decode(UInt64.self, from: convertFromHexString("0x1BFFFFFFFFFFFFFFFF")))
        XCTAssertEqual(value as! UInt64, 18446744073709551615)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.Bignum.self, from: convertFromHexString("0xC249010000000000000000"))) // 18446744073709551616
        XCTAssertTrue((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

        XCTAssertNoThrow(value = try decoder.decode(CBOR.NegativeUInt64.self, from: convertFromHexString("0x3BFFFFFFFFFFFFFFFF"))) // -18446744073709551616
        XCTAssertEqual((value as! CBOR.NegativeUInt64).rawValue, .min)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.Bignum.self, from: convertFromHexString("0xC349010000000000000000"))) // -18446744073709551617
        XCTAssertFalse((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

        XCTAssertNoThrow(value = try decoder.decode(Int64.self, from: convertFromHexString("0x20")))
        XCTAssertEqual(value as! Int64, -1)

        XCTAssertNoThrow(value = try decoder.decode(Int64.self, from: convertFromHexString("0x29")))
        XCTAssertEqual(value as! Int64, -10)

        XCTAssertNoThrow(value = try decoder.decode(Int64.self, from: convertFromHexString("0x3863")))
        XCTAssertEqual(value as! Int64, -100)

        XCTAssertNoThrow(value = try decoder.decode(Int64.self, from: convertFromHexString("0x3903E7")))
        XCTAssertEqual(value as! Int64, -1000)

        XCTAssertNoThrow(value = try decoder.decode(Int64.self, from: convertFromHexString("0x3B7FFFFFFFFFFFFFFF"))) // NOT part of RFC 8949 examples
        XCTAssertEqual(value as! Int64, .min)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF90000")))
        XCTAssertEqual(value as! Float16, 0.0)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF98000")))
        XCTAssertEqual(value as! Float16, -0.0)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF93C00")))
        XCTAssertEqual(value as! Float16, 1.0)

        XCTAssertNoThrow(value = try decoder.decode(Double.self, from: convertFromHexString("0xFB3FF199999999999A")))
        XCTAssertEqual(value as! Double, 1.1)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF93E00")))
        XCTAssertEqual(value as! Float16, 1.5)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF97BFF")))
        XCTAssertEqual(value as! Float16, 65504.0)

        XCTAssertNoThrow(value = try decoder.decode(Float.self, from: convertFromHexString("0xFA47C35000")))
        XCTAssertEqual(value as! Float, 100000.0)

        XCTAssertNoThrow(value = try decoder.decode(Float.self, from: convertFromHexString("0xFA7F7FFFFF")))
        XCTAssertEqual(value as! Float, 3.4028234663852886e+38)

        XCTAssertNoThrow(value = try decoder.decode(Double.self, from: convertFromHexString("0xFB7E37E43C8800759C")))
        XCTAssertEqual(value as! Double, 1.0e+300)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF90001")))
        XCTAssertEqual(value as! Float16, 5.960464477539063e-8)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF90400")))
        XCTAssertEqual(value as! Float16, 0.00006103515625)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF9C400")))
        XCTAssertEqual(value as! Float16, -4.0)

        XCTAssertNoThrow(value = try decoder.decode(Double.self, from: convertFromHexString("0xFBC010666666666666")))
        XCTAssertEqual(value as! Double, -4.1)

        // Float16, Float, and Double should be able to decode each other's NaN values
        for quietNaN in ["0xF97E00", "0xFA7FC00000", "0xFB7FF8000000000000"].map(convertFromHexString) {
            XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: quietNaN))
            XCTAssertTrue((value as! Float16).isNaN)
            XCTAssertFalse((value as! Float16).isSignalingNaN)

            XCTAssertNoThrow(value = try decoder.decode(Float.self, from: quietNaN))
            XCTAssertTrue((value as! Float).isNaN)
            XCTAssertFalse((value as! Float).isSignalingNaN)

            XCTAssertNoThrow(value = try decoder.decode(Double.self, from: quietNaN))
            XCTAssertTrue((value as! Double).isNaN)
            XCTAssertFalse((value as! Double).isSignalingNaN)
        }

         // NOT part of RFC 8949 examples
        for signalingNaN in ["0xF97D00", "0xFA7FA00000", "0xFB7FF4000000000000"].map(convertFromHexString) {
            XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: signalingNaN))
            XCTAssertTrue((value as! Float16).isSignalingNaN)

            XCTAssertNoThrow(value = try decoder.decode(Float.self, from: signalingNaN))
            XCTAssertTrue((value as! Float).isSignalingNaN)

            XCTAssertNoThrow(value = try decoder.decode(Double.self, from: signalingNaN))
            XCTAssertTrue((value as! Double).isSignalingNaN)
        }

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF97C00")))
        XCTAssertEqual(value as! Float16, .infinity)

        XCTAssertNoThrow(value = try decoder.decode(Float16.self, from: convertFromHexString("0xF9FC00")))
        XCTAssertEqual(value as! Float16, -.infinity)

        XCTAssertNoThrow(value = try decoder.decode(Float.self, from: convertFromHexString("0xFA7F800000")))
        XCTAssertEqual(value as! Float, .infinity)

        XCTAssertNoThrow(value = try decoder.decode(Float.self, from: convertFromHexString("0xFAFF800000")))
        XCTAssertEqual(value as! Float, -.infinity)

        XCTAssertNoThrow(value = try decoder.decode(Double.self, from: convertFromHexString("0xFB7FF0000000000000")))
        XCTAssertEqual(value as! Double, .infinity)

        XCTAssertNoThrow(value = try decoder.decode(Double.self, from: convertFromHexString("0xFBFFF0000000000000")))
        XCTAssertEqual(value as! Double, -.infinity)

        XCTAssertNoThrow(value = try decoder.decode(Bool.self, from: convertFromHexString("0xF4")))
        XCTAssertFalse(value as! Bool)

        XCTAssertNoThrow(value = try decoder.decode(Bool.self, from: convertFromHexString("0xF5")))
        XCTAssertTrue(value as! Bool)

//        XCTAssertNoThrow(value = try decoder.decode(CBOR.Null.self, from: convertFromHexString("0xF6")))
//        XCTAssertTrue(value is CBOR.Null)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.Undefined.self, from: convertFromHexString("0xF7")))
        XCTAssertTrue(value is CBOR.Undefined)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.SimpleValue.self, from: convertFromHexString("0xF0")))
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 16)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.SimpleValue.self, from: convertFromHexString("0xF818")))
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 24)

        XCTAssertNoThrow(value = try decoder.decode(CBOR.SimpleValue.self, from: convertFromHexString("0xF8FF")))
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 255)

        XCTAssertNoThrow(value = try decoder.decode(Date.self, from: convertFromHexString("0xC074323031332D30332D32315432303A30343A30305A")))
        XCTAssertEqual(value as! Date, rfc3339Date())

        XCTAssertNoThrow(value = try decoder.decode(Date.self, from: convertFromHexString("0xC11A514B67B0")))
        XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240))

        XCTAssertNoThrow(value = try decoder.decode(Date.self, from: convertFromHexString("0xC1FB41D452D9EC200000")))
        XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240.5))

        XCTAssertNoThrow(value = try decoder.decode(Data.self, from: convertFromHexString("0xD74401020304")))
        XCTAssertEqual(value as! Data, convertFromHexString("0x01020304"))

        XCTAssertNoThrow(value = try decoder.decode(Data.self, from: convertFromHexString("0xD818456449455446")))
        XCTAssertEqual(value as! Data, convertFromHexString("0x6449455446"))

        XCTAssertNoThrow(value = try decoder.decode(URL.self, from: convertFromHexString("0xD82076687474703A2F2F7777772E6578616D706C652E636F6D")))
        XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

        XCTAssertNoThrow(value = try decoder.decode(Data.self, from: convertFromHexString("0x40")))
        XCTAssertEqual(value as! Data, Data())

        XCTAssertNoThrow(value = try decoder.decode(Data.self, from: convertFromHexString("0x4401020304")))
        XCTAssertEqual(value as! Data, convertFromHexString("0x01020304"))

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x60")))
        XCTAssertEqual(value as! String, "")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x6161")))
        XCTAssertEqual(value as! String, "a")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x6449455446")))
        XCTAssertEqual(value as! String, "IETF")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x62225C")))
        XCTAssertEqual(value as! String, "\"\\")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x62C3BC")))
        XCTAssertEqual(value as! String, "\u{00FC}")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x63E6B0B4")))
        XCTAssertEqual(value as! String, "\u{6C34}")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x64F0908591")))
        XCTAssertEqual(value as! String, "\u{10151}")
    }

    func testAppendixAComplexExamples1() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // []
        //
        // [1, 2, 3]
        //
        // [1,  2,  3,  4,  5,  6,  7,
        //  8,  9,  10, 11, 12, 13, 14,
        //  15, 16, 17, 18, 19, 20, 21,
        //  22, 23, 24, 25]

        let decoder = CBORDecoder()
        var array: [UInt8] = []

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x80")))
        XCTAssertTrue(array.isEmpty)

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x9FFF"))) // Indefinite length array
        XCTAssertTrue(array.isEmpty)

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x83010203")))
        XCTAssertEqual(array, [1, 2, 3])

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x9F010203FF"))) // Indefinite length array
        XCTAssertEqual(array, [1, 2, 3])

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x98190102030405060708090A0B0C0D0E0F101112131415161718181819")))
        XCTAssertEqual(array, [1, 2, 3, 4, 5, 6, 7, 8, 9,
                               10, 11, 12, 13, 14, 15, 16,
                               17, 18, 19, 20, 21, 22, 23,
                               24, 25])

        XCTAssertNoThrow(array = try decoder.decode([UInt8].self, from: convertFromHexString("0x9F0102030405060708090A0B0C0D0E0F101112131415161718181819FF"))) // Indefinite length array
        XCTAssertEqual(array, [1, 2, 3, 4, 5, 6, 7, 8, 9,
                               10, 11, 12, 13, 14, 15, 16,
                               17, 18, 19, 20, 21, 22, 23,
                               24, 25])
    }

    func testAppendixAComplexExamples2() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1, [2, 3], [4, 5]]

        struct Test: Decodable {

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var value: Any!

                XCTAssertNoThrow(value = try container.decode(Int8.self))
                XCTAssertEqual((value as! Int8), 1)

                XCTAssertNoThrow(value = try container.decode([UInt8].self))
                XCTAssertEqual((value as! [UInt8]), [2, 3])

                XCTAssertNoThrow(value = try container.decode([UInt64].self))
                XCTAssertEqual((value as! [UInt64]), [4, 5])
            }
        }

        let dataStrings = [
            "0x8301820203820405",      // Definite/Definite/Definite
            "0x83018202039F0405FF",    // Definite/Definite/Indefinite
            "0x83019F0203FF820405",    // Definite/Indefinite/Definite
            "0x83019F0203FF9F0405FF",  // Definite/Indefinite/Indefinite
            "0x9F01820203820405FF",    // Indefinite/Definite/Definite
            "0x9F018202039F0405FFFF",  // Indefinite/Definite/Indefinite
            "0x9F019F0203FF820405FF",  // Indefinite/Indefinite/Definite
            "0x9F019F0203FF9F0405FFFF" // Indefinite/Indefinite/Indefinite
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(_ = try CBORDecoder().decode(Test.self, from: convertFromHexString(dataString)))
        }
    }

    func testAppendixAComplexExamples3() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1: 2, 3: 4]

        struct Test: Decodable {

            private enum CodingKeys: Int, CodingKey {

                case first = 1
                case second = 3
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertTrue(container.contains(.first))
                XCTAssertNoThrow(value = try container.decode(Int16.self, forKey: .first))
                XCTAssertEqual((value as! Int16), 2)

                XCTAssertTrue(container.contains(.second))
                XCTAssertNoThrow(value = try container.decode(UInt32.self, forKey: .second))
                XCTAssertEqual((value as! UInt32), 4)
            }
        }

        XCTAssertNoThrow(_ = try CBORDecoder().decode(Test.self, from: convertFromHexString("0xA201020304")))
        XCTAssertNoThrow(_ = try CBORDecoder().decode(Test.self, from: convertFromHexString("0xBF01020304FF"))) // Indefinite length map
    }

    func testAppendixAComplexExamples4() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": 1, "b": [2, 3]]

        struct Test1: Decodable {

            private enum CodingKeys: String, CodingKey {

                case first  = "a"
                case second = "b"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertTrue(container.contains(.first))
                XCTAssertNoThrow(value = try container.decode(UInt16.self, forKey: .first))
                XCTAssertEqual((value as! UInt16), 1)

                XCTAssertTrue(container.contains(.second))
                XCTAssertNoThrow(value = try container.decode([Int64].self, forKey: .second))
                XCTAssertEqual((value as! [Int64]), [2, 3])
            }
        }
        struct Test2: Decodable {

            private enum CodingKeys: String, CodingKey {

                case first  = "a"
                case second = "b"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertTrue(container.contains(.first))
                XCTAssertNoThrow(value = try container.decode(UInt16.self, forKey: .first))
                XCTAssertEqual((value as! UInt16), 1)

                XCTAssertTrue(container.contains(.second))
                var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .second)

                XCTAssertNoThrow(value = try unkeyedContainer.decode(Int64.self))
                XCTAssertEqual((value as! Int64), 2)
                XCTAssertNoThrow(value = try unkeyedContainer.decode(Int32.self))
                XCTAssertEqual((value as! Int32), 3)
            }
        }

        let dataStrings = [
            "0xA26161016162820203",    // Definite/Definite
            "0xA261610161629F0203FF",  // Definite/Indefinite
            "0xBF6161016162820203FF",  // Indefinite/Definite
            "0xBF61610161629F0203FFFF" // Indefinite/Indefinite
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(_ = try CBORDecoder().decode(Test1.self, from: convertFromHexString(dataString)))
            XCTAssertNoThrow(_ = try CBORDecoder().decode(Test2.self, from: convertFromHexString(dataString)))
        }
    }

    func testAppendixAComplexExamples5() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a", ["b": "c"]]

        struct Test1: Decodable {

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var value: Any!

                XCTAssertNoThrow(value = try container.decode(String.self))
                XCTAssertEqual((value as! String), "a")

                XCTAssertNoThrow(value = try container.decode([String: String].self))
                XCTAssertEqual((value as! [String: String]), ["b": "c"])
            }
        }
        struct Test2: Decodable {

            private enum CodingKeys: String, CodingKey {
                case b
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var value: Any!

                XCTAssertNoThrow(value = try container.decode(String.self))
                XCTAssertEqual((value as! String), "a")

                let keyedContainer = try container.nestedContainer(keyedBy: CodingKeys.self)

                XCTAssertTrue(keyedContainer.contains(.b))
                XCTAssertNoThrow(value = try keyedContainer.decode(String.self, forKey: .b))
                XCTAssertEqual((value as! String), "c")
            }
        }

        let dataStrings = [
            "0x826161A161626163",    // Definite/Definite
            "0x826161BF61626163FF",  // Definite/Indefinite
            "0x9F6161A161626163FF",  // Indefinite/Definite
            "0x9F6161BF61626163FFFF" // Indefinite/Indefinite
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(_ = try CBORDecoder().decode(Test1.self, from: convertFromHexString(dataString)))
            XCTAssertNoThrow(_ = try CBORDecoder().decode(Test2.self, from: convertFromHexString(dataString)))
        }
    }

    func testAppendixAComplexExamples6() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"]

        struct Test1: Decodable {

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                var value: Any!

                XCTAssertNoThrow(try value = container.decode([String: String].self))
                XCTAssertEqual((value as! [String: String]), ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"])
            }
        }
        struct Test2: Decodable {

            private enum CodingKeys: String, CodingKey {
                case a, b, c, d, e
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertTrue(container.contains(.a))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .a))
                XCTAssertEqual((value as! String), "A")

                XCTAssertTrue(container.contains(.b))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .b))
                XCTAssertEqual((value as! String), "B")

                XCTAssertTrue(container.contains(.c))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .c))
                XCTAssertEqual((value as! String), "C")

                XCTAssertTrue(container.contains(.d))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .d))
                XCTAssertEqual((value as! String), "D")

                XCTAssertTrue(container.contains(.e))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .e))
                XCTAssertEqual((value as! String), "E")
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test1.self, from: convertFromHexString("0xA56161614161626142616361436164614461656145")))
        XCTAssertNoThrow(try CBORDecoder().decode(Test1.self, from: convertFromHexString("0xBF6161614161626142616361436164614461656145FF"))) // Indefinite length map

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xA56161614161626142616361436164614461656145")))
        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xBF6161614161626142616361436164614461656145FF"))) // Indefinite length map
    }

    func testAppendixAComplexExamples7() {
        // [1: "A", 2: "B", 3: "C", 4: "D", 5: "E"]

        struct Test1: Decodable {

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                var value: Any!

                XCTAssertNoThrow(try value = container.decode([Int: String].self))
                XCTAssertEqual((value as! [Int: String]), [1: "A", 2: "B", 3: "C", 4: "D", 5: "E"])
            }
        }
        struct Test2: Decodable {

            private enum CodingKeys: Int, CodingKey {
                case a = 1
                case b = 2
                case c = 3
                case d = 4
                case e = 5
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertTrue(container.contains(.a))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .a))
                XCTAssertEqual((value as! String), "A")

                XCTAssertTrue(container.contains(.b))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .b))
                XCTAssertEqual((value as! String), "B")

                XCTAssertTrue(container.contains(.c))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .c))
                XCTAssertEqual((value as! String), "C")

                XCTAssertTrue(container.contains(.d))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .d))
                XCTAssertEqual((value as! String), "D")

                XCTAssertTrue(container.contains(.e))
                XCTAssertNoThrow(try value = container.decode(String.self, forKey: .e))
                XCTAssertEqual((value as! String), "E")
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test1.self, from: convertFromHexString("0xA5016141026142036143046144056145")))
        XCTAssertNoThrow(try CBORDecoder().decode(Test1.self, from: convertFromHexString("0xBF016141026142036143046144056145FF"))) // Indefinite length map

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xA5016141026142036143046144056145")))
        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xBF016141026142036143046144056145FF"))) // Indefinite length map
    }

    func testAppendixAComplexExamples8() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ h'0102', h'030405')

        let decoder = CBORDecoder()
        var value: Any!

        XCTAssertNoThrow(value = try decoder.decode(CBOR.IndefiniteLengthData.self, from: convertFromHexString("0x5F42010243030405FF")))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks.count, 2)
        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[0], convertFromHexString("0x0102"))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[1], convertFromHexString("0x030405"))

        XCTAssertNoThrow(value = try decoder.decode(Data.self, from: convertFromHexString("0x5F42010243030405FF")))
        XCTAssertEqual((value as! Data), convertFromHexString("0x0102030405"))
    }

    func testAppendixAComplexExamples9() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ "strea", "ming")

        let decoder = CBORDecoder()
        var value: Any!

        XCTAssertNoThrow(value = try decoder.decode(CBOR.IndefiniteLengthString.self, from: convertFromHexString("0x7F657374726561646D696E67FF")))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks.count, 2)
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[0], convertFromHexString("0x7374726561"))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[1], convertFromHexString("0x6D696E67"))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).stringValue, "streaming")
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).stringValue(as: .utf8), "streaming")

        XCTAssertNoThrow(value = try decoder.decode(String.self, from: convertFromHexString("0x7F657374726561646D696E67FF")))
        XCTAssertEqual((value as! String), "streaming")
    }

    func testAppendixAComplexExamples10() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [_ "Fun": true, "Amt": -2]

        struct Test: Decodable {

            private enum CodingKeys: String, CodingKey {
                case key1 = "Fun"
                case key2 = "Amt"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var value: Any!

                XCTAssertNoThrow(value = try container.decode(Bool.self, forKey: .key1))
                XCTAssertEqual((value as! Bool), true)

                XCTAssertNoThrow(value = try container.decode(Int16.self, forKey: .key2))
                XCTAssertEqual((value as! Int16), -2)
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test.self, from: convertFromHexString("0xBF6346756EF563416D7421FF")))
    }

    func testDecodeSingleValues() {
        struct TestDecodeSingleValue: Decodable {

            private static var block: ((SingleValueDecodingContainer) throws -> Void)?

            static func decode(from data: Data, action: @escaping (SingleValueDecodingContainer) throws -> Void) {
                block = action
                defer { block = nil }

                XCTAssertNoThrow(try CBORDecoder().decode(TestDecodeSingleValue.self, from: data))
            }

            init(from decoder: Decoder) throws {
                try TestDecodeSingleValue.block?(decoder.singleValueContainer())
            }
        }

        TestDecodeSingleValue.decode(from: convertFromHexString("0xF6"))                 { XCTAssertEqual($0.decodeNil(), true) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xF5"))                 { XCTAssertEqual($0.decodeNil(), false) }

        TestDecodeSingleValue.decode(from: convertFromHexString("0xF5"))                 { XCTAssertEqual(try $0.decode(Bool.self), true) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xF4"))                 { XCTAssertEqual(try $0.decode(Bool.self), false) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x21"))                 { XCTAssertEqual(try $0.decode(Int8.self), -2) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1875"))               { XCTAssertEqual(try $0.decode(Int8.self), 117) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3944FD"))             { XCTAssertEqual(try $0.decode(Int16.self), -17662) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1A000F4240"))         { XCTAssertEqual(try $0.decode(Int32.self), 1000000) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3B002366A4CF29EB2D")) { XCTAssertEqual(try $0.decode(Int64.self), -9964482221173550) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3BFFFFFFFFFFFFFFFF")) { XCTAssertEqual(try $0.decode(Int64.self), 0) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x17"))                 { XCTAssertEqual(try $0.decode(UInt8.self), 23) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x18FE"))               { XCTAssertEqual(try $0.decode(UInt8.self), 254) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x196203"))             { XCTAssertEqual(try $0.decode(UInt16.self), 25091) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1A8C4F7DE3"))         { XCTAssertEqual(try $0.decode(UInt32.self), 2354019811) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1BFFFFFFFFFFFFFFFF")) { XCTAssertEqual(try $0.decode(UInt64.self), .max) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xF93C00"))             { XCTAssertEqual(try $0.decode(Float.self), 1.0) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFA47C35000"))         { XCTAssertEqual(try $0.decode(Float.self), 100000.0) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFB3FF199999999999A")) { XCTAssertEqual(try $0.decode(Double.self), 1.1) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFA7F800000"))         { XCTAssertEqual(try $0.decode(Float.self), .infinity) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFA7F800001"))         { XCTAssertTrue((try $0.decode(Float.self)).isNaN) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFB7FF0000000000000")) { XCTAssertEqual(try $0.decode(Double.self), .infinity) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFB7FF0000000000001")) { XCTAssertTrue((try $0.decode(Double.self)).isNaN) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0xD8246443424F52"))     { XCTAssertEqual(try $0.decode(String.self), "CBOR") }

        #if arch(arm64) || arch(x86_64)
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3B7FFFFFFFFFFFFFFF")) { XCTAssertEqual(try $0.decode(Int.self), .min) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1BFFFFFFFFFFFFFFFF")) { XCTAssertEqual(try $0.decode(UInt.self), .max) }
        #elseif arch(arm) || arch(i386)
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3A7FFFFFFF"))         { XCTAssertEqual(try $0.decode(Int.self), .min) }
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1AFFFFFFFF"))         { XCTAssertEqual(try $0.decode(UInt.self), .max) }
        #endif // #if arch(arm64) || arch(x86_64)
    }

    func testDecodeSingleValueFailureCases() {
        struct TestDecodeSingleValue: Decodable {

            private static var block: ((SingleValueDecodingContainer) throws -> Any)?

            static func decode(from data: Data, action: @escaping (SingleValueDecodingContainer) throws -> Any) {
                block = action
                defer { block = nil }

                XCTAssertThrowsError(try CBORDecoder().decode(TestDecodeSingleValue.self, from: data))
            }

            init(from decoder: Decoder) throws {
                _ = try TestDecodeSingleValue.block?(decoder.singleValueContainer())
            }
        }

        TestDecodeSingleValue.decode(from: convertFromHexString("0xF6"))                 { try $0.decode(Bool.self) } // Decode any type from nil
        TestDecodeSingleValue.decode(from: convertFromHexString("0x02"))                 { try $0.decode(Bool.self) } // Decode bool from other type
        TestDecodeSingleValue.decode(from: convertFromHexString("0x397FFF"))             { try $0.decode(Int8.self) } // Integer too big
        TestDecodeSingleValue.decode(from: convertFromHexString("0x6161"))               { try $0.decode(Int16.self) } // Decode integer from other type
        TestDecodeSingleValue.decode(from: convertFromHexString("0x1BFFFFFFFFFFFFFFFF")) { try $0.decode(Int32.self) } // Decode integer from other type
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3BFFFFFFFFFFFFFFF0")) { try $0.decode(Int64.self) } // Decode integer from large signed
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3BFFFFFFFFFFFFFFFE")) { try $0.decode(Int64.self) } // Decode integer from large signed
        TestDecodeSingleValue.decode(from: convertFromHexString("0x39FFFF"))             { try $0.decode(UInt8.self) } // Integer too big
        TestDecodeSingleValue.decode(from: convertFromHexString("0x6161"))               { try $0.decode(UInt16.self) } // Decode integer from other type
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3B7FFFFFFFFFFFFFFF")) { try $0.decode(UInt32.self) } // Decode integer from large signed
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3BFFFFFFFFFFFFFFFF")) { try $0.decode(UInt64.self) } // Decode unsigned from large signed
        TestDecodeSingleValue.decode(from: convertFromHexString("0x3BFFFFFFFFFFFFFFFE")) { try $0.decode(UInt64.self) } // Decode unsigned from large signed
        TestDecodeSingleValue.decode(from: convertFromHexString("0x01"))                 { try $0.decode(String.self) } // Decode string from other type
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFB3FF199999999999A")) { try $0.decode(Float.self) } // Precise Double into Float
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFB3FF199999999999A")) { try $0.decode(Float.self) } // Precise Double into Float16
        TestDecodeSingleValue.decode(from: convertFromHexString("0xFA3F8CCCCD"))         { try $0.decode(Float16.self) } // Precise Float into Float16
    }

    func testDecodeStringKeyedValues() {
        struct TestDecodeKeyedValues: Decodable {

            private enum CodingKeys: String, CodingKey {
                case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                XCTAssertEqual(try container.decodeNil(forKey: .a), true)
                XCTAssertEqual(try container.decode(Bool.self, forKey: .b), false)
                XCTAssertEqual(try container.decode(Bool.self, forKey: .c), true)
                XCTAssertEqual(try container.decode(Int8.self, forKey: .d), -2)
                XCTAssertEqual(try container.decode(Int8.self, forKey: .e), 117)
                XCTAssertEqual(try container.decode(Int16.self, forKey: .f), -17662)
                XCTAssertEqual(try container.decode(Int32.self, forKey: .g), 1000000)
                XCTAssertEqual(try container.decode(Int64.self, forKey: .h), -9964482221173550)
                XCTAssertEqual(try container.decode(Int64.self, forKey: .i), 0)
                XCTAssertEqual(try container.decode(UInt8.self, forKey: .j), 23)
                XCTAssertEqual(try container.decode(UInt8.self, forKey: .k), 254)
                XCTAssertEqual(try container.decode(UInt16.self, forKey: .l), 25091)
                XCTAssertEqual(try container.decode(UInt32.self, forKey: .m), 2354019811)
                XCTAssertEqual(try container.decode(UInt64.self, forKey: .n), .max)
                XCTAssertEqual(try container.decode(Float16.self, forKey: .o), 1.0)
                XCTAssertEqual(try container.decode(Float.self, forKey: .p), 100000.0)
                XCTAssertEqual(try container.decode(Double.self, forKey: .q), 1.1)
                XCTAssertEqual(try container.decode(String.self, forKey: .r), "CBOR")
                XCTAssertEqual(try container.decode(Int.self, forKey: .s), .min)
                XCTAssertEqual(try container.decode(UInt.self, forKey: .t), .max)
            }
        }

        var encodedData = convertFromHexString("0xB4 6161F6 6162F4 6163F5 616421 61651875 61663944FD 61671A000F4240 61683B002366A4CF29EB2D 61693BFFFFFFFFFFFFFFFF 616A17 616B18FE 616C196203 616D1A8C4F7DE3 616E1BFFFFFFFFFFFFFFFF 616FF93C00 6170FA47C35000 6171FB3FF199999999999A 6172D8246443424F52")

        #if arch(arm64) || arch(x86_64)
        encodedData.append(convertFromHexString("61733B7FFFFFFFFFFFFFFF 61741BFFFFFFFFFFFFFFFF"))
        #elseif arch(arm) || arch(i386)
        encodedData.append(convertFromHexString("61733A7FFFFFFF 61741AFFFFFFFF"))
        #else
        #error("Unsupported Architecture")
        #endif // #if arch(arm64) || arch(x86_64)

        XCTAssertNoThrow(try CBORDecoder().decode(TestDecodeKeyedValues.self, from: encodedData))
    }

    func testDecodeIntKeyedValues() {
        struct TestDecodeKeyedValues: Decodable {

            private enum CodingKeys: Int, CodingKey {
                case a = 0,  b = 1,  c = 2,  d = 3,  e = 4,
                     f = 5,  g = 6,  h = 7,  i = 8,  j = 9,
                     k = 10, l = 11, m = 12, n = 13, o = 14,
                     p = 15, q = 16, r = 17, s = 18, t = 19
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                XCTAssertEqual(try container.decodeNil(forKey: .a), true)
                XCTAssertEqual(try container.decode(Bool.self, forKey: .b), false)
                XCTAssertEqual(try container.decode(Bool.self, forKey: .c), true)
                XCTAssertEqual(try container.decode(Int8.self, forKey: .d), -2)
                XCTAssertEqual(try container.decode(Int8.self, forKey: .e), 117)
                XCTAssertEqual(try container.decode(Int16.self, forKey: .f), -17662)
                XCTAssertEqual(try container.decode(Int32.self, forKey: .g), 1000000)
                XCTAssertEqual(try container.decode(Int64.self, forKey: .h), -9964482221173550)
                XCTAssertEqual(try container.decode(Int64.self, forKey: .i), 0)
                XCTAssertEqual(try container.decode(UInt8.self, forKey: .j), 23)
                XCTAssertEqual(try container.decode(UInt8.self, forKey: .k), 254)
                XCTAssertEqual(try container.decode(UInt16.self, forKey: .l), 25091)
                XCTAssertEqual(try container.decode(UInt32.self, forKey: .m), 2354019811)
                XCTAssertEqual(try container.decode(UInt64.self, forKey: .n), .max)
                XCTAssertEqual(try container.decode(Float16.self, forKey: .o), 1.0)
                XCTAssertEqual(try container.decode(Float.self, forKey: .p), 100000.0)
                XCTAssertEqual(try container.decode(Double.self, forKey: .q), 1.1)
                XCTAssertEqual(try container.decode(String.self, forKey: .r), "CBOR")
                XCTAssertEqual(try container.decode(Int.self, forKey: .s), .min)
                XCTAssertEqual(try container.decode(UInt.self, forKey: .t), .max)
            }
        }

        var encodedData = convertFromHexString("0xB4 00F6 01F4 02F5 0321 041875 053944FD 061A000F4240 073B002366A4CF29EB2D 083BFFFFFFFFFFFFFFFF 0917 0A18FE 0B196203 0C1A8C4F7DE3 0D1BFFFFFFFFFFFFFFFF 0EF93C00 0FFA47C35000 10FB3FF199999999999A 11D8246443424F52")

        #if arch(arm64) || arch(x86_64)
        encodedData.append(convertFromHexString("123B7FFFFFFFFFFFFFFF 131BFFFFFFFFFFFFFFFF"))
        #elseif arch(arm) || arch(i386)
        encodedData.append(convertFromHexString("123A7FFFFFFF 131AFFFFFFFF"))
        #else
        #error("Unsupported Architecture")
        #endif // #if arch(arm64) || arch(x86_64)

        XCTAssertNoThrow(try CBORDecoder().decode(TestDecodeKeyedValues.self, from: encodedData))
    }

    func testDecodeKeyedValuesFailureCases() {
        struct TestDecodeKeyedValue<T>: Decodable where T: Decodable {

            private enum CodingKeys: String, CodingKey {
                case a, b
            }

            static func decode(_ type: T.Type, from data: Data) {
                _ = try? CBORDecoder().decode(TestDecodeKeyedValue.self, from: data)
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                // Key exists, wrong type
                XCTAssertThrowsError(try container.decode(T.self, forKey: .a))
                XCTAssertThrowsError(try container.nestedUnkeyedContainer(forKey: .a))
                XCTAssertThrowsError(try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .a))

                // Key doesn't exist
                XCTAssertThrowsError(try container.decodeNil(forKey: .b))
                XCTAssertThrowsError(try container.decode(T.self, forKey: .b))
                XCTAssertThrowsError(try container.decode(Int.self, forKey: .b))
                XCTAssertThrowsError(try container.nestedUnkeyedContainer(forKey: .b))
                XCTAssertThrowsError(try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .b))
            }
        }

        TestDecodeKeyedValue.decode(Bool.self, from: convertFromHexString("0xA16161F6")) // Decode any type from nil
        TestDecodeKeyedValue.decode(Bool.self, from: convertFromHexString("0xA1616102")) // Decode bool from other type
        TestDecodeKeyedValue.decode(Int8.self, from: convertFromHexString("0xA16161397FFF")) // Integer too big
        TestDecodeKeyedValue.decode(Int16.self, from: convertFromHexString("0xA161616161")) // Decode integer from other type
        TestDecodeKeyedValue.decode(Int32.self, from: convertFromHexString("0xA161611BFFFFFFFFFFFFFFFF")) // Decode integer from other type
        TestDecodeKeyedValue.decode(Int64.self, from: convertFromHexString("0xA161613BFFFFFFFFFFFFFFF0")) // Decode integer from large signed
        TestDecodeKeyedValue.decode(Int64.self, from: convertFromHexString("0xA161613BFFFFFFFFFFFFFFFE")) // Decode integer from large signed
        TestDecodeKeyedValue.decode(UInt8.self, from: convertFromHexString("0xA1616119FFFF")) // Integer too big
        TestDecodeKeyedValue.decode(UInt16.self, from: convertFromHexString("0xA161616161")) // Decode integer from other type
        TestDecodeKeyedValue.decode(UInt32.self, from: convertFromHexString("0xA161613B7FFFFFFFFFFFFFFF")) // Decode integer from large signed
        TestDecodeKeyedValue.decode(UInt64.self, from: convertFromHexString("0xA161613BFFFFFFFFFFFFFFFF")) // Decode unsigned from large signed
        TestDecodeKeyedValue.decode(UInt64.self, from: convertFromHexString("0xA161613BFFFFFFFFFFFFFFFE")) // Decode unsigned from large signed
        TestDecodeKeyedValue.decode(String.self, from: convertFromHexString("0xA1616101")) // Decode string from other type
    }

    func testDecodeUnkeyedValues() {
        struct TestDecodeUnkeyedValues: Decodable {

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                XCTAssertEqual(container.count, 20)

                XCTAssertEqual(try container.decodeNil(), true)
                XCTAssertEqual(try container.decodeNil(), false) // Decoding nil for non-nil value returns false and does NOT increment index
                XCTAssertEqual(try container.decode(Bool.self), false)
                XCTAssertEqual(try container.decode(Bool.self), true)
                XCTAssertEqual(try container.decode(Int8.self), -2)
                XCTAssertEqual(try container.decode(Int8.self), 117)
                XCTAssertEqual(try container.decode(Int16.self), -17662)
                XCTAssertEqual(try container.decode(Int32.self), 1000000)
                XCTAssertEqual(try container.decode(Int64.self), -9964482221173550)
                XCTAssertEqual(try container.decode(Int64.self), 0)
                XCTAssertEqual(try container.decode(UInt8.self), 23)
                XCTAssertEqual(try container.decode(UInt8.self), 254)
                XCTAssertEqual(try container.decode(UInt16.self), 25091)
                XCTAssertEqual(try container.decode(UInt32.self), 2354019811)
                XCTAssertEqual(try container.decode(UInt64.self), .max)
                XCTAssertEqual(try container.decode(Float16.self), 1.0)
                XCTAssertEqual(try container.decode(Float.self), 100000.0)
                XCTAssertEqual(try container.decode(Double.self), 1.1)
                XCTAssertEqual(try container.decode(String.self), "CBOR")
                XCTAssertEqual(try container.decode(Int.self), .min)
                XCTAssertEqual(try container.decode(UInt.self), .max)
            }
        }

        var encodedData = convertFromHexString("0x94 F6 F4 F5 21 1875 3944FD 1A000F4240 3B002366A4CF29EB2D 3BFFFFFFFFFFFFFFFF 17 18FE 196203 1A8C4F7DE3 1BFFFFFFFFFFFFFFFF F93C00 FA47C35000 FB3FF199999999999A D8246443424F52")

        #if arch(arm64) || arch(x86_64)
        encodedData.append(convertFromHexString("3B7FFFFFFFFFFFFFFF 1BFFFFFFFFFFFFFFFF"))
        #elseif arch(arm) || arch(i386)
        encodedData.append(convertFromHexString("3A7FFFFFFF 1AFFFFFFFF"))
        #else
        #error("Unsupported Architecture")
        #endif // #if arch(arm64) || arch(x86_64)

        XCTAssertNoThrow(try CBORDecoder().decode(TestDecodeUnkeyedValues.self, from: encodedData))
    }

    func testDecodeNestedUnkeyedContainers() {
        struct TestDecodeNestedUnkeyedContainers: Decodable {

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var nestedContainer = try container.nestedUnkeyedContainer()

                XCTAssertEqual(try nestedContainer.decode(UInt16.self), 9)
                XCTAssertEqual(try container.decode(UInt32.self), 2)
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(TestDecodeNestedUnkeyedContainers.self, from: convertFromHexString("0x82810902")))
    }

    func testDecodeUnkeyedValuesFailureCases1() {
        struct TestDecodeUnkeyedValue<T>: Decodable where T: Decodable {

            private enum CodingKeys: String, CodingKey {
                case a
            }

            static func decode(_ type: T .Type, from data: Data) {
                _ = try? CBORDecoder().decode(TestDecodeUnkeyedValue.self, from: data)
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()

                // Wrong type
                XCTAssertThrowsError(try container.decode(T.self))
                XCTAssertThrowsError(try container.nestedUnkeyedContainer())
                XCTAssertThrowsError(try container.nestedContainer(keyedBy: CodingKeys.self))
            }
        }

        TestDecodeUnkeyedValue.decode(Bool.self, from: convertFromHexString("0x80")) // Decode any type from empty array
        TestDecodeUnkeyedValue.decode(Bool.self, from: convertFromHexString("0x81F6")) // Decode any type from nil
        TestDecodeUnkeyedValue.decode(Bool.self, from: convertFromHexString("0x8102")) // Decode bool from other type
        TestDecodeUnkeyedValue.decode(Int8.self, from: convertFromHexString("0x81397FFF")) // Integer too big
        TestDecodeUnkeyedValue.decode(Int16.self, from: convertFromHexString("0x816161")) // Decode integer from other type
        TestDecodeUnkeyedValue.decode(Int32.self, from: convertFromHexString("0x811BFFFFFFFFFFFFFFFF")) // Decode integer from other type
        TestDecodeUnkeyedValue.decode(Int64.self, from: convertFromHexString("0x813BFFFFFFFFFFFFFFF0")) // Decode integer from large signed
        TestDecodeUnkeyedValue.decode(Int64.self, from: convertFromHexString("0x813BFFFFFFFFFFFFFFFE")) // Decode integer from large signed
        TestDecodeUnkeyedValue.decode(UInt8.self, from: convertFromHexString("0x8119FFFF")) // Integer too big
        TestDecodeUnkeyedValue.decode(UInt16.self, from: convertFromHexString("0x816161")) // Decode integer from other type
        TestDecodeUnkeyedValue.decode(UInt32.self, from: convertFromHexString("0x813B7FFFFFFFFFFFFFFF")) // Decode integer from large signed
        TestDecodeUnkeyedValue.decode(UInt64.self, from: convertFromHexString("0x813BFFFFFFFFFFFFFFFF")) // Decode unsigned from large signed
        TestDecodeUnkeyedValue.decode(UInt64.self, from: convertFromHexString("0x813BFFFFFFFFFFFFFFFE")) // Decode unsigned from large signed
        TestDecodeUnkeyedValue.decode(String.self, from: convertFromHexString("0x8101")) // Decode string from other type
    }

    func testDecodeUnkeyedValuesFailureCases2() {
        struct TestDecodeUnkeyedValue: Decodable {

            private static var block: ((inout UnkeyedDecodingContainer) throws -> Void)?

            static func decode(from data: Data, action: @escaping (inout UnkeyedDecodingContainer) throws -> Void) {
                block = action
                defer { block = nil }

                _ = try? CBORDecoder().decode(TestDecodeUnkeyedValue.self, from: data)
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                try TestDecodeUnkeyedValue.block?(&container)
            }
        }

        // Empty array
        TestDecodeUnkeyedValue.decode(from: convertFromHexString("0x80")) { container in
            XCTAssertThrowsError(try container.decodeNil())
            XCTAssertThrowsError(try container.superDecoder())
            XCTAssertThrowsError(try container.decode(UInt.self))
            XCTAssertThrowsError(try container.decode(Int.self))
            XCTAssertThrowsError(try container.decode(Float.self))
        }

        // Nil value
        TestDecodeUnkeyedValue.decode(from: convertFromHexString("0x81F6")) { container in
            XCTAssertThrowsError(try container.decode(UInt.self))
            XCTAssertThrowsError(try container.decode(Int.self))
            XCTAssertThrowsError(try container.decode(Float.self))
        }
    }

    func testDecodeDecimalFractionsAndBigfloats() {
        // Success
        do {
            let fraction = try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0xC482010F"))
            XCTAssertEqual(fraction.exponent, 1)
            XCTAssertEqual(fraction.mantissa, 15)
        } catch { XCTFail(error.localizedDescription) }

        do {
            let fraction = try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, Int64>.self, from: convertFromHexString("0xC48201C2410F"))
            XCTAssertEqual(fraction.exponent, 1)
            XCTAssertEqual(fraction.mantissa, 15)
        } catch { XCTFail(error.localizedDescription) }

        do {
            let fraction = try CBORDecoder().decode(CBOR.DecimalFraction<Int64, Int64>.self, from: convertFromHexString("0xC482202E"))
            XCTAssertEqual(fraction.exponent, -1)
            XCTAssertEqual(fraction.mantissa, -15)
        } catch { XCTFail(error.localizedDescription) }

        do {
            let fraction = try CBORDecoder().decode(CBOR.Bigfloat<UInt64, UInt64>.self, from: convertFromHexString("0xC582010F"))
            XCTAssertEqual(fraction.exponent, 1)
            XCTAssertEqual(fraction.mantissa, 15)
        } catch { XCTFail(error.localizedDescription) }

        do {
            let fraction = try CBORDecoder().decode(CBOR.Bigfloat<UInt64, Int64>.self, from: convertFromHexString("0xC58201C3410E"))
            XCTAssertEqual(fraction.exponent, 1)
            XCTAssertEqual(fraction.mantissa, -15)
        } catch { XCTFail(error.localizedDescription) }

        do {
            let fraction = try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC582202E"))
            XCTAssertEqual(fraction.exponent, -1)
            XCTAssertEqual(fraction.mantissa, -15)
        } catch { XCTFail(error.localizedDescription) }

        // Failure
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0xC4823B80000000000000003B8FFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC5823B80000000000000003B8FFFFFFFFFFFFFFF")))

        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0xC482003B8FFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<Int64, Int64>.self, from: convertFromHexString("0xC4823BFFFFFFFFFFFFFFFE00")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC582003B8FFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC582003BFFFFFFFFFFFFFFFE")))

        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0x80")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0x80")))

        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0xC582202E")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC482202E")))

        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<UInt64, UInt64>.self, from: convertFromHexString("0xC48200C24AFFFFFFFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<Int64, Int64>.self, from: convertFromHexString("0xC48200C248FFFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, Int64>.self, from: convertFromHexString("0xC58200C34AFFFFFFFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, UInt64>.self, from: convertFromHexString("0xC58200C348FFFFFFFFFFFFFFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<Int64, UInt64>.self, from: convertFromHexString("0xC58200C348FFFFFFFFFFFFFFFE")))

        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<Int8, Int8>.self, from: convertFromHexString("0xC4823944FD3944FD")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.DecimalFraction<Int8, Int8>.self, from: convertFromHexString("0xC482203944FD")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<UInt8, UInt8>.self, from: convertFromHexString("0xC58219FFFF19FFFF")))
        XCTAssertThrowsError(try CBORDecoder().decode(CBOR.Bigfloat<UInt8, UInt8>.self, from: convertFromHexString("0xC58218FF19FFFF")))
    }

    func testFailureCases() {
        let decoder = CBORDecoder()

        XCTAssertThrowsError(try decoder.decode(String.self, from: Data()))                                 // Empty Data
        XCTAssertThrowsError(try decoder.decode(String.self, from: convertFromHexString("0x62")))           // Invalid CBOR
        XCTAssertThrowsError(try decoder.decode([String].self, from: convertFromHexString("0xF6")))         // Decode Array from nil
        XCTAssertThrowsError(try decoder.decode([String].self, from: convertFromHexString("0xF5")))         // Decode Array from a Bool
        XCTAssertThrowsError(try decoder.decode([String: String].self, from: convertFromHexString("0xF6"))) // Decode Dictionary from nil
        XCTAssertThrowsError(try decoder.decode([String: String].self, from: convertFromHexString("0xF5"))) // Decode Dictionary from a Bool
        XCTAssertThrowsError(try decoder.decode(CBOR.NegativeUInt64.self, from: convertFromHexString("0x01"))) // NegativeUInt64 from unsigned
    }

    func testDecoderUserInfo() {
        let decoder = CBORDecoder()
        decoder.userInfo[CodingUserInfoKey(rawValue: "CBORDecoderKey")!] = -33781

        struct Test: Decodable {

            init(from decoder: Decoder) throws {
                let value = decoder.userInfo[CodingUserInfoKey(rawValue: "CBORDecoderKey")!]

                XCTAssertNotNil(value)
                XCTAssertTrue(value! is Int)
                XCTAssertEqual(value as! Int, -33781)
            }
        }

        XCTAssertNoThrow(try decoder.decode(Test.self, from: convertFromHexString("0x00")))
    }

    func testSuperDecoder1() {
        class Test1: Decodable {
            private enum CodingKeys: String, CodingKey {
                case a
            }
            required init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                let keyedContainer = try container.nestedContainer(keyedBy: CodingKeys.self)
                var arrayContainer = try keyedContainer.nestedUnkeyedContainer(forKey: .a)

                XCTAssertEqual(try arrayContainer.decode(Int.self), 0)
                XCTAssertEqual(try arrayContainer.decode(UInt8.self), 1)
            }
        }
        class Test2: Test1 {
            required init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                try super.init(from: try container.superDecoder())

                XCTAssertEqual(try container.decode(Int32.self), 2)
                XCTAssertEqual(try container.decode(Int16.self), 3)
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0x8381A161618200010203")))
    }

    func testSuperDecoder2() {
        class Test1: Decodable {

            private enum CodingKeys1: String, CodingKey {
                case a
            }
            private enum CodingKeys2: String, CodingKey {
                case b
                case c
            }

            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys1.self)
                let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys2.self, forKey: .a)

                XCTAssertEqual(try nestedContainer.decodeNil(forKey: .b), true)
                XCTAssertEqual(try nestedContainer.decode(Bool.self, forKey: .c), false)
            }
        }
        class Test2: Test1 {

            private enum CodingKeys: String, CodingKey {
                case t
            }

            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                try super.init(from: container.superDecoder(forKey: .t))
            }
        }
        class Test3: Test1 {

            private enum CodingKeys: String, CodingKey {
                case t
            }

            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                try super.init(from: container.superDecoder())
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xA16174A16161A26162F66163F4")))
        XCTAssertNoThrow(try CBORDecoder().decode(Test3.self, from: convertFromHexString("0xA1657375706572A16161A26162F66163F4")))
    }

    func testSuperDecoder3() {
        class Test1: Decodable {
            required init(from decoder: Decoder) throws { }
        }
        class Test2: Test1 {
            required init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                try super.init(from: container.superDecoder())

                XCTAssertEqual(try container.decode(UInt.self), 1)
                XCTAssertEqual(try container.decode(Int64.self), 2)
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0x83F60102")))
    }

    func testSuperDecoder4() {
        class Test1: Decodable {
            required init(from decoder: Decoder) throws { }
        }
        class Test2: Test1 {
            private enum CodingKeys: String, CodingKey {
                case a
                case b
            }
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                try super.init(from: container.superDecoder())

                XCTAssertEqual(try container.decode(UInt.self, forKey: .a), 1)
                XCTAssertEqual(try container.decode(Int64.self, forKey: .b), 2)
            }
        }

        XCTAssertNoThrow(try CBORDecoder().decode(Test2.self, from: convertFromHexString("0xA2616101616202")))
    }

    // MARK: Private Methods

    private func convertFromHexString(_ string: String) -> Data {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
        hex = hex.starts(with: "0x") ? String(hex.dropFirst(2)) : hex

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

    private func rfc3339Date() -> Date {
        // 2013-03-21T20:04:00Z
        var components = DateComponents()
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2013
        components.month = 03
        components.day = 21
        components.hour = 20
        components.minute = 04
        components.second = 00

        return Calendar.current.date(from: components)!
    }
}

// swiftlint:enable nesting function_body_length force_cast identifier_name opening_brace comma implicitly_unwrapped_optional number_separator force_unwrapping closure_spacing
