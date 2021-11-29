//
//  ContainersTests.swift
//  CBORCodingTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

// swiftlint:disable identifier_name force_unwrapping

@testable import CBORCoding
import XCTest

// MARK: - ContainersTests Definition

class ContainersTests: XCTestCase {

    // MARK: Test Methods

    func testArrayWrapperInitialization() {
        var wrapper = ArrayWrapper<Int>()
        XCTAssertEqual(wrapper.count, 0)
        XCTAssertFalse(wrapper.indefiniteLength)

        wrapper = ArrayWrapper<Int>(indefiniteLength: false)
        XCTAssertEqual(wrapper.count, 0)
        XCTAssertFalse(wrapper.indefiniteLength)

        wrapper = ArrayWrapper<Int>(indefiniteLength: true)
        XCTAssertEqual(wrapper.count, 0)
        XCTAssertTrue(wrapper.indefiniteLength)

        wrapper = ArrayWrapper<Int>(wrapping: [3], indefiniteLength: false)
        XCTAssertEqual(wrapper.count, 1)
        XCTAssertEqual(wrapper[0], 3)
        XCTAssertFalse(wrapper.indefiniteLength)

        wrapper = ArrayWrapper<Int>(wrapping: [5], indefiniteLength: true)
        XCTAssertEqual(wrapper.count, 1)
        XCTAssertEqual(wrapper[0], 5)
        XCTAssertTrue(wrapper.indefiniteLength)
    }

    func testArrayWrapperImplementedProtocolRequirements() {
        var array   = [0, 1, 2, 3, 4]
        let wrapper = ArrayWrapper(wrapping: array)

        do {
            var arrayIterator = array.makeIterator()
            var wrapperIterator = wrapper.makeIterator()

            var value1 = arrayIterator.next()
            var value2 = wrapperIterator.next()

            repeat {
                XCTAssertNotNil(value1)
                XCTAssertNotNil(value2)
                XCTAssertEqual(value1, value2)

                value1 = arrayIterator.next()
                value2 = wrapperIterator.next()
            } while value1 != nil && value2 != nil

            XCTAssertNil(value1)
            XCTAssertNil(value2)
        }

        XCTAssertEqual(array.startIndex, wrapper.startIndex)
        XCTAssertEqual(array.endIndex, wrapper.endIndex)
        XCTAssertEqual(array.index(after: array.startIndex), wrapper.index(after: wrapper.startIndex))
        XCTAssertEqual(array.index(before: array.endIndex), wrapper.index(before: wrapper.endIndex))

        array[2]   = -1
        wrapper[2] = -1

        XCTAssertEqual(array[2], -1)
        XCTAssertEqual(wrapper[2], -1)

        array.replaceSubrange(0 ..< 2, with: [4, 13])
        wrapper.replaceSubrange(0 ..< 2, with: [4, 13])

        XCTAssertEqual(array[0], 4)
        XCTAssertEqual(array[1], 13)
        XCTAssertEqual(wrapper[0], 4)
        XCTAssertEqual(wrapper[1], 13)
    }

    func testCodingKeyDictionaryInitialization() {
        var dictionary = CodingKeyDictionary<Int>()
        XCTAssertEqual(dictionary.count, 0)
        XCTAssertEqual(dictionary.keys.count, 0)
        XCTAssertEqual(dictionary.values.count, 0)
        XCTAssertFalse(dictionary.indefiniteLength)

        dictionary = CodingKeyDictionary<Int>(indefiniteLength: false)
        XCTAssertEqual(dictionary.count, 0)
        XCTAssertEqual(dictionary.keys.count, 0)
        XCTAssertEqual(dictionary.values.count, 0)
        XCTAssertFalse(dictionary.indefiniteLength)

        dictionary = CodingKeyDictionary<Int>(indefiniteLength: true)
        XCTAssertEqual(dictionary.count, 0)
        XCTAssertEqual(dictionary.keys.count, 0)
        XCTAssertEqual(dictionary.values.count, 0)
        XCTAssertTrue(dictionary.indefiniteLength)

        enum CodingKeys: String, CodingKey {
            case a
            case b
        }

        dictionary = [CodingKeys.a: 1, CodingKeys.b: 2]
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertEqual(dictionary.keys.count, 2)
        XCTAssertEqual(dictionary.values.count, 2)
        XCTAssertEqual(dictionary[CodingKeys.a], 1)
        XCTAssertEqual(dictionary[CodingKeys.b], 2)
        XCTAssertFalse(dictionary.indefiniteLength)
    }

    func testCodingKeyDictionaryImplementedProtocolRequirements() {
        enum CodingKeys: Int, CodingKey {
            case a = 1
            case b = 2
            case c = 3
        }

        let dictionary: CodingKeyDictionary<String> = [
            CodingKeys.a: "a",
            CodingKeys.b: "b"
        ]

        XCTAssertEqual(dictionary.keys[0].intValue, CodingKeys.a.rawValue)
        XCTAssertEqual(dictionary.keys[1].intValue, CodingKeys.b.rawValue)
        XCTAssertEqual(dictionary.values[0], "a")
        XCTAssertEqual(dictionary.values[1], "b")

        XCTAssertEqual(dictionary[CodingKeys.a], "a")
        XCTAssertEqual(dictionary[CodingKeys.b], "b")
        XCTAssertNil(dictionary[CodingKeys.c])

        dictionary[CodingKeys.c] = "c"
        XCTAssertEqual(dictionary[CodingKeys.c], "c")

        dictionary[CodingKeys.c] = "C"
        XCTAssertEqual(dictionary[CodingKeys.c], "C")

        dictionary[CodingKeys.c] = nil
        XCTAssertNil(dictionary[CodingKeys.c])

        var iterator = dictionary.makeIterator()
        var pair: (key: CodingKey, value: String)?

        pair = iterator.next()
        XCTAssertNotNil(pair)
        XCTAssertEqual(pair!.key.intValue, CodingKeys.a.rawValue)
        XCTAssertEqual(pair!.value, "a")

        pair = iterator.next()
        XCTAssertNotNil(pair)
        XCTAssertEqual(pair!.key.intValue, CodingKeys.b.rawValue)
        XCTAssertEqual(pair!.value, "b")

        pair = iterator.next()
        XCTAssertNil(pair)
    }
}
