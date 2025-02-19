// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

let logger = Logger(subsystem: "net.satzlich.rohan", category: "Rohan")

extension Collection {
  func getOnlyElement() -> Element? {
    self.count == 1 ? self[startIndex] : nil
  }
}

extension Bool {
  var intValue: Int { self ? 1 : 0 }
}

extension String {
  var stringLength: Int { utf16.count }
}

extension NSFont {
  convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
    guard isFlipped else {
      self.init(name: name, size: size)
      return
    }
    let descriptor = NSFontDescriptor(name: name, size: size)
    let textTransform = AffineTransform(scaleByX: size, byY: -size)
    self.init(descriptor: descriptor, textTransform: textTransform)
  }
}

extension NSRange {
  func clamped(to range: NSRange) -> NSRange {
    if self.location == NSNotFound || range.location == NSNotFound {
      return NSRange(location: NSNotFound, length: 0)
    }
    let location = Swift.max(self.location, range.location)
    let end = Swift.min(self.location + self.length, range.location + range.length)
    return NSRange(location: location, length: end - location)
  }
}
