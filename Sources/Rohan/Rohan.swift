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

extension Double {
  @inlinable @inline(__always)

  func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    return String(format: "%.\(precision)f", self)
  }
}

extension NSFont {
  /** Initializes a flipped font */
  convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
    let descriptor = NSFontDescriptor(name: name, size: size)
    self.init(descriptor: descriptor, size: size, isFlipped: isFlipped)
  }

  convenience init?(descriptor: NSFontDescriptor, size: CGFloat, isFlipped: Bool) {
    guard isFlipped else { self.init(descriptor: descriptor, size: size); return }
    let textTransform = AffineTransform(scaleByX: size, byY: -size)
    self.init(descriptor: descriptor, textTransform: textTransform)
  }
}

extension String {
  /** Returns true if the start of the string is combining */
  func hasCombiningStart() -> Bool {
    !isEmpty && (" " + prefix(1)).count == 1
  }
}
