// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import OSLog
@_exported import RohanCommon

let logger = Logger(subsystem: "net.satzlich.rohan", category: "Rohan")

extension NSRange {
  /**
   Clamp the range to another range.

   If any of the ranges is invalid, return an invalid range. Otherwise, return
   the clamped range.
   */
  func clamped(to range: NSRange) -> NSRange {
    // if one of the ranges is invalid, return an invalid range
    if self.location == NSNotFound || range.location == NSNotFound {
      return NSRange(location: NSNotFound, length: 0)
    }
    // otherwise, do the clamping
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    let location = self.location.clamped(lowerBound, upperBound)
    let end = (self.location + self.length).clamped(lowerBound, upperBound)
    return NSRange(location: location, length: end - location)
  }
}
