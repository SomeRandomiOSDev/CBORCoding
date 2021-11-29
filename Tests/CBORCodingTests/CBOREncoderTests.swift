//
//  CBOREncoderTests.swift
//  CBORCodingTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable comma nesting function_body_length identifier_name force_try force_cast number_separator force_unwrapping

@testable import CBORCoding
import Half
import XCTest

// MARK: - CBORTests Definition

class CBOREncoderTests: XCTestCase {

    // MARK: Test Methods

    func testAppendixASimpleExamples() {
        // Test Examples taken from Appendix A of RFC 8949

        let encoder = CBOREncoder()
        let testData: [(Data, String)] = [
            (try! encoder.encode(UInt64(0)),                                  "0x00"),
            (try! encoder.encode(UInt64(1)),                                  "0x01"),
            (try! encoder.encode(UInt64(10)),                                 "0x0A"),
            (try! encoder.encode(UInt64(23)),                                 "0x17"),
            (try! encoder.encode(UInt64(24)),                                 "0x1818"),
            (try! encoder.encode(UInt64(25)),                                 "0x1819"),
            (try! encoder.encode(UInt64(100)),                                "0x1864"),
            (try! encoder.encode(UInt64(1000)),                               "0x1903E8"),
            (try! encoder.encode(UInt64(1000000)),                            "0x1A000F4240"),
            (try! encoder.encode(UInt64(1000000000000)),                      "0x1B000000E8D4A51000"),
            (try! encoder.encode(18446744073709551615 as UInt64),             "0x1BFFFFFFFFFFFFFFFF"),
            (try! encoder.encode(CBOR.Bignum(isPositive: true,
                                             content: Data([UInt8(0x01), 0x00, 0x00, 0x00,
                                                            0x00, 0x00, 0x00, 0x00, 0x00]))), "0xC249010000000000000000"), // 18446744073709551616
            (try! encoder.encode(CBOR.NegativeUInt64(rawValue: .min)),        "0x3BFFFFFFFFFFFFFFFF"), // -18446744073709551616
            (try! encoder.encode(CBOR.Bignum(isPositive: false,
                                             content: Data([UInt8(0x01), 0x00, 0x00, 0x00,
                                                            0x00, 0x00, 0x00, 0x00, 0x00]))), "0xC349010000000000000000"), // -18446744073709551617
            (try! encoder.encode(Int64(-1)),                                  "0x20"),
            (try! encoder.encode(Int64(-10)),                                 "0x29"),
            (try! encoder.encode(Int64(-100)),                                "0x3863"),
            (try! encoder.encode(Int64(-1000)),                               "0x3903E7"),
            (try! encoder.encode(Int64.min),                                  "0x3B7FFFFFFFFFFFFFFF"), // NOT part of RFC 8949 examples
            (try! encoder.encode(Half(0.0)),                                  "0xF90000"),
            (try! encoder.encode(Half(-0.0)),                                 "0xF98000"),
            (try! encoder.encode(Half(1.0)),                                  "0xF93C00"),
            (try! encoder.encode(Double(1.1)),                                "0xFB3FF199999999999A"),
            (try! encoder.encode(Half(1.5)),                                  "0xF93E00"),
            (try! encoder.encode(Half(65504.0)),                              "0xF97BFF"),
            (try! encoder.encode(Float(100000.0)),                            "0xFA47C35000"),
            (try! encoder.encode(Float(3.4028234663852886e+38)),              "0xFA7F7FFFFF"),
            (try! encoder.encode(Double(1.0e+300)),                           "0xFB7E37E43C8800759C"),
            (try! encoder.encode(Half(5.960464477539063e-8)),                 "0xF90001"),
            (try! encoder.encode(Half(0.00006103515625)),                     "0xF90400"),
            (try! encoder.encode(Half(-4.0)),                                 "0xF9C400"),
            (try! encoder.encode(Double(-4.1)),                               "0xFBC010666666666666"),
            (try! encoder.encode(Half.infinity),                              "0xF97C00"),
            (try! encoder.encode(Half.nan),                                   "0xF97E00"),
            (try! encoder.encode(-Half.infinity),                             "0xF9FC00"),
            (try! encoder.encode(Float.infinity),                             "0xFA7F800000"),
            (try! encoder.encode(Float.nan),                                  "0xFA7FC00000"),
            (try! encoder.encode(-Float.infinity),                            "0xFAFF800000"),
            (try! encoder.encode(Double.infinity),                            "0xFB7FF0000000000000"),
            (try! encoder.encode(Double.nan),                                 "0xFB7FF8000000000000"),
            (try! encoder.encode(-Double.infinity),                           "0xFBFFF0000000000000"),
            (try! encoder.encode(false),                                      "0xF4"),
            (try! encoder.encode(true),                                       "0xF5"),
            (try! encoder.encode(CBOR.Null()),                                "0xF6"),
            (try! encoder.encode(CBOR.Undefined()),                           "0xF7"),
            (try! encoder.encode(CBOR.SimpleValue(rawValue: 16)),             "0xF0"),
            (try! encoder.encode(CBOR.SimpleValue(rawValue: 24)),             "0xF818"),
            (try! encoder.encode(CBOR.SimpleValue(rawValue: 255)),            "0xF8FF"),
            (CBOREncoder.encode(rfc3339Date(),
                                using: .rfc3339),                             "0xC074323031332D30332D32315432303A30343A30305A"),
            (CBOREncoder.encode(Date(timeIntervalSince1970: 1363896240),
                                using: .secondsSince1970),                    "0xC11A514B67B0"),
            (CBOREncoder.encode(Date(timeIntervalSince1970: 1363896240.5),
                                using: .secondsSince1970),                    "0xC1FB41D452D9EC200000"),
            (try! CBOREncoder.encode(Data([UInt8(0x01), 0x02, 0x03, 0x04]),
                                     forTag: .base16Conversion).encodedData,  "0xD74401020304"),
            (try! CBOREncoder.encode(Data([UInt8(0x64), 0x49, 0x45,
                                           0x54, 0x46]),
                                     forTag: .encodedCBORData).encodedData,   "0xD818456449455446"),
            (try! encoder.encode(URL(string: "http://www.example.com")!),     "0xD82076687474703A2F2F7777772E6578616D706C652E636F6D"),
            (try! encoder.encode(Data()),                                     "0x40"),
            (try! encoder.encode(Data([UInt8(0x01), UInt8(0x02),
                                      UInt8(0x03), UInt8(0x04)])),            "0x4401020304"),
            (try! encoder.encode(""),                                         "0x60"),
            (try! encoder.encode("a"),                                        "0x6161"),
            (try! encoder.encode("IETF"),                                     "0x6449455446"),
            (try! encoder.encode("\"\\"),                                     "0x62225C"),
            (try! encoder.encode("\u{00FC}"),                                 "0x62C3BC"),
            (try! encoder.encode("\u{6C34}"),                                 "0x63E6B0B4"),
            (try! encoder.encode("\u{10151}"),                                "0x64F0908591")
        ]

        for (encodedData, string) in testData {
            XCTAssertEqual(convertToHexString(encodedData), string)
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

        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode([UInt8]()))
        XCTAssertEqual(convertToHexString(encodedData), "0x80")

        XCTAssertNoThrow(encodedData = try encoder.encode([1, 2, 3]))
        XCTAssertEqual(convertToHexString(encodedData), "0x83010203")

        XCTAssertNoThrow(encodedData = try encoder.encode([1, 2, 3, 4, 5, 6, 7, 8, 9,
                                                           10, 11, 12, 13, 14, 15, 16,
                                                           17, 18, 19, 20, 21, 22, 23,
                                                           24, 25]))
        XCTAssertEqual(convertToHexString(encodedData), "0x98190102030405060708090A0B0C0D0E0F101112131415161718181819")
    }

