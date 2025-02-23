// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

let logger = Logger(subsystem: "net.satzlich.rohan", category: "Rohan")

extension Bool {
  var intValue: Int { self ? 1 : 0 }
}

extension Collection {
  func getOnlyElement() -> Element? {
    self.count == 1 ? self[startIndex] : nil
  }
}

extension NSFont {
  convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
    guard isFlipped else { self.init(name: name, size: size); return }
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
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    let location = self.location.clamped(lowerBound, upperBound)
    let end = (self.location + self.length).clamped(lowerBound, upperBound)
    return NSRange(location: location, length: end - location)
  }
}
