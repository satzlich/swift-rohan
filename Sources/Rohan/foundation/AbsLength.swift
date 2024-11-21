// Copyright 2024 Lie Yan

import Foundation

/**
 Absolute length

 Supported units:
 - points
 - millimeters
 - centimeters
 - inches
 */
struct AbsLength: Equatable, Hashable, Codable {
    let ptValue: Double

    var mmValue: Double {
        ptValue * Scales.mm
    }

    var cmValue: Double {
        ptValue * Scales.cm
    }

    var inValue: Double {
        ptValue * Scales.in
    }

    static func pt(_ value: Double) -> AbsLength {
        AbsLength(value / Scales.pt)
    }

    static func mm(_ value: Double) -> AbsLength {
        AbsLength(value / Scales.mm)
    }

    static func cm(_ value: Double) -> AbsLength {
        AbsLength(value / Scales.cm)
    }

    static func `in`(_ value: Double) -> AbsLength {
        AbsLength(value / Scales.in)
    }

    private init(_ ptValue: Double) {
        self.ptValue = ptValue
    }

    /// Scales for conversion
    private enum Scales {
        static let pt = 1.0
        static let mm = 2.83465
        static let cm = 28.3465
        static let `in` = 72.0
    }
}
