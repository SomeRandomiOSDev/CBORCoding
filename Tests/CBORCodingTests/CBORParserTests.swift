//
//  CBORParserTests.swift
//  CBORCodingTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable function_body_length force_cast comma force_try implicitly_unwrapped_optional number_separator force_unwrapping

@testable import CBORCoding
import XCTest

// MARK: - CBORParserTests Definition

class CBORParserTests: XCTestCase {

    // MARK: Private Constants

    private let prefixLengths = [0, 2, 4]
    private let suffixLengths = [0, 2, 4]

    // MARK: Test Methods

    func testAppendixASimpleExamples() {
        // Test Examples taken from Appendix A of RFC 8949

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())01\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 1)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())0A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 10)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())17\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 23)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 24)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1819\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 25)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1864\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 100)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1903E8\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 1000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1A000F4240\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 1000000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1B000000E8D4A51000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 1000000000000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())1BFFFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 18446744073709551615)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C249010000000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // 18446744073709551616
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertTrue((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())3BFFFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // -18446744073709551616
                XCTAssertTrue(value is CBOR.NegativeUInt64)
                XCTAssertEqual((value as! CBOR.NegativeUInt64).rawValue, .min)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C349010000000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // -18446744073709551617
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertFalse((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x010000000000000000"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())20\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, -1)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())29\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, -10)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())3863\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, -100)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())3903E7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, -1000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())3B7FFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // NOT part of RFC 8949 examples
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, .min)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F90000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 0.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F98000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, -0.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F93C00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 1.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FB3FF199999999999A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertEqual(value as! Double, 1.1)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F93E00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 1.5)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F97BFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 65504.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FA47C35000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float)
                XCTAssertEqual(value as! Float, 100000.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FA7F7FFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float)
                XCTAssertEqual(value as! Float, 3.4028234663852886e+38)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FB7E37E43C8800759C\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertEqual(value as! Double, 1.0e+300)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F90001\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 5.960464477539063e-8)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F90400\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, 0.00006103515625)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F9C400\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, -4.0)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FBC010666666666666\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertEqual(value as! Double, -4.1)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F97C00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, .infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F97E00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertTrue((value as! Float16).isNaN)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F9FC00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float16)
                XCTAssertEqual(value as! Float16, -.infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FA7F800000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float)
                XCTAssertEqual(value as! Float, .infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FA7FC00000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float)
                XCTAssertTrue((value as! Float).isNaN)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FAFF800000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Float)
                XCTAssertEqual(value as! Float, -.infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FB7FF0000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertEqual(value as! Double, .infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FB7FF8000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertTrue((value as! Double).isNaN)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())FBFFF0000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Double)
                XCTAssertEqual(value as! Double, -.infinity)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F4\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Bool)
                XCTAssertFalse(value as! Bool)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F5\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Bool)
                XCTAssertTrue(value as! Bool)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F6\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.Null)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.Undefined)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F0\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.SimpleValue)
                XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 16)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.SimpleValue)
                XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 24)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())F8FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.SimpleValue)
                XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 255)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C074323031332D30332D32315432303A30343A30305A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual(value as! Date, rfc3339Date())

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C11A514B67B0\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C1FB41D452D9EC200000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual(value as! Date, Date(timeIntervalSince1970: 1363896240.5))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D74401020304\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x01020304"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D818456449455446\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x6449455446"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D82076687474703A2F2F7777772E6578616D706C652E636F6D\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is URL)
                XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())40\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, Data())

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())4401020304\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x\(prefix())01020304\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())60\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())6161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "a")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())6449455446\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "IETF")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())62225C\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "\"\\")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())62C3BC\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "\u{00FC}")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())63E6B0B4\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "\u{6C34}")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())64F0908591\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "\u{10151}")
            }
        }
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

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    ("0x\(prefix())80\(suffix())",   "0x\(prefix())83010203\(suffix())",   "0x\(prefix())98190102030405060708090A0B0C0D0E0F101112131415161718181819\(suffix())"), // Definite Length Arrays
                    ("0x\(prefix())9FFF\(suffix())", "0x\(prefix())9F010203FF\(suffix())", "0x\(prefix())9F0102030405060708090A0B0C0D0E0F101112131415161718181819FF\(suffix())")  // Indefinite Length Arrays
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.0, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is ArrayWrapper<Any>)
                    XCTAssertTrue((value as! ArrayWrapper<Any>).isEmpty)

                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.1, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is ArrayWrapper<Any>)
                    XCTAssertEqual((value as! ArrayWrapper<Any>).count, 3)
                    XCTAssertTrue((value as! ArrayWrapper<Any>).array is [UInt64])
                    XCTAssertEqual((value as! ArrayWrapper<Any>).array as! [UInt64], [1, 2, 3])

                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.2, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is ArrayWrapper<Any>)
                    XCTAssertEqual((value as! ArrayWrapper<Any>).count, 25)
                    XCTAssertTrue((value as! ArrayWrapper<Any>).array is [UInt64])
                    XCTAssertEqual((value as! ArrayWrapper<Any>).array as! [UInt64], [1,  2,  3,  4,  5,  6,  7,
                                                                                      8,  9,  10, 11, 12, 13, 14,
                                                                                      15, 16, 17, 18, 19, 20, 21,
                                                                                      22, 23, 24, 25])
                }
            }
        }
    }

    func testAppendixAComplexExamples2() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1, [2, 3], [4, 5]]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings: [String] = [
                    "0x\(prefix())8301820203820405\(suffix())",      // Definite/Definite/Definite Length Arrays
                    "0x\(prefix())83018202039F0405FF\(suffix())",    // Definite/Definite/Indefinite Length Arrays
                    "0x\(prefix())83019F0203FF820405\(suffix())",    // Definite/Indefinite/Definite Length Arrays
                    "0x\(prefix())83019F0203FF9F0405FF\(suffix())",  // Definite/Indefinite/Indefinite Length Arrays
                    "0x\(prefix())9F01820203820405FF\(suffix())",    // Indefinite/Definite/Definite Length Arrays
                    "0x\(prefix())9F018202039F0405FFFF\(suffix())",  // Indefinite/Definite/Indefinite Length Arrays
                    "0x\(prefix())9F019F0203FF820405FF\(suffix())",  // Indefinite/Indefinite/Definite Length Arrays
                    "0x\(prefix())9F019F0203FF9F0405FFFF\(suffix())" // Indefinite/Indefinite/Indefinite Length Arrays
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
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
        }
    }

    func testAppendixAComplexExamples3() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1: 2, 3: 4]
        //
        // [1: "a", 2: "b"]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    ("0x\(prefix())A201020304\(suffix())",   "0x\(prefix())A2016161026162\(suffix())"),  // Definite Length Maps
                    ("0x\(prefix())BF01020304FF\(suffix())", "0x\(prefix())BF016161026162FF\(suffix())") // Indefinite Length Map
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.0, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 2)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] is UInt64)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] as? UInt64, 2)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 3)] is UInt64)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 3)] as? UInt64, 4)

                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString.1, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 2)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] as? String, "a")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 2)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 2)] as? String, "b")
                }
            }
        }
    }

    func testAppendixAComplexExamples4() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": 1, "b": [2, 3]]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    "0x\(prefix())A26161016162820203\(suffix())",    // Definite/Definite Length Containers
                    "0x\(prefix())A261610161629F0203FF\(suffix())",  // Definite/Indefinite Length Containers
                    "0x\(prefix())BF6161016162820203FF\(suffix())",  // Indefinite/Definite Length Containers
                    "0x\(prefix())BF61610161629F0203FFFF\(suffix())" // Indefinite/Indefinite Length Containers
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 2)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "a")] is UInt64)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "a")] as? UInt64, 1)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] is ArrayWrapper<Any>)
                    XCTAssertTrue(((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] as? ArrayWrapper<Any>)?.array is [UInt64])
                    XCTAssertEqual(((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] as? ArrayWrapper<Any>)?.array as? [UInt64], [2 ,3])
                }
            }
        }
    }

    func testAppendixAComplexExamples5() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a", ["b": "c"]]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    "0x\(prefix())826161A161626163\(suffix())",    // Definite/Definite Length Containers
                    "0x\(prefix())826161BF61626163FF\(suffix())",  // Definite/Indefinite Length Containers
                    "0x\(prefix())9F6161A161626163FF\(suffix())",  // Indefinite/Definite Length Containers
                    "0x\(prefix())9F6161BF61626163FFFF\(suffix())" // Indefinite/Indefinite Length Containers
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is ArrayWrapper<Any>)
                    XCTAssertEqual((value as? ArrayWrapper<Any>)?.count, 2)

                    XCTAssertTrue((value as? ArrayWrapper<Any>)?.array[0] is String)
                    XCTAssertEqual((value as? ArrayWrapper<Any>)?.array[0] as? String, "a")

                    XCTAssertTrue((value as? ArrayWrapper<Any>)?[1] is CodingKeyDictionary<Any>)
                    XCTAssertTrue(((value as? ArrayWrapper<Any>)?[1] as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] is String)
                    XCTAssertEqual(((value as? ArrayWrapper<Any>)?[1] as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] as? String, "c")
                }
            }
        }
    }

    func testAppendixAComplexExamples6() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    "0x\(prefix())A56161614161626142616361436164614461656145\(suffix())",  // Definite Length Map
                    "0x\(prefix())BF6161614161626142616361436164614461656145FF\(suffix())" // Indefinite Length Map
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 5)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "a")] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "a")] as? String, "A")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "b")] as? String, "B")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "c")] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "c")] as? String, "C")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "d")] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "d")] as? String, "D")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "e")] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "e")] as? String, "E")
                }
            }
        }
    }

    func testAppendixAComplexExamples7() {
        // [1: "A", 2: "B", 3: "C", 4: "D", 5: "E"]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    "0x\(prefix())A5016141026142036143046144056145\(suffix())",  // Definite Length Map
                    "0x\(prefix())BF016141026142036143046144056145FF\(suffix())" // Indefinite Length Map
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 5)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 1)] as? String, "A")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 2)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 2)] as? String, "B")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 3)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 3)] as? String, "C")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 4)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 4)] as? String, "D")

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 5)] is String)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(intValue: 5)] as? String, "E")
                }
            }
        }
    }

    func testAppendixAComplexExamples8() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ h'0102', h'030405')

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())5F42010243030405FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.IndefiniteLengthData)

                XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks.count, 2)
                XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[0], convertFromHexString("0x0102"))
                XCTAssertEqual((value as! CBOR.IndefiniteLengthData).chunks[1], convertFromHexString("0x030405"))
            }
        }
    }

    func testAppendixAComplexExamples9() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ "strea", "ming")

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())7F657374726561646D696E67FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.IndefiniteLengthString)

                XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks.count, 2)
                XCTAssertEqual((value as! CBOR.IndefiniteLengthString).stringValue, "streaming")
                XCTAssertEqual((value as! CBOR.IndefiniteLengthString).stringValue(as: .utf8), "streaming")
                XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[0], Data("strea".utf8))
                XCTAssertEqual((value as! CBOR.IndefiniteLengthString).chunks[1], Data("ming".utf8))
            }
        }
    }

    func testAppendixAComplexExamples10() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["Fun": true, "Amt": -2]

        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!
                let dataStrings = [
                    "0x\(prefix())BF6346756EF563416D7421FF\(suffix())", // Definite Length Map
                    "0x\(prefix())A26346756EF563416D7421\(suffix())"    // Indefinite Length Map
                ]

                for dataString in dataStrings {
                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(dataString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is CodingKeyDictionary<Any>)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?.count, 2)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "Fun")] is Bool)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "Fun")] as? Bool, true)

                    XCTAssertTrue((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "Amt")] is Int64)
                    XCTAssertEqual((value as? CodingKeyDictionary<Any>)?[CBOR.CodingKey(stringValue: "Amt")] as? Int64, -2)
                }
            }
        }
    }

    func testTaggedValues() {
        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C074323031332D30332D32315432303A30343A30305A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual((value as! Date), rfc3339Date())

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C101\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual((value as! Date), Date(timeIntervalSince1970: 1))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C1FB41D452D9EC200000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Date)
                XCTAssertEqual((value as! Date), Date(timeIntervalSince1970: 1363896240.5))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C24100\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertTrue((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C25F420001420203FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Indefinite length data as Bignum content
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertTrue((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00010203"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C34100\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertFalse((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0x00"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C482010F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Decimal Fraction
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
                XCTAssertTrue((value as! [Any])[1] is UInt64)
                XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
                XCTAssertTrue((value as! [Any])[2] is UInt64)
                XCTAssertEqual((value as! [Any])[2] as! UInt64, 15)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C482202E\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Decimal Fraction
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
                XCTAssertTrue((value as! [Any])[1] is Int64)
                XCTAssertEqual((value as! [Any])[1] as! Int64, -1)
                XCTAssertTrue((value as! [Any])[2] is Int64)
                XCTAssertEqual((value as! [Any])[2] as! Int64, -15)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C4823B80000000000000003B8FFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Decimal Fraction
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
                XCTAssertTrue((value as! [Any])[1] is CBOR.NegativeUInt64)
                XCTAssertEqual(((value as! [Any])[1] as! CBOR.NegativeUInt64).rawValue, 0x8000000000000001)
                XCTAssertTrue((value as! [Any])[2] is CBOR.NegativeUInt64)
                XCTAssertEqual(((value as! [Any])[2] as! CBOR.NegativeUInt64).rawValue, 0x9000000000000000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C582010F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Bigfloat
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
                XCTAssertTrue((value as! [Any])[1] is UInt64)
                XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
                XCTAssertTrue((value as! [Any])[2] is UInt64)
                XCTAssertEqual((value as! [Any])[2] as! UInt64, 15)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C58201C2410F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Bigfloat
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
                XCTAssertTrue((value as! [Any])[1] is UInt64)
                XCTAssertEqual((value as! [Any])[1] as! UInt64, 1)
                XCTAssertTrue((value as! [Any])[2] is CBOR.Bignum)
                XCTAssertTrue(((value as! [Any])[2] as! CBOR.Bignum).isPositive)
                XCTAssertEqual(((value as! [Any])[2] as! CBOR.Bignum).content, convertFromHexString("0x0F"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())C5823B80000000000000003B8FFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Bigfloat
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .bigfloat)
                XCTAssertTrue((value as! [Any])[1] is CBOR.NegativeUInt64)
                XCTAssertEqual(((value as! [Any])[1] as! CBOR.NegativeUInt64).rawValue, 0x8000000000000001)
                XCTAssertTrue((value as! [Any])[2] is CBOR.NegativeUInt64)
                XCTAssertEqual(((value as! [Any])[2] as! CBOR.NegativeUInt64).rawValue, 0x9000000000000000)

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D54101\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D64101\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D74101\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, convertFromHexString("0x01"))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D56161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "a")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D66161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "a")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D76161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "a")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D82076687474703A2F2F7777772E6578616D706C652E636F6D\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is URL)
                XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

                do {
                    let hexString = "0x\(prefix())D820" + (try! CBOREncoder().encode(CBOR.IndefiniteLengthString(wrapping: ["http://www.", "example.com"]))).map { String(format: "%02X", $0) }.joined() + suffix()

                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString(hexString, prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertTrue(value is URL)
                    XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)
                }

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D8226851304A5055673D3D\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, Data("CBOR".utf8))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D8216651304A505567\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, Data("CBOR".utf8))

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D8246443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "CBOR")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D8236573616C3F74\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is String)
                XCTAssertEqual(value as! String, "sal?t")

                XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D9D9F74443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertTrue(value is Data)
                XCTAssertEqual(value as! Data, Data("CBOR".utf8))
            }
        }
    }

    func testFailureCases() {
        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())0101\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Multiple values outside of a container

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())18\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Unsigned - Missing extra byte
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())19\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Unsigned - Missing two extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())1A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Unsigned - Missing four extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())1B\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Unsigned - Missing eight extra bytes

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())38\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Signed - Missing extra byte
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())39\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Signed - Missing two extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())3A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Signed - Missing four extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())3B\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Signed - Missing eight extra bytes

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())F8\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Simple - Missing extra byte
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())FE\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Major Type 7, Unassigned code

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())F9\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Float16 - Missing two extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())FA\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Float - Missing four extra bytes
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())FB\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Double - Missing eight extra bytes

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C6\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Invalid tag
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())DF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Invalid tag
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C0\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Standard Date
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C1\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Epoch Date
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C2\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Positive Bignum
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C3\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Negative Bignum
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Decimal Fraction
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C5\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Bigfloat
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D5\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Base64URL Conversion
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D6\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Base64 Conversion
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Empty Tag - Base16 Conversion
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - Encoded CBOR Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D820\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - URI
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D821\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - Base64URL
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D822\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - Base64
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D823\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - Regular Expression
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D824\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Empty Tag - MIME Message

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D8216121\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid Base64URL Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D8226121\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid Base64 Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D8236129\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid Regular Expression

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())7F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Indefinite Length String - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())7F60\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Indefinite Length String - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())7F61\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Indefinite Length String - Chunk of Length 1 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())5F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Indefinite Length Data - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())5F40\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Indefinite Length Data - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())5F41\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Indefinite Length Data - Chunk of Length 1 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())5F60FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Indefinite Length Data - String Chunks
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())9F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Indefinite Length Array - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())9F60\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Indefinite Length Array - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())BF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Indefinite Length Map - No Break
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())BF61616161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Indefinite Length Map - No Break

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // "Break" Code - No Container
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())820000FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // "Break" Code - Outside of Container
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())82FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // "Break" Code - Inside Definite Length Array
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())A2FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // "Break" Code - Inside Definite Length Map

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())62\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // String of Length 2 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())6261\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // String of Length 2 - 1 Element
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())42\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Data of Length 2 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())4200\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Data of Length 2 - 1 Element
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())82\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Array of Length 2 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())8200\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))       // Array of Length 2 - 1 Element
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())A2\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))         // Map of Length 2 - 0 Elements
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())A261616161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Map of Length 2 - 1 Element
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())A16161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Map with Key but no Value

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())64FEFEFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid UTF-8 String
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D8207F61FE61FE61FF61FFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid UTF-8 URL
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D820682074207420702073203A202F202F206520782061206D2070206C2065202E2063206F206D\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid URL ("h t t p s : / / e x a m p l e . c o m")
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())D8204100\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid URL (Empty Byte Data)
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C06443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid RFC3339 Date String ("CBOR")
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C16443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Invalid Epoch Date ("CBOR")

                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4420001\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Byte Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4811818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Array of Length 1
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C49F1818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Array of Length 1
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4821818\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Array of Length 2 - 1 Element
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4823B00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Array of Length 2 - 1 Element - Empty Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C482003B\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))     // Decimal Fraction Tag - Array of Length 2 - 2 Elements - 2nd Element Empty Data
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C48261616162\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))) // Decimal Fraction Tag - ["a", "b"]
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C482016162\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Decimal Fraction Tag - [1, "b"]
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4821818C6\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Decimal Fraction Tag - [24, Invalid Tag]
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4821818C0\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Decimal Fraction Tag - [24, Date Tag]
                XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())C4821818C2\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))   // Decimal Fraction Tag - [24, Empty Bignum Data]

                do {
                    var value: Any?

                    XCTAssertNoThrow(value = try CBORParser.parse(Data()))
                    XCTAssertNil(value)

                    XCTAssertNoThrow(value = try CBORParser.parse(convertFromHexString("0x\(prefix())D9D9F7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                    XCTAssertNil(value)
                }
            }
        }
    }

    func testDecodeMapCodingKeys() {
        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

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
                    try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0x\(prefix())FFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x\(prefix())FFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                ]
                var throwingCodingKeys = [
                    try! encoder.encode(UInt64.max),
                    try! encoder.encode(CBOR.NegativeUInt64(rawValue: 0x8000000000000001)),
                    try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0x\(prefix())FFFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0x\(prefix())FFFFFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x\(prefix())FFFFFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x\(prefix())8000000000000001\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                ]

                // Throws on 32-bit architectures but succeeds on 64-bit architectures.
                let archEdgeCases = [
                    try! encoder.encode(Int64.min),
                    try! encoder.encode(Int64.max),
                    try! encoder.encode(UInt32.max),
                    try! encoder.encode(CBOR.Bignum(isPositive: true, content: convertFromHexString("0x\(prefix())0100010001000100\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x\(prefix())0100010001000100\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength))),
                    try! encoder.encode(CBOR.Bignum(isPositive: false, content: convertFromHexString("0x\(prefix())8000000000000000\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                ]

                #if arch(arm64) || arch(x86_64)
                nonThrowingCodingKeys.append(contentsOf: archEdgeCases)
                #elseif arch(i386) || arch(arm)
                throwingCodingKeys.append(contentsOf: archEdgeCases)
                #endif // #if arch(arm64) || arch(x86_64)

                for key in nonThrowingCodingKeys {
                    XCTAssertNoThrow(try CBORParser.parse(convertFromHexString("0x\(prefix())A1\(key.map { String(format: "%02X", $0) }.joined())6161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                }

                for key in throwingCodingKeys {
                    XCTAssertThrowsError(try CBORParser.parse(convertFromHexString("0x\(prefix())A1\(key.map { String(format: "%02X", $0) }.joined())6161\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                }
            }
        }
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
        for prefixLength in prefixLengths {
            func prefix() -> String { return randomHexString(ofLength: prefixLength) }

            for suffixLength in suffixLengths {
                func suffix() -> String { return randomHexString(ofLength: suffixLength) }

                var value: Any!

                // Success cases
                XCTAssertNoThrow(value = try CBORParser.testDecode(String.self, from: convertFromHexString("0x\(prefix())6443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBORDecodedString)
                XCTAssertNoThrow(value = try (value as! CBORDecodedString).decodedStringValue())
                XCTAssertEqual(value as! String?, "CBOR")

                XCTAssertNoThrow(value = try CBORParser.testDecode(String.self, from: convertFromHexString("0x\(prefix())7F624342624F52FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBORDecodedString)
                XCTAssertNoThrow(value = try (value as! CBORDecodedString).decodedStringValue())
                XCTAssertEqual(value as! String?, "CBOR")

                XCTAssertNoThrow(value = try CBORParser.testDecode(Data.self, from: convertFromHexString("0x\(prefix())4443424F52\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBORDecodedData)
                XCTAssertEqual((value as! CBORDecodedData).decodedDataValue(), Data("CBOR".utf8))

                XCTAssertNoThrow(value = try CBORParser.testDecode(Data.self, from: convertFromHexString("0x\(prefix())5F424342424F52FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBORDecodedData)
                XCTAssertEqual((value as! CBORDecodedData).decodedDataValue(), Data("CBOR".utf8))

                XCTAssertNoThrow(value = try CBORParser.testDecode(URL.self, from: convertFromHexString("0x\(prefix())76687474703A2F2F7777772E6578616D706C652E636F6D\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is URL)
                XCTAssertEqual(value as! URL, URL(string: "http://www.example.com")!)

                XCTAssertNoThrow(value = try CBORParser.testDecode(Date.self, tag: .standardDateTime, from: convertFromHexString("0x\(prefix())74323031332D30332D32315432303A30343A30305A\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is Date)
                XCTAssertEqual(value as! Date, rfc3339Date())

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.NegativeUInt64.self, from: convertFromHexString("0x\(prefix())3B7FFFFFFFFFFFFFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBOR.NegativeUInt64)
                XCTAssertEqual((value as! CBOR.NegativeUInt64).rawValue, 0x8000000000000000)

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.SimpleValue.self, from: convertFromHexString("0x\(prefix())F8FF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBOR.SimpleValue)
                XCTAssertEqual((value as! CBOR.SimpleValue).rawValue, 255)

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bignum.self, tag: .positiveBignum, from: convertFromHexString("0x\(prefix())42FFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertTrue((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0xFFFF"))

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bignum.self, tag: .negativeBignum, from: convertFromHexString("0x\(prefix())42FFFF\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is CBOR.Bignum)
                XCTAssertFalse((value as! CBOR.Bignum).isPositive)
                XCTAssertEqual((value as! CBOR.Bignum).content, convertFromHexString("0xFFFF"))

                XCTAssertNoThrow(value = try CBORParser.testDecode(Float.self, from: convertFromHexString("0x\(prefix())F97C00\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is Float)
                XCTAssertEqual(value as! Float, .infinity)

                XCTAssertNoThrow(value = try CBORParser.testDecode(UInt64.self, from: convertFromHexString("0x\(prefix())1903E8\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is UInt64)
                XCTAssertEqual(value as! UInt64, 1000)

                XCTAssertNoThrow(value = try CBORParser.testDecode(Int64.self, from: convertFromHexString("0x\(prefix())3903E7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value)
                XCTAssertTrue(value is Int64)
                XCTAssertEqual(value as! Int64, -1000)

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.DecimalFraction<Int64, Int64>.self, from: convertFromHexString("0x\(prefix())82202E\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value) // Decimal Fraction
                XCTAssertTrue(value is [Any])
                XCTAssertEqual((value as! [Any]).count, 3)

                XCTAssertTrue((value as! [Any])[0] is CBOR.Tag)
                XCTAssertEqual((value as! [Any])[0] as! CBOR.Tag, .decimalFraction)
                XCTAssertTrue((value as! [Any])[1] is Int64)
                XCTAssertEqual((value as! [Any])[1] as! Int64, -1)
                XCTAssertTrue((value as! [Any])[2] is Int64)
                XCTAssertEqual((value as! [Any])[2] as! Int64, -15)

                XCTAssertNoThrow(value = try CBORParser.testDecode(CBOR.Bigfloat<UInt64, UInt64>.self, from: convertFromHexString("0x\(prefix())82010F\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)).value) // Bigfloat
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

                XCTAssertThrowsError(try CBORParser.testDecode(UInt8.self, from: convertFromHexString("0x\(prefix())1903E8\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
                XCTAssertThrowsError(try CBORParser.testDecode(Int8.self, from: convertFromHexString("0x\(prefix())3903E7\(suffix())", prefixLength: prefixLength, suffixLength: suffixLength)))
            }
        }
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

    func testConvertFromHexStringWithPrefixesAndSuffixes() {
        let hex = randomHexString(ofLength: 16)
        let prefix = randomHexString(ofLength: 2)
        let suffix = randomHexString(ofLength: 2)

        XCTAssertEqual(convertFromHexString(hex), convertFromHexString(prefix + hex, prefixLength: prefix.count / 2))
        XCTAssertEqual(convertFromHexString(hex), convertFromHexString(hex + suffix, suffixLength: suffix.count / 2))
        XCTAssertEqual(convertFromHexString(hex), convertFromHexString(prefix + hex + suffix, prefixLength: prefix.count / 2, suffixLength: suffix.count / 2))
    }

    // MARK: Private Methods

    private func convertFromHexString(_ string: String, prefixLength: Int = 0, suffixLength: Int = 0) -> Data {
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

        if prefixLength > 0 {
            if suffixLength > 0 {
                data = data[prefixLength ..< (data.count - suffixLength)]
            } else {
                data = data[prefixLength...]
            }
        } else if suffixLength > 0 {
            data = data[..<(data.count - suffixLength)]
        }

        return data
    }

    private func randomHexString(ofLength length: Int = 8) -> String {
        guard length > 0 else { return "" }
        return String((0 ..< (length * 2)).map { _ in "0123456789ABCDEF".shuffled()[0] })
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
