// Copyright 2024-2025 Lie Yan

import Foundation
@_exported import RohanCommon

extension String {
    /** Returns the NSString length */
    public func nsLength() -> Int { (self as NSString).length }
}

extension Bool {
    @inlinable @inline(__always)
    var intValue: Int { self ? 1 : 0 }
}

extension Optional {
    @inlinable @inline(__always)
    var asArray: [Wrapped] { map { [$0] } ?? [] }
}
