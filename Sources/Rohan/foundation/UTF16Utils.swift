// Copyright 2024 Lie Yan

import Foundation

enum UTF16Utils {
    static func isHighSurrogate(_ scalar: UInt16) -> Bool {
        (0xD800 ... 0xDBFF) ~= scalar
    }

    static func isLowSurrogate(_ scalar: UInt16) -> Bool {
        (0xDC00 ... 0xDFFF) ~= scalar
    }

    static func isSurrogate(_ scalar: UInt16) -> Bool {
        isHighSurrogate(scalar) || isLowSurrogate(scalar)
    }

    static func combineSurrogates(_ high: UInt16, _ low: UInt16) -> UInt32 {
        (UInt32(high) - 0xD800) * 0x400 + (UInt32(low) - 0xDC00) + 0x10000
    }
}
