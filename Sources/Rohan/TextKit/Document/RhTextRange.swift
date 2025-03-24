// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Text range.

 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextRange``.
 */
@frozen
public struct RhTextRange: Equatable, Hashable, CustomDebugStringConvertible {
  public let location: TextLocation
  public let endLocation: TextLocation

  public var isEmpty: Bool { location.compare(endLocation) == .orderedSame }

  public init(_ location: TextLocation) {
    self.location = location
    self.endLocation = location
  }

  public init?(_ location: TextLocation, _ end: TextLocation) {
    guard let comparisonResult = location.compare(end),
      comparisonResult != .orderedDescending
    else { return nil }

    self.location = location
    self.endLocation = end
  }

  public init?(unordered location: TextLocation, _ end: TextLocation) {
    guard let comparisonResult = location.compare(end) else { return nil }
    if comparisonResult == .orderedDescending {
      self.location = end
      self.endLocation = location
    }
    else {
      self.location = location
      self.endLocation = end
    }
  }

  public var debugDescription: String {
    self.isEmpty ? "\(location)" : "\(location)..<\(endLocation)"
  }

  /** Concate a prefix to a text range. */
  static func concate(_ prefix: [RohanIndex], _ range: RhTextRange) -> RhTextRange {
    func compose(_ location: TextLocation) -> TextLocation {
      let indices = prefix + location.indices
      return TextLocation(indices, location.offset)
    }
    let location = compose(range.location)
    let endLocation = compose(range.endLocation)
    return RhTextRange(location, endLocation)!
  }
}
