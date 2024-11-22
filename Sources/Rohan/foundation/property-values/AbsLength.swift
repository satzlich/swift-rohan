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
    let ptValue: Double

    var mmValue: Double {
        ptValue * InvScales.mm
    }

    var cmValue: Double {
        ptValue * InvScales.cm
    }

    var picaValue: Double {
        ptValue * InvScales.pica
    }

    var inValue: Double {
        ptValue * InvScales.`in`
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

    private init(_ ptValue: Double) {
        precondition(ptValue.isFinite)

        self.ptValue = ptValue
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
