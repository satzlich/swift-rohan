// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  /// Move caret to the next/previous location.
  /// - Returns: The new location of the caret. Nil if the given location is invalid.
  static func destinationLocation(
    for location: TextLocation, _ direction: TextSelectionNavigation.Direction,
    _ rootNode: RootNode
  ) -> TextLocation? {
    precondition([.forward, .backward].contains(direction))

    guard var trace = buildTrace_v2(for: location, rootNode) else { return nil }

    switch direction {
    case .forward:
      trace.moveForward()
      return trace.buildLocation()

    case .backward:
      trace.moveBackward()
      return trace.buildLocation()

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}
