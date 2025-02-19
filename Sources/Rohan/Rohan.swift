// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

let logger = Logger(subsystem: "net.satzlich.rohan", category: "Rohan")

extension Collection {
  @inlinable @inline(__always)
  func getOnlyElement() -> Element? {
    self.count == 1 ? self[startIndex] : nil
  }
}

extension Bool {
  @inlinable @inline(__always)
  var intValue: Int { self ? 1 : 0 }
}

extension NSFont {
  /** Initializes a flipped font */
  convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
    let descriptor = NSFontDescriptor(name: name, size: size)
    self.init(descriptor: descriptor, size: size, isFlipped: isFlipped)
  }

  private convenience init?(descriptor: NSFontDescriptor, size: CGFloat, isFlipped: Bool) {
    guard isFlipped else { self.init(descriptor: descriptor, size: size); return }
    let textTransform = AffineTransform(scaleByX: size, byY: -size)
    self.init(descriptor: descriptor, textTransform: textTransform)
  }
}

extension NSRange {
    public func clamped(to range: NSRange) -> NSRange {
        if location == NSNotFound || range.location == NSNotFound {
            return NSRange(location: NSNotFound, length: 0)
        }
        let location_ = Swift.max(location, range.location)
        let end_ = Swift.min(location + length, range.location + range.length)
        return NSRange(location: location_, length: end_ - location_)
    }
}

extension String {
  /** Returns true if the start of the string is combining */
  func hasCombiningStart() -> Bool {
    !isEmpty && (" " + prefix(1)).count == 1
  }
}
