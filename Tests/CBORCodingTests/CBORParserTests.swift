//
//  CBORParserTests.swift
//  CBORCodingTests
//
//  Created by Joseph Newton on 5/26/19.
//  Copyright © 2019 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable function_body_length force_cast comma force_try implicitly_unwrapped_optional number_separator force_unwrapping

@testable import CBORCoding
import Half
import XCTest

// MARK: - CBORParserTests Definition

class CBORParserTests: XCTestCase {

    // MARK: Test Methods

    func testAppendixASimpleExamples() {
        // Test Examples taken from Appendix A of RFC 7049

        var value: Any!

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x00")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x01")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 1)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x0A")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 10)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x17")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 23)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1818")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 24)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1819")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 25)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1864")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 100)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1903E8")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 1000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1A000F4240")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 1000000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1B000000E8D4A51000")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 1000000000000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x1BFFFFFFFFFFFFFFFF")))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 18446744073709551615)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC249010000000000000000"))) // 18446744073709551616
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertTrue((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x3BFFFFFFFFFFFFFFFF"))) // -18446744073709551616
        XCTAssertTrue(value is CBOR.NegativeUInt64)
        XCTAssertEqual((value as! CBOR.NegativeUInt64).rawValue, .min)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC349010000000000000000"))) // -18446744073709551617
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertFalse((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x20")))
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, -1)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x29")))
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, -10)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x3863")))
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, -100)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x3903E7")))
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, -1000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x3B7FFFFFFFFFFFFFFF"))) // NOT part of RFC 7049 examples
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, .min)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF90000")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 0.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF98000")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, -0.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF93C00")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 1.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFB3FF199999999999A")))
        XCTAssertTrue(value is Double)
        XCTAssertEqual(value as! Double, 1.1)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF93E00")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 1.5)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF97BFF")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 65504.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFA47C35000")))
        XCTAssertTrue(value is Float)
        XCTAssertEqual(value as! Float, 100000.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFA7F7FFFFF")))
        XCTAssertTrue(value is Float)
        XCTAssertEqual(value as! Float, 3.4028234663852886e+38)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFB7E37E43C8800759C")))
        XCTAssertTrue(value is Double)
        XCTAssertEqual(value as! Double, 1.0e+300)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF90001")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 5.960464477539063e-8)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF90400")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, 0.00006103515625)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF9C400")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, -4.0)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFBC010666666666666")))
        XCTAssertTrue(value is Double)
        XCTAssertEqual(value as! Double, -4.1)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF97C00")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, .infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF97E00")))
        XCTAssertTrue(value is Half)
        XCTAssertTrue((value as! Half).isNaN)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF9FC00")))
        XCTAssertTrue(value is Half)
        XCTAssertEqual(value as! Half, -.infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFA7F800000")))
        XCTAssertTrue(value is Float)
        XCTAssertEqual(value as! Float, .infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFA7FC00000")))
        XCTAssertTrue(value is Float)
        XCTAssertTrue((value as! Float).isNaN)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFAFF800000")))
        XCTAssertTrue(value is Float)
        XCTAssertEqual(value as! Float, -.infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFB7FF0000000000000")))
        XCTAssertTrue(value is Double)
        XCTAssertEqual(value as! Double, .infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFB7FF8000000000000")))
        XCTAssertTrue(value is Double)
        XCTAssertTrue((value as! Double).isNaN)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xFBFFF0000000000000")))
        XCTAssertTrue(value is Double)
        XCTAssertEqual(value as! Double, -.infinity)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF4")))
        XCTAssertTrue(value is Bool)
        XCTAssertFalse(value as! Bool)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF5")))
        XCTAssertTrue(value is Bool)
        XCTAssertTrue(value as! Bool)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF6")))
        XCTAssertTrue(value is CBOR.Null)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF7")))
        XCTAssertTrue(value is CBOR.Undefined)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF0")))
        XCTAssertTrue(value is CBOR.SimpleValue)
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 16)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF818")))
        XCTAssertTrue(value is CBOR.SimpleValue)
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 24)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xF8FF")))
        XCTAssertTrue(value is CBOR.SimpleValue)
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 255)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC074323031332D30332D32315432303A30343A30305A")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual(value as! Date, rfc3339Date())

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC11A514B67B0")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC1FB41D452D9EC200000")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240.5))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD74401020304")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x01020304"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD818456449455446")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x6449455446"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD82076687474703A2F2F7777772E6578616D706C652E636F6D")))
        XCTAssertTrue(value is URL)
        XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x40")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, Data())

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x4401020304")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x01020304"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x60")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x6161")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "a")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x6449455446")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "IETF")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x62225C")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "\"\\")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x62C3BC")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "\u{00FC}")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x63E6B0B4")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "\u{6C34}")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x64F0908591")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "\u{10151}")
    }

    func testAppendixAComplexExamples1() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // []
        //
        // [1, 2, 3]
        //
        // [1,  2,  3,  4,  5,  6,  7,
        //  8,  9,  10, 11, 12, 13, 14,
        //  15, 16, 17, 18, 19, 20, 21,
        //  22, 23, 24, 25]

        var value: Any!
        let dataStrings = [
            ("0x80",   "0x83010203",   "0x98190102030405060708090A0B0C0D0E0F101112131415161718181819"), // Definite Length Arrays
            ("0x9FFF", "0x9F010203FF", "0x9F0102030405060708090A0B0C0D0E0F101112131415161718181819FF")  // Indefinite Length Arrays
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.0)))
            XCTAssertTrue(value is ArrayWrapper<Any>)
            XCTAssertTrue((value as! ArrayWrapper<Any>).isEmpty)

            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.1)))
            XCTAssertTrue(value is ArrayWrapper<Any>)
            XCTAssertEqual((value as! ArrayWrapper<Any>).count, 3)
            XCTAssertTrue((value as! ArrayWrapper<Any>).array is [UInt64])
            XCTAssertEqual((value as! ArrayWrapper<Any>).array as! [UInt64], [1, 2, 3])

            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.2)))
            XCTAssertTrue(value is ArrayWrapper<Any>)
            XCTAssertEqual((value as! ArrayWrapper<Any>).count, 25)
            XCTAssertTrue((value as! ArrayWrapper<Any>).array is [UInt64])
            XCTAssertEqual((value as! ArrayWrapper<Any>).array as! [UInt64], [1,  2,  3,  4,  5,  6,  7,
                                                                              8,  9,  10, 11, 12, 13, 14,
                                                                              15, 16, 17, 18, 19, 20, 21,
                                                                              22, 23, 24, 25])
        }
    }

    func testAppendixAComplexExamples2() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // [1, [2, 3], [4, 5]]

        var value: Any!
        let dataStrings: [String] = [
            "0x8301820203820405",      // Definite/Definite/Definite Length Arrays
            "0x83018202039F0405FF",    // Definite/Definite/Indefinite Length Arrays
            "0x83019F0203FF820405",    // Definite/Indefinite/Definite Length Arrays
            "0x83019F0203FF9F0405FF",  // Definite/Indefinite/Indefinite Length Arrays
            "0x9F01820203820405FF",    // Indefinite/Definite/Definite Length Arrays
            "0x9F018202039F0405FFFF",  // Indefinite/Definite/Indefinite Length Arrays
            "0x9F019F0203FF820405FF",  // Indefinite/Indefinite/Definite Length Arrays
            "0x9F019F0203FF9F0405FFFF" // Indefinite/Indefinite/Indefinite Length Arrays
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is ArrayWrapper<Any>)
            XCTAssertEqual((value as! ArrayWrapper<Any>).count, 3)

            XCTAssertTrue((value as! ArrayWrapper<Any>).array[0] is UInt64)
            XCTAssertEqual((value as! ArrayWrapper<Any>).array[0] as! UInt64, 1)

            XCTAssertTrue((value as! ArrayWrapper<Any>)[1] is ArrayWrapper<Any>)
            XCTAssertTrue(((value as! ArrayWrapper<Any>)[1] as! ArrayWrapper<Any>).array is [UInt64])
            XCTAssertEqual(((value as! ArrayWrapper<Any>)[1] as! ArrayWrapper<Any>).array as! [UInt64], [2, 3])

            XCTAssertTrue((value as! ArrayWrapper<Any>)[2] is ArrayWrapper<Any>)
            XCTAssertTrue(((value as! ArrayWrapper<Any>)[2] as! ArrayWrapper<Any>).array is [UInt64])
            XCTAssertEqual(((value as! ArrayWrapper<Any>)[2] as! ArrayWrapper<Any>).array as! [UInt64], [4, 5])
        }
    }

    func testAppendixAComplexExamples3() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // [1: 2, 3: 4]
        //
        // [1: "a", 2: "b"]

        var value: Any!
        let dataStrings = [
            ("0xA201020304",   "0xA2016161026162"),  // Definite Length Maps
            ("0xBF01020304FF", "0xBF016161026162FF") // Indefinite Length Map
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.0)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 2)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] is UInt64)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] as! UInt64, 2)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 3)!] is UInt64)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 3)!] as! UInt64, 4)

            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.1)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 2)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] as! String, "a")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 2)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 2)!] as! String, "b")
        }
    }

    func testAppendixAComplexExamples4() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // ["a": 1, "b": [2, 3]]

        var value: Any!
        let dataStrings = [
            "0xA26161016162820203",    // Definite/Definite Length Containers
            "0xA261610161629F0203FF",  // Definite/Indefinite Length Containers
            "0xBF6161016162820203FF",  // Indefinite/Definite Length Containers
            "0xBF61610161629F0203FFFF" // Indefinite/Indefinite Length Containers
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 2)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "a")!] is UInt64)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "a")!] as! UInt64, 1)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] is ArrayWrapper<Any>)
            XCTAssertTrue(((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] as! ArrayWrapper<Any>).array is [UInt64])
            XCTAssertEqual(((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] as! ArrayWrapper<Any>).array as! [UInt64], [2 ,3])
        }
    }

    func testAppendixAComplexExamples5() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // ["a", ["b": "c"]]

        var value: Any!
        let dataStrings = [
            "0x826161A161626163",    // Definite/Definite Length Containers
            "0x826161BF61626163FF",  // Definite/Indefinite Length Containers
            "0x9F6161A161626163FF",  // Indefinite/Definite Length Containers
            "0x9F6161BF61626163FFFF" // Indefinite/Indefinite Length Containers
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is ArrayWrapper<Any>)
            XCTAssertEqual((value as! ArrayWrapper<Any>).count, 2)

            XCTAssertTrue((value as! ArrayWrapper<Any>).array[0] is String)
            XCTAssertEqual((value as! ArrayWrapper<Any>).array[0] as! String, "a")

            XCTAssertTrue((value as! ArrayWrapper<Any>)[1] is CodingKeyDictionary<Any>)
            XCTAssertTrue(((value as! ArrayWrapper<Any>)[1] as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] is String)
            XCTAssertEqual(((value as! ArrayWrapper<Any>)[1] as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] as! String, "c")
        }
    }

    func testAppendixAComplexExamples6() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"]

        var value: Any!
        let dataStrings = [
            "0xA56161614161626142616361436164614461656145",  // Definite Length Map
            "0xBF6161614161626142616361436164614461656145FF" // Indefinite Length Map
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 5)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "a")!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "a")!] as! String, "A")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "b")!] as! String, "B")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "c")!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "c")!] as! String, "C")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "d")!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "d")!] as! String, "D")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "e")!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "e")!] as! String, "E")
        }
    }

    func testAppendixAComplexExamples7() {
        // [1: "A", 2: "B", 3: "C", 4: "D", 5: "E"]

        var value: Any!
        let dataStrings = [
            "0xA5016141026142036143046144056145",  // Definite Length Map
            "0xBF016141026142036143046144056145FF" // Indefinite Length Map
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 5)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 1)!] as! String, "A")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 2)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 2)!] as! String, "B")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 3)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 3)!] as! String, "C")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 4)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 4)!] as! String, "D")

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 5)!] is String)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(intValue: 5)!] as! String, "E")
        }
    }

    func testAppendixAComplexExamples8() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // (_ h'0102', h'030405')

        var value: Any!

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x5F42010243030405FF")))
        XCTAssertTrue(value is CBOR.IndefiniteLengthData)

        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks.count, 2)
        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[0], convertFromHexString("0x0102"))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[1], convertFromHexString("0x030405"))
    }

    func testAppendixAComplexExamples9() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // (_ "strea", "ming")

        var value: Any!

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x7F657374726561646D696E67FF")))
        XCTAssertTrue(value is CBOR.IndefiniteLengthString)

        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks.count, 2)
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).stringValue, "streaming")
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[0], Data("strea".utf8))
        XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[1], Data("ming".utf8))
    }

    func testAppendixAComplexExamples10() {
        // Test Examples taken from Appendix A of RFC 7049
        //
        // ["Fun": true, "Amt": -2]

        var value: Any!
        let dataStrings = [
            "0xBF6346756EF563416D7421FF", // Definite Length Map
            "0xA26346756EF563416D7421"    // Indefinite Length Map
        ]

        for dataString in dataStrings {
            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString)))
            XCTAssertTrue(value is CodingKeyDictionary<Any>)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>).count, 2)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "Fun")!] is Bool)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "Fun")!] as! Bool, true)

            XCTAssertTrue((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "Amt")!] is Int64)
            XCTAssertEqual((value as! CodingKeyDictionary<Any>)[CBOR.CodingKey(stringValue: "Amt")!] as! Int64, -2)
        }
    }

    func testTaggedValues() {
        var value: Any!

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC074323031332D30332D32315432303A30343A30305A")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual((value as! Date), rfc3339Date())

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC101")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual((value as! Date), Date(timeIntervalSince1970: 1))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC1FB41D452D9EC200000")))
        XCTAssertTrue(value is Date)
        XCTAssertEqual((value as! Date), Date(timeIntervalSince1970: 1363896240.5))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC24100")))
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertTrue((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC25F420001420203FF"))) // Indefinite length data as Bignum content
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertTrue((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00010203"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC34100")))
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertFalse((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC482010F"))) // Decimal Fraction
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
        XCTAssertTrue((value as! [Any])[1] is UInt64)
        XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
        XCTAssertTrue((value as! [Any])[2] is UInt64)
        XCTAssertEqual((value as! [Any])[2] as! UInt64, 15)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC482202E"))) // Decimal Fraction
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
        XCTAssertTrue((value as! [Any])[1] is Int64)
        XCTAssertEqual((value as! [Any])[1] as! Int64, -1)
        XCTAssertTrue((value as! [Any])[2] is Int64)
        XCTAssertEqual((value as! [Any])[2] as! Int64, -15)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC4823B80000000000000003B8FFFFFFFFFFFFFFF"))) // Decimal Fraction
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
        XCTAssertTrue((value as! [Any])[1] is CBOR.NegativeUInt64)
        XCTAssertEqual(((value as! [Any])[1] as! CBOR.NegativeUInt64).rawValue, 0x8000000000000001)
        XCTAssertTrue((value as! [Any])[2] is CBOR.NegativeUInt64)
        XCTAssertEqual(((value as! [Any])[2] as! CBOR.NegativeUInt64).rawValue, 0x9000000000000000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC582010F"))) // Bigfloat
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
        XCTAssertTrue((value as! [Any])[1] is UInt64)
        XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
        XCTAssertTrue((value as! [Any])[2] is UInt64)
        XCTAssertEqual((value as! [Any])[2] as! UInt64, 15)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC58201C2410F"))) // Bigfloat
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
        XCTAssertTrue((value as! [Any])[1] is UInt64)
        XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
        XCTAssertTrue((value as! [Any])[2] is CBOR.Bignum)
        XCTAssertTrue(((value as! [Any])[2] as! CBOR.Bignum).isPositive)
        XCTAssertEqual(((value as! [Any])[2] as! CBOR.Bignum).content, convertFromHexString("0x0F"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xC5823B80000000000000003B8FFFFFFFFFFFFFFF"))) // Bigfloat
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
        XCTAssertTrue((value as! [Any])[1] is CBOR.NegativeUInt64)
        XCTAssertEqual(((value as! [Any])[1] as! CBOR.NegativeUInt64).rawValue, 0x8000000000000001)
        XCTAssertTrue((value as! [Any])[2] is CBOR.NegativeUInt64)
        XCTAssertEqual(((value as! [Any])[2] as! CBOR.NegativeUInt64).rawValue, 0x9000000000000000)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD54101")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD64101")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD74101")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD56161")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "a")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD66161")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "a")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD76161")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "a")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD82076687474703A2F2F7777772E6578616D706C652E636F6D")))
        XCTAssertTrue(value is URL)
        XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD820") + (try! CBOREncoder().encode(CBOR.IndefiniteLengthString(wrapping: ["http://www.", "example.com"])))))
        XCTAssertTrue(value is URL)
        XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD8226851304A5055673D3D")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, Data("CBOR".utf8))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD8216651304A505567")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, Data("CBOR".utf8))

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD8246443424F52")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "CBOR")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD8236573616C3F74")))
        XCTAssertTrue(value is String)
        XCTAssertEqual(value as! String, "sal?t")

        XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD9D9F74443424F52")))
        XCTAssertTrue(value is Data)
        XCTAssertEqual(value as! Data, Data("CBOR".utf8))
    }

    func testFailureCases() {
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x0101"))) // Multiple values outside of a container

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x18"))) // Unsigned - Missing extra byte
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x19"))) // Unsigned - Missing two extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x1A"))) // Unsigned - Missing four extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x1B"))) // Unsigned - Missing eight extra bytes

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x38"))) // Signed - Missing extra byte
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x39"))) // Signed - Missing two extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x3A"))) // Signed - Missing four extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x3B"))) // Signed - Missing eight extra bytes

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xF8"))) // Simple - Missing extra byte
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xFE"))) // Major Type 7, Unassigned code

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xF9"))) // Half - Missing two extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xFA"))) // Float - Missing four extra bytes
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xFB"))) // Double - Missing eight extra bytes

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC6")))   // Invalid tag
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xDF")))   // Invalid tag
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC0")))   // Empty Tag - Standard Date
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC1")))   // Empty Tag - Epoch Date
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC2")))   // Empty Tag - Positive Bignum
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC3")))   // Empty Tag - Negative Bignum
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4")))   // Empty Tag - Decimal Fraction
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC5")))   // Empty Tag - Bigfloat
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD5")))   // Empty Tag - Base64URL Conversion
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD6")))   // Empty Tag - Base64 Conversion
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD7")))   // Empty Tag - Base16 Conversion
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD818"))) // Empty Tag - Encoded CBOR Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD820"))) // Empty Tag - URI
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD821"))) // Empty Tag - Base64URL
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD822"))) // Empty Tag - Base64
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD823"))) // Empty Tag - Regular Expression
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD824"))) // Empty Tag - MIME Message

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD8216121"))) // Invalid Base64URL Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD8226121"))) // Invalid Base64 Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD8236129"))) // Invalid Regular Expression

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x7F")))         // Indefinite Length String - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x7F60")))       // Indefinite Length String - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x7F61")))       // Indefinite Length String - Chunk of Length 1 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x5F")))         // Indefinite Length Data - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x5F40")))       // Indefinite Length Data - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x5F41")))       // Indefinite Length Data - Chunk of Length 1 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x5F60FF")))     // Indefinite Length Data - String Chunks
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x9F")))         // Indefinite Length Array - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x9F60")))       // Indefinite Length Array - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xBF")))         // Indefinite Length Map - No Break
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xBF61616161"))) // Indefinite Length Map - No Break

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xFF")))         // "Break" Code - No Container
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x820000FF")))   // "Break" Code - Outside of Container
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x82FF")))       // "Break" Code - Inside Definite Length Array
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xA2FF")))       // "Break" Code - Inside Definite Length Map

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x62")))         // String of Length 2 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x6261")))       // String of Length 2 - 1 Element
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x42")))         // Data of Length 2 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x4200")))       // Data of Length 2 - 1 Element
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x82")))         // Array of Length 2 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x8200")))       // Array of Length 2 - 1 Element
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xA2")))         // Map of Length 2 - 0 Elements
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xA261616161"))) // Map of Length 2 - 1 Element
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xA16161")))     // Map with Key but no Value

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x64FEFEFFFF"))) // Invalid UTF-8 String
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD8207F61FE61FE61FF61FFFF"))) // Invalid UTF-8 URL
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD820682074207420702073203A202F202F206520782061206D2070206C2065202E2063206F206D"))) // Invalid URL ("h t t p s : / / e x a m p l e . c o m")
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xD8204100"))) // Invalid URL (Empty Byte Data)
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC06443424F52"))) // Invalid RFC3339 Date String ("CBOR")
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC16443424F52"))) // Invalid Epoch Date ("CBOR")

        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4420001")))     // Decimal Fraction Tag - Byte Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4811818")))     // Decimal Fraction Tag - Array of Length 1
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC49F1818")))     // Decimal Fraction Tag - Array of Length 1
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4821818")))     // Decimal Fraction Tag - Array of Length 2 - 1 Element
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4823B00")))     // Decimal Fraction Tag - Array of Length 2 - 1 Element - Empty Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC482003B")))     // Decimal Fraction Tag - Array of Length 2 - 2 Elements - 2nd Element Empty Data
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC48261616162"))) // Decimal Fraction Tag - ["a", "b"]
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC482016162")))   // Decimal Fraction Tag - [1, "b"]
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4821818C6")))   // Decimal Fraction Tag - [24, Invalid Tag]
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4821818C0")))   // Decimal Fraction Tag - [24, Date Tag]
        XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xC4821818C2")))   // Decimal Fraction Tag - [24, Empty Bignum Data]

        do {
            var value: Any?

            XCTAssertNoThrow(value = try CBORParser.parse(Data()))
            XCTAssertNil(value)

            XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0xD9D9F7")))
            XCTAssertNil(value)
        }
    }

    func testDecodeMapCodingKeys() {
        let encoder = CBOREncoder()

        var nonThrowingCodingKeys = [
            try! encoder.encode(Int8.min),
            try! encoder.encode(Int8.max),
            try! encoder.encode(Int16.min),
            try! encoder.encode(Int16.max),
            try! encoder.encode(Int32.min),
            try! encoder.encode(Int32.max),
            try! encoder.encode(Int.min),
            try! encoder.encode(Int.max),
            try! encoder.encode(UInt8.max),
            try! encoder.encode(UInt16.max),
            try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0xFFFF"))),
            try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0xFFFF")))
        ]
        var throwingCodingKeys = [
            try! encoder.encode(UInt64.max),
            try! encoder.encode(CBOR.NegativeUInt64(rawValue: 0x8000000000000001)),
            try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0xFFFFFFFFFFFFFFFF"))),
            try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0xFFFFFFFFFFFFFFFFFF"))),
            try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0xFFFFFFFFFFFFFFFFFF"))),
            try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x8000000000000001")))
        ]

        // Throws on 32-bit architectures but succeeds on 64-bit architectures.
        let archEdgeCases = [
            try! encoder.encode(Int64.min),
            try! encoder.encode(Int64.max),
            try! encoder.encode(UInt32.max),
            try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0x0100010001000100"))),
            try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x0100010001000100"))),
            try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x8000000000000000")))
        ]

        #if arch(arm64) || arch(x86_64)
        nonThrowingCodingKeys.append(contentsOf: archEdgeCases)
        #elseif arch(i386) || arch(arm)
        throwingCodingKeys.append(contentsOf: archEdgeCases)
        #endif // #if arch(arm64) || arch(x86_64)

        // swiftlint:disable trailing_closure
        for key in nonThrowingCodingKeys {
            XCTAssertNoThrow(try CBORParser.parse(convertFromHexString("0xA1\(key.map({ String(format: "%02X", $0) }).joined())6161")))
        }

        for key in throwingCodingKeys {
            XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0xA1\(key.map({ String(format: "%02X", $0) }).joined())6161")))
        }
        // swiftlint:enable trailing_closure
    }

    func testTypeParsing() {
        // Failure cases
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.unsigned.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.negative.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.bytes.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.string.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.array.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.map.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 28])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 28])))

        XCTAssertThrowsError(try CBORParser.type(for: Data()))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 24])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 25])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 24, 25])))
        XCTAssertThrowsError(try CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 25, 25, 25])))

        // Success cases
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.unsigned.rawValue | 24])) == UInt8.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.unsigned.rawValue | 25])) == UInt16.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.unsigned.rawValue | 26])) == UInt32.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.unsigned.rawValue | 27])) == UInt64.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.negative.rawValue | 24])) == Int8.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.negative.rawValue | 25])) == Int16.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.negative.rawValue | 26])) == Int32.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.negative.rawValue | 27])) == Int64.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.bytes.rawValue | 24])) == Data.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.string.rawValue | 24])) == String.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.array.rawValue | 24])) == Array<Any>.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.map.rawValue | 24])) == Dictionary<String, Any>.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 0])) == Date.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 2])) == Data.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 4])) == Array<Int>.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 21])) == Data.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 24, 24])) == Data.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 24, 32])) == String.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.tag.rawValue | 25, 0xD9, 0xF7])) == Data.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 19])) == CBOR.SimpleValue.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 20])) == Bool.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 22])) == CBOR.Null.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 23])) == CBOR.Undefined.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 24])) == CBOR.SimpleValue.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 25])) == Float.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 26])) == Float.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 27])) == Double.self)
        XCTAssertTrue(try! CBORParser.type(for: Data([CBOR.MajorType.additonal.rawValue | 31])) == CBOR.Break.self)
    }

    func testDirectDecoding() {
        var value: Any!

        // Success cases
        XCTAssertNoThrow(value = try CBORParser.testDecode(String.self, from: convertFromHexString("0x6443424F52")).value)
        XCTAssertTrue(value is CBORDecodedString)
        XCTAssertNoThrow(value = try (value as! CBORDecodedString).decodedStringValue())
        XCTAssertEqual(value as! String?, "CBOR")

        XCTAssertNoThrow(value = try CBORParser.testDecode(String.self, from: convertFromHexString("0x7F624342624F52FF")).value)
        XCTAssertTrue(value is CBORDecodedString)
        XCTAssertNoThrow(value = try (value as! CBORDecodedString).decodedStringValue())
        XCTAssertEqual(value as! String?, "CBOR")

        XCTAssertNoThrow(value = try CBORParser.testDecode(Data.self, from: convertFromHexString("0x4443424F52")).value)
        XCTAssertTrue(value is CBORDecodedData)
        XCTAssertEqual((value as! CBORDecodedData).decodedDataValue(), Data("CBOR".utf8))

        XCTAssertNoThrow(value = try CBORParser.testDecode(Data.self, from: convertFromHexString("0x5F424342424F52FF")).value)
        XCTAssertTrue(value is CBORDecodedData)
        XCTAssertEqual((value as! CBORDecodedData).decodedDataValue(), Data("CBOR".utf8))

        XCTAssertNoThrow(value = try CBORParser.testDecode(URL.self, from: convertFromHexString("0x76687474703A2F2F7777772E6578616D706C652E636F6D")).value)
        XCTAssertTrue(value is URL)
        XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

        XCTAssertNoThrow(value = try CBORParser.testDecode(Date.self, tag: .standardDateTime, from: convertFromHexString("0x74323031332D30332D32315432303A30343A30305A")).value)
        XCTAssertTrue(value is Date)
        XCTAssertEqual(value as! Date, rfc3339Date())

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.NegativeUInt64.self, from: convertFromHexString("0x3B7FFFFFFFFFFFFFFF")).value)
        XCTAssertTrue(value is CBOR.NegativeUInt64)
        XCTAssertEqual((value as! CBOR.NegativeUInt64).rawValue, 0x8000000000000000)

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.SimpleValue.self, from: convertFromHexString("0xF8FF")).value)
        XCTAssertTrue(value is CBOR.SimpleValue)
        XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 255)

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bignum.self, tag: .positiveBignum, from: convertFromHexString("0x42FFFF")).value)
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertTrue((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0xFFFF"))

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bignum.self, tag: .negativeBignum, from: convertFromHexString("0x42FFFF")).value)
        XCTAssertTrue(value is CBOR.Bignum)
        XCTAssertFalse((value as! CBOR.Bignum).isPositive)
        XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0xFFFF"))

        XCTAssertNoThrow(value = try CBORParser.testDecode(Float.self, from: convertFromHexString("0xF97C00")).value)
        XCTAssertTrue(value is Float)
        XCTAssertEqual(value as! Float, .infinity)

        XCTAssertNoThrow(value = try CBORParser.testDecode(UInt64.self, from: convertFromHexString("0x1903E8")).value)
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 1000)

        XCTAssertNoThrow(value = try CBORParser.testDecode(Int64.self, from: convertFromHexString("0x3903E7")).value)
        XCTAssertTrue(value is Int64)
        XCTAssertEqual(value as! Int64, -1000)

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.DecimalFraction<Int64, Int64>.self, from: convertFromHexString("0x82202E")).value) // Decimal Fraction
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
        XCTAssertTrue((value as! [Any])[1] is Int64)
        XCTAssertEqual((value as! [Any])[1] as! Int64, -1)
        XCTAssertTrue((value as! [Any])[2] is Int64)
        XCTAssertEqual((value as! [Any])[2] as! Int64, -15)

        XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bigfloat<UInt64, UInt64>.self, from: convertFromHexString("0x82010F")).value) // Bigfloat
        XCTAssertTrue(value is [Any])
        XCTAssertEqual((value as! [Any]).count, 3)

        XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
        XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
        XCTAssertTrue((value as! [Any])[1] is UInt64)
        XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
        XCTAssertTrue((value as! [Any])[2] is UInt64)
        XCTAssertEqual((value as! [Any])[2] as! UInt64, 15)

        // Failure cases
        XCTAssertThrowsError(try CBORParser.testDecode(CBOR.NegativeUInt64.self, from: Data()))
        XCTAssertThrowsError(try CBORParser.testDecode(CBOR.NegativeUInt64.self, from: Data([CBOR.MajorType.unsigned.rawValue])))

        XCTAssertThrowsError(try CBORParser.testDecode(CBOR.SimpleValue.self, from: Data()))
        XCTAssertThrowsError(try CBORParser.testDecode(CBOR.SimpleValue.self, from: Data([CBOR.MajorType.unsigned.rawValue])))
        XCTAssertThrowsError(try CBORParser.testDecode(CBOR.SimpleValue.self, from: Data([CBOR.MajorType.additonal.rawValue | 25])))

        XCTAssertThrowsError(try CBORParser.testDecode(Float.self, from: Data()))
        XCTAssertThrowsError(try CBORParser.testDecode(Double.self, from: Data()))

        XCTAssertThrowsError(try CBORParser.testDecode(UInt64.self, from: Data()))
        XCTAssertThrowsError(try CBORParser.testDecode(Int64.self, from: Data()))

        XCTAssertThrowsError(try CBORParser.testDecode(UInt8.self, from: convertFromHexString("0x1903E8")))
        XCTAssertThrowsError(try CBORParser.testDecode(Int8.self, from: convertFromHexString("0x3903E7")))
    }

    func testCreateCodingKeys() {
        var codingKey: CodingKey!

        // Success cases
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: CBOR.NegativeUInt64(rawValue: 0x7F)))
        XCTAssertEqual(codingKey.intValue, -127)

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: CBOR.NegativeUInt64(rawValue: UInt64(Int.max) + 1)))
        XCTAssertEqual(codingKey.intValue, .min)

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int8.max))
        XCTAssertEqual(codingKey.intValue, Int(Int8.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int8.min))
        XCTAssertEqual(codingKey.intValue, Int(Int8.min))

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int16.max))
        XCTAssertEqual(codingKey.intValue, Int(Int16.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int16.min))
        XCTAssertEqual(codingKey.intValue, Int(Int16.min))

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int32.max))
        XCTAssertEqual(codingKey.intValue, Int(Int32.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int32.min))
        XCTAssertEqual(codingKey.intValue, Int(Int32.min))

        #if arch(arm64) || arch(x86_64) // 64-bit
        // On 64-bit architectures the `Int` type is 64-bits wide and therefore will be
        // able to fully represent the following values

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int64.max))
        XCTAssertEqual(codingKey.intValue, Int(Int64.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: Int64.min))
        XCTAssertEqual(codingKey.intValue, Int(Int64.min))
        #endif // #if arch(arm64) || arch(x86_64)

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt8.max))
        XCTAssertEqual(codingKey.intValue, Int(UInt8.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt8.min))
        XCTAssertEqual(codingKey.intValue, Int(UInt8.min))

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt16.max))
        XCTAssertEqual(codingKey.intValue, Int(UInt16.max))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt16.min))
        XCTAssertEqual(codingKey.intValue, Int(UInt16.min))

        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt32.min))
        XCTAssertEqual(codingKey.intValue, Int(UInt32.min))
        XCTAssertNoThrow(codingKey = try CBORParser.testCreateCodingKey(from: UInt64.min))
        XCTAssertEqual(codingKey.intValue, Int(UInt64.min))

        // Failure cases
        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: CBOR.NegativeUInt64(rawValue: .max)))
        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: CBOR.Bignum(isPositive: false, content: convertFromHexString("0xFFFFFFFFFFFFFFFF"))))

        #if arch(arm) || arch(i386) // 32-bit
        // On 32-bit architectures the `Int` type is 32-bits wide and therefore will not be
        // able to represent the following values

        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: Int64.max))
        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: Int64.min))
        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: UInt32.max))
        #endif // #if arch(arm64) || arch(x86_64)

        XCTAssertThrowsError(try CBORParser.testCreateCodingKey(from: UInt64.max))
    }
    
    func testSlicedDataInput() {
        var value: Any!
        
        // Skip over the first 2 bytes with a slice.
        let data = convertFromHexString("0x000000")[2...]
        
        XCTAssertNoThrow(value = try CBORParser.parse(data))
        XCTAssertTrue(value is UInt64)
        XCTAssertEqual(value as! UInt64, 0)

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
