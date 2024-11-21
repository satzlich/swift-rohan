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
        ptValue * InvScales.mm
    }

    var cmValue: Double {
        ptValue * InvScales.cm
    }

    var inValue: Double {
        ptValue * InvScales.in
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
     Instantiates with inches

     - Precondition: value is finite
     */
    static func `in`(_ value: Double) -> AbsLength {
        AbsLength(value * Scales.in)
    }

    private init(_ ptValue: Double) {
        precondition(ptValue.isFinite)

        self.ptValue = ptValue
    }

    /// Scales for conversion
    private enum Scales {
        static let pt = 1.0
        static let mm = 2.83465
        static let cm = 28.3465
        static let `in` = 72.0
    }

    private enum InvScales {
        static let pt = 1.0 / Scales.pt
        static let mm = 1.0 / Scales.mm
        static let cm = 1.0 / Scales.cm
        static let `in` = 1.0 / Scales.in
    }
}
