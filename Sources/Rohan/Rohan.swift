// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

// "noor" for external use
let logger = Logger(subsystem: "net.satzlich.noor", category: "Noor")

extension NSRange {
  /**
   Clamp the range to another range.
   - Returns: The clamped range if both ranges are valid. Otherwise, return
    a value whose `location` equals `NSNotFound`.
   */
  func clamped(to range: NSRange) -> NSRange {
    // if one of the ranges is invalid, return an invalid range
    if self.location == NSNotFound || range.location == NSNotFound {
      return .notFound
    }
    // otherwise, do the clamping
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    let location = self.location.clamped(lowerBound, upperBound)
    let end = (self.location + self.length).clamped(lowerBound, upperBound)
    return NSRange(location: location, length: end - location)
  }

  static var notFound: NSRange { NSRange(location: NSNotFound, length: 0) }
}
