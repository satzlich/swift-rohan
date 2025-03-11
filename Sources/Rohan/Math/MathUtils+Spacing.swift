// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import UnicodeMathClass

extension MathUtils {
  /** Resolve __running__ math class for fragments */
  static func resolveMathClass<S>(_ classes: S) -> [MathClass]
  where S: Sequence, S.Element == MathClass {
    var last: MathClass?

    return classes.map { clazz in
      if clazz == .Vary,
        [.Normal, .Alphabetic, .Closing, .Fence].contains(last)
      {
        last = .Binary
        return .Binary
      }
      else {
        last = clazz
        return clazz
      }
    }
  }

  /**
   Returns the spacing between two math classes. Nil indicates zero spacing.
   - Note: The implementation is derived from the TeXbook and source code of Typst.
   But the exact rules are slightly different from either.
   */
  static func resolveSpacing(
    _ lhs: MathClass, _ rhs: MathClass, _ style: MathStyle
  ) -> Em? {
    // match non-script styles
    func matches(_ a: MathStyle) -> Bool { a == .display || a == .text }

    switch (lhs, rhs) {
    /* No spacing before punctuation; thin spacing after punctuation, unless
         in script size. */
    case (_, .Punctuation):
      return .none
    case (.Punctuation, _):
      return matches(style) ? .thin : .none

    /* No spacing after opening delimiters and before closing delimiters. */
    case (.Opening, _), (_, .Closing):
      return .none

    /* Thick spacing around relations, unless followed by another relation
         or in script size. */
    case (.Relation, .Relation):
      return .none
    case (.Relation, _), (_, .Relation):
      return matches(style) ? .thick : .none

    /* Medium spacing around binary operators, unless in script size. */
    case (.Binary, _), (_, .Binary):
      return matches(style) ? .medium : .none

    /* Thin spacing around large operators, unless to the left of
         an opening delimiter. TeXBook, p170 */
    case (.Large, .Opening), (.Large, .Fence):
      return .none
    case (.Large, _), (_, .Large):
      return matches(style) ? .thin : .none

    default:
      return .none
    }
  }
}
