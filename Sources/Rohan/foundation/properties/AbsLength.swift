// Copyright 2024 Lie Yan

import Foundation

/**
 Absolute length

 Supported units:
 - points
 - millimeters
 - centimeters
 - picas
 - inches
 */
struct AbsLength: Equatable, Hashable, Codable {
    private let rawValue: Double

    var ptValue: Double {
        rawValue * InvScales.pt
    }

    var mmValue: Double {
        rawValue * InvScales.mm
    }

    var cmValue: Double {
        rawValue * InvScales.cm
    }

    var picaValue: Double {
        rawValue * InvScales.pica
    }

    var inValue: Double {
        rawValue * InvScales.`in`
    }

    var isFinite: Bool {
        rawValue.isFinite
    }

    /**
     Instantiates with points

     - Precondition: value is finite
     */
    static func pt(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.pt)
    }

    /**
     Instantiates with millimeters

     - Precondition: value is finite
     */
    static func mm(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.mm)
    }

    /**
     Instantiates with centimeters

     - Precondition: value is finite
     */
    static func cm(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.cm)
    }

    /**
     Instantiates with picas

     - Precondition: value is finite
     */
    static func pica(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.pica)
    }

    /**
     Instantiates with inches

     - Precondition: value is finite
     */
    static func `in`(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.`in`)
    }

    private init(_ rawValue: Double) {
        precondition(rawValue.isFinite)

        self.rawValue = rawValue
    }

    /**
     Scales for conversion

     - SeeAlso: [Desktop publishing point](
     https://en.wikipedia.org/wiki/Point_(typography)#Desktop_publishing_point )
     */
    private enum Scales {
        static let pt = 1.0
        static let mm = 72 / 25.4
        static let cm = 72 / 2.54
        static let pica = 12.0
        static let `in` = 72.0
    }

    private enum InvScales {
        static let pt = 1.0
        static let mm = 25.4 / 72
        static let cm = 2.54 / 72
        static let pica = 1.0 / 12
        static let `in` = 1.0 / 72
    }
}

extension AbsLength: Comparable {
    static func < (lhs: AbsLength, rhs: AbsLength) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension AbsLength: AdditiveArithmetic {
    static func - (lhs: AbsLength, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs.rawValue - rhs.rawValue)
    }

    static func + (lhs: AbsLength, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs.rawValue + rhs.rawValue)
    }

    static var zero: AbsLength {
        AbsLength(0)
    }
}

extension AbsLength {
    static func * (lhs: AbsLength, rhs: Double) -> AbsLength {
        AbsLength(lhs.rawValue * rhs)
    }

    static func * (lhs: Double, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs * rhs.rawValue)
    }
}
