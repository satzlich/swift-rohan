// Copyright 2024 Lie Yan

import Foundation

enum UTF16Utils {
    public static func isHighSurrogate(_ codeUnit: UInt16) -> Bool {
        (0xD800 ... 0xDBFF) ~= codeUnit
    }

    public static func isLowSurrogate(_ codeUnit: UInt16) -> Bool {
        (0xDC00 ... 0xDFFF) ~= codeUnit
    }

    public static func isSurrogate(_ codeUnit: UInt16) -> Bool {
        isHighSurrogate(codeUnit) || isLowSurrogate(codeUnit)
    }

    public static func combineSurrogates(_ high: UInt16, _ low: UInt16) -> UInt32 {
        (UInt32(high) - 0xD800) * 0x400 + (UInt32(low) - 0xDC00) + 0x10000
    }
}
