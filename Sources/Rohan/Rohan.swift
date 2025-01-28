// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

let logger = Logger(subsystem: "net.satzlich.rohan", category: "Rohan")

extension Bool {
    @inlinable @inline(__always)
    var intValue: Int { self ? 1 : 0 }
}

extension NSFont {
    /** Initializes a flipped font */
    convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
        guard isFlipped else { self.init(name: name, size: size); return }

        let descriptor = NSFontDescriptor(name: name, size: size)
        let textTransform = AffineTransform(scaleByX: size, byY: -size)
        self.init(descriptor: descriptor, textTransform: textTransform)
    }
}

extension Optional {
    @inlinable @inline(__always)
    var asArray: [Wrapped] { map { [$0] } ?? [] }
}

extension String {
    /** Returns the NSString length */
    @inlinable @inline(__always)
    func lengthAsNSString() -> Int { (self as NSString).length }
}
