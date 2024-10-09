// Copyright 2024 Lie Yan

import Foundation

extension UTF16 {
    public static func isSurrogate(_ x: UInt16) -> Bool {
        UTF16.isLeadSurrogate(x) || UTF16.isTrailSurrogate(x)
    }

    public static func combineSurrogates(_ lead: UInt16, _ trail: UInt16) -> UInt32 {
        (UInt32(lead) - 0xD800) * 0x400 + (UInt32(trail) - 0xDC00) + 0x10000
    }
}
