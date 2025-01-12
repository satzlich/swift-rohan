// Copyright 2024-2025 Lie Yan

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
public struct AbsLength: Equatable, Hashable, Codable {
    private let rawValue: Double

    public var ptValue: Double { rawValue * InvScales.pt }
    public var mmValue: Double { rawValue * InvScales.mm }
    public var cmValue: Double { rawValue * InvScales.cm }
    public var picaValue: Double { rawValue * InvScales.pica }
    public var inchValue: Double { rawValue * InvScales.inch }

    public var isFinite: Bool { rawValue.isFinite }

    public static func pt(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.pt)
    }

    public static func mm(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.mm)
    }

    public static func cm(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.cm)
    }

    public static func pica(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.pica)
    }

    public static func inch(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.inch)
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
        static let inch = 72.0
    }

    private enum InvScales {
        static let pt = 1.0
        static let mm = 25.4 / 72
        static let cm = 2.54 / 72
        static let pica = 1.0 / 12
        static let inch = 1.0 / 72
    }
}

extension AbsLength: Comparable {
    public static func < (lhs: AbsLength, rhs: AbsLength) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension AbsLength: AdditiveArithmetic {
    public static func - (lhs: AbsLength, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs.rawValue - rhs.rawValue)
    }

    public static func + (lhs: AbsLength, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs.rawValue + rhs.rawValue)
    }

    public static var zero: AbsLength { AbsLength(0) }
}

extension AbsLength {
    public static func * (lhs: AbsLength, rhs: Double) -> AbsLength {
        AbsLength(lhs.rawValue * rhs)
    }

    public static func * (lhs: Double, rhs: AbsLength) -> AbsLength {
        AbsLength(lhs * rhs.rawValue)
    }

    public static func / (lhs: AbsLength, rhs: Double) -> AbsLength {
        AbsLength(lhs.rawValue / rhs)
    }
}

extension AbsLength: CustomStringConvertible {
    public var description: String {
        String(format: "%.2f", ptValue)
    }
}
