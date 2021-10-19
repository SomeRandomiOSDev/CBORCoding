//
//  CBOR+Equatable.swift
//  CBORCoding
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - CBOR.NegativeUInt64 Extension

extension CBOR.NegativeUInt64: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.NegativeUInt64, rhs: CBOR.NegativeUInt64) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - CBOR.SimpleValue Extension

extension CBOR.SimpleValue: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.SimpleValue, rhs: CBOR.SimpleValue) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - CBOR.Bignum Extension

extension CBOR.Bignum: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.Bignum, rhs: CBOR.Bignum) -> Bool {
        return lhs.isPositive == rhs.isPositive && lhs.content == rhs.content
    }
}

// MARK: - CBOR.DecimalFraction Extension

extension CBOR.DecimalFraction: Equatable {

    public static func == (lhs: CBOR.DecimalFraction<I1, I2>, rhs: CBOR.DecimalFraction<I1, I2>) -> Bool {
        return lhs.exponent == rhs.exponent && lhs.mantissa == rhs.mantissa
    }
}

// MARK: - CBOR.Bigfloat Extension

extension CBOR.Bigfloat: Equatable {

    public static func == (lhs: CBOR.Bigfloat<I1, I2>, rhs: CBOR.Bigfloat<I1, I2>) -> Bool {
        return lhs.exponent == rhs.exponent && lhs.mantissa == rhs.mantissa
    }
}

// MARK: - CBOR.IndefiniteLengthArray Extension

extension CBOR.IndefiniteLengthArray: Equatable where Element: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.IndefiniteLengthArray<Element>, rhs: CBOR.IndefiniteLengthArray<Element>) -> Bool {
        return lhs.array == rhs.array
    }
}

// MARK: - CBOR.IndefiniteLengthMap Extension

extension CBOR.IndefiniteLengthMap: Equatable where Value: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.IndefiniteLengthMap<Key, Value>, rhs: CBOR.IndefiniteLengthMap<Key, Value>) -> Bool {
        return lhs.map == rhs.map
    }
}

// MARK: - CBOR.IndefiniteLengthData Extension

extension CBOR.IndefiniteLengthData: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.IndefiniteLengthData, rhs: CBOR.IndefiniteLengthData) -> Bool {
        return lhs.chunks == rhs.chunks
    }
}

// MARK: - CBOR.IndefiniteLengthString Extension

extension CBOR.IndefiniteLengthString: Equatable {

    // MARK: Equatable Protocol Requirements

    public static func == (lhs: CBOR.IndefiniteLengthString, rhs: CBOR.IndefiniteLengthString) -> Bool {
        return lhs.chunks == rhs.chunks
    }
}
