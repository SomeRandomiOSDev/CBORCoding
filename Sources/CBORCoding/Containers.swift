//
//  Containers.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - ArrayWrapper Definition

/// Internal class based array for reference semantics without having to involve the
/// Objective-C runtime (NSArray)
internal class ArrayWrapper<Element>: MutableCollection, RandomAccessCollection, RangeReplaceableCollection {

    // MARK: - Private Properties

    var array: [Element]

    // MARK: - Properties

    let indefiniteLength: Bool

    // MARK: - Initialization

    required init() {
        self.array = []
        self.indefiniteLength = false
    }

    init(indefiniteLength: Bool) {
        self.array = []
        self.indefiniteLength = indefiniteLength
    }

    init(wrapping array: [Element] = [], indefiniteLength: Bool = false) {
        self.array = array
        self.indefiniteLength = indefiniteLength
    }

    // MARK: - Sequence/Collection/MutableCollection/BidirectionalCollection/RandomAccessCollection Protocol Requirements

    func makeIterator() -> Array<Element>.Iterator {
        return array.makeIterator()
    }

    var startIndex: Int {
        return array.startIndex
    }

    var endIndex: Int {
        return array.endIndex
    }

    func index(after i: Int) -> Int {
        return array.index(after: i)
    }

    func index(before i: Int) -> Int {
        return array.index(before: i)
    }

    subscript(index: Int) -> Element {
        get { return array[index] }
        set { array[index] = newValue }
    }

    // MARK: - RangeReplaceableCollection Protocol Requirements

    func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C: Collection, R: RangeExpression, Element == C.Element, Index == R.Bound {
        array.replaceSubrange(subrange, with: newElements)
    }

    func insert(_ newElement: __owned Element, at i: Int) {
        array.insert(newElement, at: i)
    }

    func append(_ newElement: __owned Element) {
        array.append(newElement)
    }
}

// MARK: - CodingKeyDictionary Definition

/// Internal class based dictionary for reference semantics without having to
/// involve the Objective-C runtime (NSDictionary)
internal class CodingKeyDictionary<Value>: Sequence, ExpressibleByDictionaryLiteral {

    // MARK: - Private Properties

    private var keyValuePairs: [(key: CodingKey, value: Value)]

    // MARK: - Properties

    var count: Int {
        return keyValuePairs.count
    }

    var keys: [CodingKey] {
        return keyValuePairs.map { $0.0 }
    }

    var values: [Value] {
        return keyValuePairs.map { $0.1 }
    }

    let indefiniteLength: Bool

    // MARK: - Initialization

    init(indefiniteLength: Bool = false) {
        self.keyValuePairs    = []
        self.indefiniteLength = indefiniteLength
    }

    // MARK: - Subscripting

    subscript(key: CodingKey) -> Value? {
        get {
            let value: Value?
            if let intValue = key.intValue {
                if let pair = keyValuePairs.first(where: { $0.key.intValue == intValue }) {
                    value = pair.value
                } else {
                    value = nil
                }
            } else {
                if let pair = keyValuePairs.first(where: { $0.key.stringValue == key.stringValue }) {
                    value = pair.value
                } else {
                    value = nil
                }
            }

            return value
        }
        set {
            if let index = keyValuePairs.firstIndex(where: { $0.key.stringValue == key.stringValue }) {
                if let newValue = newValue {
                    keyValuePairs[index] = (key, newValue)
                } else {
                    keyValuePairs.remove(at: index)
                }
            } else {
                if let newValue = newValue {
                    keyValuePairs.append((key, newValue))
                }
            }
        }
    }

    // MARK: - Sequence Protocol Requirements

    func makeIterator() -> Array<(key: CodingKey, value: Value)>.Iterator {
        return keyValuePairs.makeIterator()
    }

    // MARK: - ExpressibleByDictionaryLiteral Protocol Requirements

    typealias Key = CodingKey

    required init(dictionaryLiteral elements: (Key, Value)...) {
        self.keyValuePairs = elements
        self.indefiniteLength = false
    }
}
