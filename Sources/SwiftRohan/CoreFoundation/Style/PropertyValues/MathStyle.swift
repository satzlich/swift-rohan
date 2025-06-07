// Copyright 2024-2025 Lie Yan

import Foundation

/**
 An extrinsic property of a math formula.

 # Note
 The relationship between math style and font size is as follows:

 | Math Style      | Font Size          |
 |-----------------|--------------------|
 | display, text   | text size          |
 | script          | script size        |
 | scriptScript    | scriptScript size  |
 */
public enum MathStyle: Equatable, Hashable, Codable, Sendable {
  case display
  case text
  case script
  case scriptScript
}

extension MathStyle: CaseIterable {}

extension MathStyle {
  /// Return the next math style which is larger than the current one.
  func scaleUp() -> MathStyle? {
    switch self {
    case .display, .text:
      return nil
    case .script:
      return .text
    case .scriptScript:
      return .script
    }
  }

  /// Returns the inline parallel of the current math style.
  func inlineParallel() -> MathStyle {
    switch self {
    case .display, .text:
      return .text
    case .script:
      return .script
    case .scriptScript:
      return .scriptScript
    }
  }
}