    func testAppendixAComplexExamples2() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1, [2, 3], [4, 5]]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()

                try container.encode(1)
                try container.encode([2, 3])
                try container.encode([4, 5])
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x8301820203820405")
    }

    func testAppendixAComplexExamples3() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1: 2, 3: 4]

        struct Test: Encodable {

            private enum CodingKeys: Int, CodingKey {

                case first = 1
                case second = 3
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(2, forKey: .first)
                try container.encode(4, forKey: .second)
            }
        }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let first  = $0 as! Int
            let second = $1 as! Int

            return first < second
        }

        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xA201020304")
    }

    func testAppendixAComplexExamples4() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": 1, "b": [2, 3]]

        struct Test: Encodable {

            private enum CodingKeys: String, CodingKey {

                case first  = "a"
                case second = "b"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(1, forKey: .first)
                try container.encode([2, 3], forKey: .second)
            }
        }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let first  = $0 as! String
            let second = $1 as! String

            return first < second
        }

        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xA26161016162820203")
    }

    func testAppendixAComplexExamples5() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a", ["b": "c"]]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()

                try container.encode("a")
                try container.encode(["b": "c"])
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x826161A161626163")
    }

    func testAppendixAComplexExamples6() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"])
            }
        }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let first  = $0 as! String
            let second = $1 as! String

            return first < second
        }

        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xA56161614161626142616361436164614461656145")
    }

    func testAppendixAComplexExamples7() {
        // [1: "A", 2: "B", 3: "C", 4: "D", 5: "E"]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode([1: "A", 2: "B", 3: "C", 4: "D", 5: "E"])
            }
        }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let first  = $0 as! Int
            let second = $1 as! Int

            return first < second
        }

        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xA5016141026142036143046144056145")
    }

    func testAppendixAComplexExamples8() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ h'0102', h'030405')

        let encoder = CBOREncoder()
        let data = CBOR.IndefiniteLengthData(wrapping: [Data([UInt8(0x01), 0x02]), Data([UInt8(0x03), 0x04, 0x05])])

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(data))
        XCTAssertEqual(convertToHexString(encodedData), "0x5F42010243030405FF")
    }

    func testAppendixAComplexExamples9() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // (_ "strea", "ming")

        let encoder = CBOREncoder()
        let data = CBOR.IndefiniteLengthString(wrapping: "streaming", chunkSize: 5)

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(data))
        XCTAssertEqual(convertToHexString(encodedData), "0x7F657374726561646D696E67FF")
    }

    func testAppendixAComplexExamples10() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [_ 1, [2, 3], [_ 4, 5]]

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    guard let cborEncoder = encoder as? CBOREncoderProtocol else { preconditionFailure("") }

                    try cborEncoder.indefiniteLengthContainerContext {
                        var container = cborEncoder.unkeyedContainer()

                        try container.encode(1)
                        try container.encode([2, 3])
                        try container.encode(CBOR.IndefiniteLengthArray<Int>(wrapping: [4, 5]))
                    }
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x9F018202039F0405FFFF")
        }

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        try encoder.indefiniteLengthContainerContext {
                            var container = encoder.unkeyedContainer()

                            try container.encode(1)
                            try container.encode([2, 3])

                            var nestedContainer = container.nestedUnkeyedContainer()
                            try nestedContainer.encode(4)
                            try nestedContainer.encode(5)
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x9F018202039F0405FFFF")
        }

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        try encoder.indefiniteLengthContainerContext {
                            var container = encoder.unkeyedContainer()
                            try container.encode(1)

                            try encoder.definiteLengthContainerContext {
                                var nestedContainer = container.nestedUnkeyedContainer()

                                try nestedContainer.encode(2)
                                try nestedContainer.encode(3)
                            }

                            var nestedContainer = container.nestedUnkeyedContainer()
                            try nestedContainer.encode(4)
                            try nestedContainer.encode(5)
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x9F018202039F0405FFFF")
        }
    }

    func testAppendixAComplexExamples11() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [_ 1, [2, 3], [4, 5]]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                if let encoder = encoder as? CBOREncoderProtocol {
                    try encoder.indefiniteLengthContainerContext {
                        var container = encoder.unkeyedContainer()

                        try container.encode(1)
                        try container.encode([2, 3])
                        try container.encode([4, 5])
                    }
                } else {
                    XCTFail("Invalid encoder type for test: \(encoder.self)")
                }
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x9F01820203820405FF")
    }

    func testAppendixAComplexExamples12() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1, [2, 3], [_ 4, 5]]

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()

                    try container.encode(1)
                    try container.encode([2, 3])
                    try container.encode(CBOR.IndefiniteLengthArray<Int>(wrapping: [4, 5]))
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x83018202039F0405FF")
        }

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        var container = encoder.unkeyedContainer()

                        try container.encode(1)
                        try container.encode([2, 3])

                        try encoder.indefiniteLengthContainerContext {
                            var nestedContainer = container.nestedUnkeyedContainer()

                            try nestedContainer.encode(4)
                            try nestedContainer.encode(5)
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x83018202039F0405FF")
        }
    }

    func testAppendixAComplexExamples13() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [1, [_ 2, 3], [4, 5]]

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()

                    try container.encode(1)
                    try container.encode(CBOR.IndefiniteLengthArray<Int>(wrapping: [2, 3]))
                    try container.encode([4, 5])
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x83019F0203FF820405")
        }

        do {
            struct Test: Encodable {

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        var container = encoder.unkeyedContainer()

                        try container.encode(1)

                        try encoder.indefiniteLengthContainerContext {
                            var nestedContainer = container.nestedUnkeyedContainer()

                            try nestedContainer.encode(2)
                            try nestedContainer.encode(3)
                        }

                        try container.encode([4, 5])
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0x83019F0203FF820405")
        }
    }

    func testAppendixAComplexExamples14() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // [_ 1,  2,  3,  4,  5,  6,  7,
        //    8,  9,  10, 11, 12, 13, 14,
        //    15, 16, 17, 18, 19, 20, 21,
        //    22, 23, 24, 25]

        let array = CBOR.IndefiniteLengthArray(wrapping: [1,  2,  3,  4,  5,  6,  7,
                                                          8,  9,  10, 11, 12, 13, 14,
                                                          15, 16, 17, 18, 19, 20, 21,
                                                          22, 23, 24, 25])
        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(array))
        XCTAssertEqual(convertToHexString(encodedData), "0x9F0102030405060708090A0B0C0D0E0F101112131415161718181819FF")
    }

    func testAppendixAComplexExamples15() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // {_ "a": 1, "b": [_ 2, 3]}

        do {
            struct Test: Encodable {

                private enum CodingKeys: String, CodingKey {
                    case a
                    case b
                }

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        try encoder.indefiniteLengthContainerContext {
                            var container = encoder.container(keyedBy: CodingKeys.self)

                            try container.encode(1, forKey: .a)
                            try container.encode(CBOR.IndefiniteLengthArray(wrapping: [2, 3]), forKey: .b)
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            encoder.keySorter = {
                let key1 = $0 as! String
                let key2 = $1 as! String

                return key1 < key2
            }
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0xBF61610161629F0203FFFF")
        }

        do {
            struct Test: Encodable {

                private enum CodingKeys: String, CodingKey {
                    case a
                    case b
                }

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        try encoder.indefiniteLengthContainerContext(includingSubcontainers: true) {
                            var container = encoder.container(keyedBy: CodingKeys.self)

                            try container.encode(1, forKey: .a)

                            var nestedContainer = container.nestedUnkeyedContainer(forKey: .b)
                            try nestedContainer.encode(2)
                            try nestedContainer.encode(3)
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            encoder.keySorter = {
                let key1 = $0 as! String
                let key2 = $1 as! String

                return key1 < key2
            }
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0xBF61610161629F0203FFFF")
        }

        do {
            struct Test: Encodable {

                private enum CodingKeys: String, CodingKey {
                    case a
                    case b
                }

                func encode(to encoder: Encoder) throws {
                    if let encoder = encoder as? CBOREncoderProtocol {
                        try encoder.indefiniteLengthContainerContext {
                            var container = encoder.container(keyedBy: CodingKeys.self)

                            try container.encode(1, forKey: .a)

                            try encoder.indefiniteLengthContainerContext {
                                var nestedContainer = container.nestedUnkeyedContainer(forKey: .b)
                                try nestedContainer.encode(2)
                                try nestedContainer.encode(3)
                            }
                        }
                    } else {
                        XCTFail("Invalid encoder type for test: \(encoder.self)")
                    }
                }
            }

            let encoder = CBOREncoder()
            encoder.keySorter = {
                let key1 = $0 as! String
                let key2 = $1 as! String

                return key1 < key2
            }
            var encodedData = Data()
            let test = Test()

            XCTAssertNoThrow(encodedData = try encoder.encode(test))
            XCTAssertEqual(convertToHexString(encodedData), "0xBF61610161629F0203FFFF")
        }
    }

    func testAppendixAComplexExamples16() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // ["a", {_ "b": "c"}]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()

                try container.encode("a")
                try container.encode(CBOR.IndefiniteLengthMap(wrapping: ["b": "c"]))
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x826161BF61626163FF")
    }

    func testAppendixAComplexExamples17() {
        // Test Examples taken from Appendix A of RFC 8949
        //
        // {_ "Fun": true, "Amt": -2}

        struct Test: Encodable {

            private enum CodingKeys: String, CodingKey {
                case key1 = "Fun"
                case key2 = "Amt"
            }

            func encode(to encoder: Encoder) throws {
                if let encoder = encoder as? CBOREncoderProtocol {
                    try encoder.indefiniteLengthContainerContext {
                        var container = encoder.container(keyedBy: CodingKeys.self)

                        try container.encode(true, forKey: .key1)
                        try container.encode(-2, forKey: .key2)
                    }
                } else {
                    XCTFail("Invalid encoder type for test: \(encoder.self)")
                }
            }
        }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let key1 = $0 as! String
            let key2 = $1 as! String

            return key1 > key2
        }
        var encodedData = Data()
        let test = Test()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xBF6346756EF563416D7421FF")
    }

    func testAppendixAComplexExamples18() {
        // {_ 1: "a", 2: "b" }

        let encoder = CBOREncoder()
        encoder.keySorter = {
            let key1 = $0 as! Int
            let key2 = $1 as! Int

            return key1 < key2
        }
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(CBOR.IndefiniteLengthMap(wrapping: [1: "a", 2: "b"])))
        XCTAssertEqual(convertToHexString(encodedData), "0xBF016161026162FF")
    }

    func testAppendixAComplexExamples19() {
        // [_ [_ 1, 2], [_ 3, 4]]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                if let encoder = encoder as? CBOREncoderProtocol {
                    try encoder.indefiniteLengthContainerContext(includingSubcontainers: true) {
                        var container = encoder.unkeyedContainer()

                        try container.encode([1, 2])
                        try container.encode([3, 4])
                    }
                } else {
                    XCTFail("Invalid encoder type for test: \(encoder.self)")
                }
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(Test()))
        XCTAssertEqual(convertToHexString(encodedData), "0x9F9F0102FF9F0304FFFF")
    }

    func testAppendixAComplexExamples20() {
        // [_ [1, 2], [3, 4]]

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                if let encoder = encoder as? CBOREncoderProtocol {
                    try encoder.indefiniteLengthContainerContext(includingSubcontainers: true) {
                        var container = encoder.unkeyedContainer()

                        try encoder.definiteLengthContainerContext(includingSubcontainers: true) {
                            try container.encode([1, 2])
                            try container.encode([3, 4])
                        }
                    }
                } else {
                    XCTFail("Invalid encoder type for test: \(encoder.self)")
                }
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(Test()))
        XCTAssertEqual(convertToHexString(encodedData), "0x9F820102820304FF")
    }

    func testFailureCases() {
        // Type that encodes no values throws
        struct EncodesNothing: Encodable {
            func encode(to encoder: Encoder) throws {
                /* Nothing to do */
            }
        }

        // Any error that gets thrown while encoding should propagate out
        struct ThrowsWhileEncoding: Encodable {
            func encode(to encoder: Encoder) throws {
                _ = encoder.unkeyedContainer()
                throw NSError(domain: "CBOREncoderTests", code: -1, userInfo: nil)
            }
        }

        let encoder = CBOREncoder()

        XCTAssertThrowsError(try encoder.encode(EncodesNothing()))
        XCTAssertThrowsError(try encoder.encode(ThrowsWhileEncoding()), "") {
            XCTAssertEqual(($0 as NSError).domain, "CBOREncoderTests")
            XCTAssertEqual(($0 as NSError).code, -1)
        }
        XCTAssertThrowsError(try encoder.encode(["Key": ThrowsWhileEncoding()]), "") {
            XCTAssertEqual(($0 as NSError).domain, "CBOREncoderTests")
            XCTAssertEqual(($0 as NSError).code, -1)
        }
        XCTAssertThrowsError(try encoder.encode([1: ThrowsWhileEncoding()]), "") {
            XCTAssertEqual(($0 as NSError).domain, "CBOREncoderTests")
            XCTAssertEqual(($0 as NSError).code, -1)
        }
    }

    func testEncodeEmptyDataTypes() {
        var encodedData = CBOREncoder.encode(Data())
        XCTAssertEqual(convertToHexString(encodedData), "0x40")

        encodedData = CBOREncoder.encode("")
        XCTAssertEqual(convertToHexString(encodedData), "0x60")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode([Int]()))
        XCTAssertEqual(convertToHexString(encodedData), "0x80")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode([Int: String]()))
        XCTAssertEqual(convertToHexString(encodedData), "0xA0")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode([String: String]()))
        XCTAssertEqual(convertToHexString(encodedData), "0xA0")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode(CBOR.IndefiniteLengthArray<Int>()))
        XCTAssertEqual(convertToHexString(encodedData), "0x9FFF")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode(CBOR.IndefiniteLengthMap<Int, String>()))
        XCTAssertEqual(convertToHexString(encodedData), "0xBFFF")

        XCTAssertNoThrow(encodedData = try CBOREncoder().encode(CBOR.IndefiniteLengthMap<String, String>()))
        XCTAssertEqual(convertToHexString(encodedData), "0xBFFF")
    }

    func testEncoderUserInfo() {
        let encoder = CBOREncoder()
        encoder.userInfo[CodingUserInfoKey(rawValue: "CBOREncoderKey")!] = -33781

        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                let value = encoder.userInfo[CodingUserInfoKey(rawValue: "CBOREncoderKey")!]

                XCTAssertNotNil(value)
                XCTAssertTrue(value! is Int)
                XCTAssertEqual(value as! Int, -33781)
            }
        }

        XCTAssertThrowsError(try encoder.encode(Test()))
    }

    func testSuperEncoder1() {
        class Test1: Encodable {
            private enum CodingKeys: String, CodingKey {
                case a
            }
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()

                var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self)
                try nestedContainer.encode([0, 1], forKey: .a)
            }
        }
        class Test2: Test1 {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try super.encode(to: container.superEncoder())

                try container.encode(2)
                try container.encode(3)
            }
        }

        let encoder = CBOREncoder()
        let test = Test2()

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x8381A161618200010203")
    }

    func testSuperEncoder2() {
        class Test1: Encodable {

            private enum CodingKeys1: String, CodingKey {
                case a
            }
            private enum CodingKeys2: String, CodingKey {
                case b
                case c
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys1.self)
                var nestedContainer = container.nestedContainer(keyedBy: CodingKeys2.self, forKey: .a)

                try nestedContainer.encodeNil(forKey: .b)
                try nestedContainer.encode(false, forKey: .c)
            }
        }
        class Test2: Test1 {

            private enum CodingKeys: String, CodingKey {
                case t
            }

            override func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try super.encode(to: container.superEncoder())
                try super.encode(to: container.superEncoder(forKey: .t))
            }
        }

        let encoder = CBOREncoder()
        let test = Test2()

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xA2657375706572A16161A26162F66163F46174A16161A26162F66163F4")
    }

    func testSuperEncoder3() {
        class Test1: Encodable {
            func encode(to encoder: Encoder) throws { }
        }
        class Test2: Test1 {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try super.encode(to: container.superEncoder())

                try container.encode(1)
                try container.encode(2)
            }
        }

        let encoder = CBOREncoder()
        let test = Test2()

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x820102")
    }

    func testEncodePrimitiveTypes1() {
        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()

                try container.encodeNil()
                try container.encode(true)
                try container.encode(Int(20))
                try container.encode(Int8(20))
                try container.encode(Int16(20))
                try container.encode(Int32(20))
                try container.encode(Int64(20))
                try container.encode(UInt(20))
                try container.encode(UInt8(20))
                try container.encode(UInt16(20))
                try container.encode(UInt32(20))
                try container.encode(UInt64(20))
                try container.encode("CBOR")
                try container.encode(Float(100000.0))
                try container.encode(Double(-4.1))
            }
        }

        let encoder = CBOREncoder()
        let test = Test()

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0x8FF6F5141414141414141414146443424F52FA47C35000FBC010666666666666")
    }

    func testEncodePrimitiveTypes2() {
        struct Test: Encodable {

            private enum CodingKeys: String, CodingKey {
                case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encodeNil(forKey: .a)
                try container.encode(true, forKey: .b)
                try container.encode(Int(20), forKey: .c)
                try container.encode(Int8(20), forKey: .d)
                try container.encode(Int16(20), forKey: .e)
                try container.encode(Int32(20), forKey: .f)
                try container.encode(Int64(20), forKey: .g)
                try container.encode(UInt(20), forKey: .h)
                try container.encode(UInt8(20), forKey: .i)
                try container.encode(UInt16(20), forKey: .j)
                try container.encode(UInt32(20), forKey: .k)
                try container.encode(UInt64(20), forKey: .l)
                try container.encode("CBOR", forKey: .m)
                try container.encode(Float(100000.0), forKey: .n)
                try container.encode(Double(-4.1), forKey: .o)
            }
        }

        let encoder = CBOREncoder()
        let test = Test()

        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(test))
        XCTAssertEqual(convertToHexString(encodedData), "0xAF6161F66162F5616314616414616514616614616714616814616914616A14616B14616C14616D6443424F52616EFA47C35000616FFBC010666666666666")
    }

    func testEncodePrimitiveTypes3() {
        class Testable: Encodable { func encode(to encoder: Encoder) throws {} }

        class TestNil: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }
        class TestBool: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(false)
            }
        }
        class TestInt8: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Int8(20))
            }
        }
        class TestInt16: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Int16(20))
            }
        }
        class TestInt32: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Int32(20))
            }
        }
        class TestInt64: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Int64(20))
            }
        }
        class TestInt: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Int(20))
            }
        }
        class TestUInt8: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(UInt8(20))
            }
        }
        class TestUInt16: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(UInt16(20))
            }
        }
        class TestUInt32: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(UInt32(20))
            }
        }
        class TestUInt64: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(UInt64(20))
            }
        }
        class TestUInt: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(UInt(20))
            }
        }
        class TestString: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode("CBOR")
            }
        }
        class TestFloat: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Float(100000.0))
            }
        }
        class TestDouble: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Double(-4.1))
            }
        }

        let testData: [(Testable, String)] = [
            (TestNil(),    "0xF6"),
            (TestBool(),   "0xF4"),
            (TestInt8(),   "0x14"),
            (TestInt16(),  "0x14"),
            (TestInt32(),  "0x14"),
            (TestInt64(),  "0x14"),
            (TestInt(),    "0x14"),
            (TestUInt8(),  "0x14"),
            (TestUInt16(), "0x14"),
            (TestUInt32(), "0x14"),
            (TestUInt64(), "0x14"),
            (TestUInt(),   "0x14"),
            (TestString(), "0x6443424F52"),
            (TestFloat(),  "0xFA47C35000"),
            (TestDouble(), "0xFBC010666666666666")
        ]

        let encoder = CBOREncoder()
        var encodedData = Data()

        for test in testData {
            XCTAssertNoThrow(encodedData = try encoder.encode(test.0))
            XCTAssertEqual(convertToHexString(encodedData), test.1)
        }
    }

    func testEncodePrimitiveTypes4() {
        class Testable: Encodable { func encode(to encoder: Encoder) throws {} }

        class TestDate: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Date(timeIntervalSince1970: 1363896240))
            }
        }
        class TestData: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(Data([UInt8(0x01), 0x02, 0x03, 0x04]))
            }
        }
        class TestURL: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(URL(string: "http://www.example.com")!)
            }
        }
        class TestUndefined: Testable {
            override func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(CBOR.Undefined())
            }
        }

        let testData: [(Testable, String)] = [
            (TestDate(),      "0xC11A514B67B0"),
            (TestData(),      "0x4401020304"),
            (TestURL(),       "0xD82076687474703A2F2F7777772E6578616D706C652E636F6D"),
            (TestUndefined(), "0xF7")
        ]

        let encoder = CBOREncoder()
        var encodedData = Data()

        for test in testData {
            XCTAssertNoThrow(encodedData = try encoder.encode(test.0))
            XCTAssertEqual(convertToHexString(encodedData), test.1)
        }
    }

    func testTaggedValues() {
        let encoder = CBOREncoder()

        let testData: [(Data, String)] = [
            (try! CBOREncoder.encode(rfc3339Date(),       forTag: .standardDateTime).encodedData, "0xC074323031332D30332D32315432303A30343A30305A"),
            (try! CBOREncoder.encode(rfc3339DateString(), forTag: .standardDateTime).encodedData, "0xC074323031332D30332D32315432303A30343A30305A"),

            (try! CBOREncoder.encode(Date(timeIntervalSince1970: 1), forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Int(1),                         forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Int8(1),                        forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Int16(1),                       forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Int32(1),                       forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Int64(1),                       forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(UInt(1),                        forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(UInt8(1),                       forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(UInt16(1),                      forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(UInt32(1),                      forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(UInt64(1),                      forTag: .epochDateTime).encodedData, "0xC101"),
            (try! CBOREncoder.encode(Float(1363896240.5),            forTag: .epochDateTime).encodedData, "0xC1FA4EA296CF"),
            (try! CBOREncoder.encode(Double(1363896240.5),           forTag: .epochDateTime).encodedData, "0xC1FB41D452D9EC200000"),

            (try! CBOREncoder.encode(Data([UInt8(0x00)]),            forTag: .positiveBignum).encodedData, "0xC24100"),
            (try! CBOREncoder.encode(Data([UInt8(0x00)]),            forTag: .negativeBignum).encodedData, "0xC34100"),

            (try! CBOREncoder.encode([Int(1), 15],                   forTag: .decimalFraction).encodedData, "0xC482010F"),
            (try! CBOREncoder.encode([Int8(1), 15],                  forTag: .decimalFraction).encodedData, "0xC482010F"),
            (try! CBOREncoder.encode([Int16(1), 15],                 forTag: .decimalFraction).encodedData, "0xC482010F"),
            (try! CBOREncoder.encode([Int32(1), 15],                 forTag: .decimalFraction).encodedData, "0xC482010F"),
            (try! CBOREncoder.encode([Int64(1), 15],                 forTag: .decimalFraction).encodedData, "0xC482010F"),
            (try! CBOREncoder.encode([UInt(1), 15],                  forTag: .bigfloat).encodedData,        "0xC582010F"),
            (try! CBOREncoder.encode([UInt8(1), 15],                 forTag: .bigfloat).encodedData,        "0xC582010F"),
            (try! CBOREncoder.encode([UInt16(1), 15],                forTag: .bigfloat).encodedData,        "0xC582010F"),
            (try! CBOREncoder.encode([UInt32(1), 15],                forTag: .bigfloat).encodedData,        "0xC582010F"),
            (try! CBOREncoder.encode([UInt64(1), 15],                forTag: .bigfloat).encodedData,        "0xC582010F"),

            (try! encoder.encode(CBOR.DecimalFraction(exponent: Int(1), mantissa: 15)),   "0xC482010F"),
            (try! encoder.encode(CBOR.DecimalFraction(exponent: Int8(1), mantissa: 15)),  "0xC482010F"),
            (try! encoder.encode(CBOR.DecimalFraction(exponent: Int16(1), mantissa: 15)), "0xC482010F"),
            (try! encoder.encode(CBOR.DecimalFraction(exponent: Int32(1), mantissa: 15)), "0xC482010F"),
            (try! encoder.encode(CBOR.DecimalFraction(exponent: Int64(1), mantissa: 15)), "0xC482010F"),
            (try! encoder.encode(CBOR.Bigfloat(exponent: UInt(1), mantissa: 15)),         "0xC582010F"),
            (try! encoder.encode(CBOR.Bigfloat(exponent: UInt8(1), mantissa: 15)),        "0xC582010F"),
            (try! encoder.encode(CBOR.Bigfloat(exponent: UInt16(1), mantissa: 15)),       "0xC582010F"),
            (try! encoder.encode(CBOR.Bigfloat(exponent: UInt32(1), mantissa: 15)),       "0xC582010F"),
            (try! encoder.encode(CBOR.Bigfloat(exponent: UInt64(1), mantissa: 15)),       "0xC582010F"),

            (try! CBOREncoder.encode(Data([UInt8(0x01)]),            forTag: .base64URLConversion).encodedData, "0xD54101"),
            (try! CBOREncoder.encode(Data([UInt8(0x01)]),            forTag: .base64Conversion).encodedData,    "0xD64101"),
            (try! CBOREncoder.encode(Data([UInt8(0x01)]),            forTag: .base16Conversion).encodedData,    "0xD74101"),
            (try! CBOREncoder.encode("a",                            forTag: .base64URLConversion).encodedData, "0xD56161"),
            (try! CBOREncoder.encode("a",                            forTag: .base64Conversion).encodedData,    "0xD66161"),
            (try! CBOREncoder.encode("a",                            forTag: .base16Conversion).encodedData,    "0xD76161"),

            (try! CBOREncoder.encode("http://www.example.com",               forTag: .uri).encodedData,         "0xD82076687474703A2F2F7777772E6578616D706C652E636F6D"),
            (try! CBOREncoder.encode(URL(string: "http://www.example.com")!, forTag: .uri).encodedData,         "0xD82076687474703A2F2F7777772E6578616D706C652E636F6D"),

            (try! CBOREncoder.encode("a",                            forTag: .base64URL).encodedData,           "0xD8216161"),
            (try! CBOREncoder.encode("a",                            forTag: .base64).encodedData,              "0xD8226161"),
            (try! CBOREncoder.encode("a",                            forTag: .mimeMessage).encodedData,         "0xD8246161"),

            (try! CBOREncoder.encode(try! NSRegularExpression(pattern: "sal?t",
                                                              options: []), forTag: .regularExpression).encodedData, "0xD8236573616C3F74"),
            (try! CBOREncoder.encode("sal?t",                               forTag: .regularExpression).encodedData, "0xD8236573616C3F74"),

            (try! CBOREncoder.encode(Data([UInt8(0x64)]) + Data("CBOR".utf8), forTag: .selfDescribedCBOR).encodedData, "0xD9D9F76443424F52")
        ]

        for (encodedData, string) in testData {
            XCTAssertEqual(convertToHexString(encodedData), string)
        }
    }

    func testSelfDescribedCBOR() {
        let encoder = CBOREncoder()
        var encodedValue = Data(), encodedValueWithTag = Data()

        encoder.includeCBORTag = false
        XCTAssertNoThrow(encodedValue = try encoder.encode("CBOR"))

        encoder.includeCBORTag = true
        XCTAssertNoThrow(encodedValueWithTag = try encoder.encode("CBOR"))

        XCTAssertEqual(encodedValue.count, encodedValueWithTag.count - 3)
        XCTAssertEqual(encodedValue, Data(encodedValueWithTag[3...]))
        XCTAssertEqual(convertToHexString(Data(encodedValueWithTag[0 ..< 3])), "0xD9D9F7")
    }

    func testTaggedValuesFailureCases() {
        XCTAssertThrowsError(try CBOREncoder.encode(rfc3339Date().timeIntervalSince1970, forTag: .standardDateTime))
        XCTAssertThrowsError(try CBOREncoder.encode(rfc3339DateString(),                 forTag: .epochDateTime))
        XCTAssertThrowsError(try CBOREncoder.encode(UInt64.max,                              forTag: .positiveBignum))
        XCTAssertThrowsError(try CBOREncoder.encode(Int64.min,                               forTag: .negativeBignum))
        XCTAssertThrowsError(try CBOREncoder.encode([Double.pi, 1.0, -0.5],                  forTag: .decimalFraction))
        XCTAssertThrowsError(try CBOREncoder.encode([Double.pi, 1.0],                        forTag: .decimalFraction))
        XCTAssertThrowsError(try CBOREncoder.encode([Double.pi, 1.0, -0.5],                  forTag: .bigfloat))
        XCTAssertThrowsError(try CBOREncoder.encode([Double.pi, 1.0],                        forTag: .bigfloat))
        XCTAssertThrowsError(try CBOREncoder.encode(URL(string: "http://www.example.com")!,  forTag: .base64URLConversion))
        XCTAssertThrowsError(try CBOREncoder.encode(URL(string: "http://www.example.com")!,  forTag: .base64Conversion))
        XCTAssertThrowsError(try CBOREncoder.encode(URL(string: "http://www.example.com")!,  forTag: .base16Conversion))
        XCTAssertThrowsError(try CBOREncoder.encode("CBOR",                                  forTag: .encodedCBORData))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .uri))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .base64URL))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .base64))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .mimeMessage))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .regularExpression))
        XCTAssertThrowsError(try CBOREncoder.encode(Data(),                                  forTag: .regularExpression))
        XCTAssertThrowsError(try CBOREncoder.encode("CBOR",                                  forTag: .selfDescribedCBOR))
    }

    func testDuplicateContainers1() {
        struct Test: Encodable {

            func encode(to encoder: Encoder) throws {
                do {
                    var container = encoder.unkeyedContainer()
                    try container.encode(true)
                }
                do {
                    var container = encoder.unkeyedContainer()
                    try container.encode(false)
                }
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(Test()))
        XCTAssertEqual(convertToHexString(encodedData), "0x82F5F4")
    }

    func testDuplicateContainers2() {
        struct Test: Encodable {

            private enum CodingKeys: String, CodingKey {
                case a
                case b
            }

            func encode(to encoder: Encoder) throws {
                do {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(true, forKey: .a)
                }
                do {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(false, forKey: .b)
                }
            }
        }

        let encoder = CBOREncoder()
        var encodedData = Data()

        XCTAssertNoThrow(encodedData = try encoder.encode(Test()))
        XCTAssertEqual(convertToHexString(encodedData), "0xA26161F56162F4")
    }

    // MARK: Private Methods

    private func convertToHexString(_ data: Data) -> String {
        // swiftlint:disable trailing_closure
        return "0x" + data.map({ String(format: "%02X", $0) }).joined()
        // swiftlint:enable trailing_closure
    }

    private func rfc3339DateString() -> String {
        return "2013-03-21T20:04:00Z"
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
