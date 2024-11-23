// Copyright 2024 Lie Yan

import Foundation

/**
 A scalar value is essentially a double-precision float, with the potential for
 additional checks and operations to be added in the future.

 */
struct Scalar: Equatable, Hashable, Codable, Comparable,
    ExpressibleByFloatLiteral, SignedNumeric
{
    typealias Magnitude = Scalar
    typealias IntegerLiteralType = Int
    typealias FloatLiteralType = Double

    let floatValue: Double

    init(_ floatValue: Double) {
        if floatValue.isNaN {
            self.floatValue = 0
        }
        else {
            self.floatValue = floatValue
        }
    }

    init(integerLiteral value: Int) {
        self.init(Double(value))
    }

    init(floatLiteral value: Double) {
        self.init(value)
    }

    init?<T>(exactly source: T) where T: BinaryInteger {
        self.init(Double(source))
    }

    var magnitude: Scalar {
        Scalar(floatValue.magnitude)
    }

    var isFinite: Bool {
        floatValue.isFinite
    }

    static func == (lhs: Scalar, rhs: Scalar) -> Bool {
        lhs.floatValue == rhs.floatValue
    }

    static func < (lhs: Scalar, rhs: Scalar) -> Bool {
        lhs.floatValue < rhs.floatValue
    }

    static func + (lhs: Scalar, rhs: Scalar) -> Scalar {
        Scalar(lhs.floatValue + rhs.floatValue)
    }

    static func - (lhs: Scalar, rhs: Scalar) -> Scalar {
        Scalar(lhs.floatValue - rhs.floatValue)
    }

    static func * (lhs: Scalar, rhs: Scalar) -> Scalar {
        Scalar(lhs.floatValue * rhs.floatValue)
    }

    static func / (lhs: Scalar, rhs: Scalar) -> Scalar {
        Scalar(lhs.floatValue / rhs.floatValue)
    }

    static func *= (lhs: inout Scalar, rhs: Scalar) {
        lhs = lhs * rhs
    }
}
