// Copyright 2024-2025 Lie Yan

import Foundation
@_exported import RohanCommon

extension String {
    /** Returns the NSString length */
    @inlinable @inline(__always)
    func nsLength() -> Int { (self as NSString).length }
}

extension Bool {
    @inlinable @inline(__always)
    var intValue: Int { self ? 1 : 0 }
}

extension Optional {
    @inlinable @inline(__always)
    var asArray: [Wrapped] { map { [$0] } ?? [] }
}

enum Characters {
    /** zero-width space */
    static var ZWSP: Character { "\u{200B}" }
    static var LineSeparator: Character { "\u{2028}" }
}
