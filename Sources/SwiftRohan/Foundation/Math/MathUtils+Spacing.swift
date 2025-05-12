// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import UnicodeMathClass

extension MathUtils {
  /// Resolve __running__ math class for fragments
  static func resolveMathClass<S>(_ classes: S) -> [MathClass]
  where S: BidirectionalCollection<MathClass> {
    guard !classes.isEmpty else { return [] }

    var resolved = [MathClass]()
    resolved.reserveCapacity(classes.count)

    var previous: MathClass?

    classes.adjacentPairs().forEach { current, next in
      if current == .Vary || current == .Binary {
        if matchPrevious(previous) || matchNext(next) {
          previous = .Normal
          resolved.append(.Normal)
        }
        else {
          previous = .Binary
          resolved.append(.Binary)
        }
      }
      else {
        previous = current
        resolved.append(current)
      }
    }

    do {
      let last = classes.last!
      if last == .Vary || last == .Binary {
        resolved.append(.Normal)
      }
      else {
        resolved.append(last)
      }
    }

    return resolved

    // Helper

    // The cases that enforce Vary to Normal
    func matchPrevious(_ clazz: MathClass?) -> Bool {
      guard let clazz = clazz else { return true }
      return [.Normal, .Alphabetic, .Closing, .Fence].contains(clazz) == false
    }

    // The cases that enforce Vary to Normal
    func matchNext(_ clazz: MathClass) -> Bool {
      [.Relation, .Closing, .Punctuation].contains(clazz)
    }
  }

  /// Returns the spacing between two math classes. Nil indicates zero spacing.
  /// - Note: The implementation is derived from the TeXbook and source code
  ///     of Typst. But the exact rules are slightly different from either.
  static func resolveSpacing(
    _ lhs: MathClass, _ rhs: MathClass, _ style: MathStyle
  ) -> Em? {
    // match non-script styles
    func matches(_ a: MathStyle) -> Bool { a == .display || a == .text }

    switch (lhs, rhs) {
    // No spacing before punctuation; thin spacing after punctuation, unless
    // in script size.
    case (_, .Punctuation): return .none
    case (.Punctuation, _): return matches(style) ? .thin : .none

    // No spacing after opening delimiters and before closing delimiters.
    case (.Opening, _), (_, .Closing): return .none

    // Thick spacing around relations, unless followed by another relation
    // or in script size.
    case (.Relation, .Relation): return .none
    case (.Relation, _), (_, .Relation): return matches(style) ? .thick : .none

    // Medium spacing around binary operators, unless in script size.
    case (.Binary, _), (_, .Binary): return matches(style) ? .medium : .none

    // Thin spacing around large operators, unless to the left of
    // an opening delimiter. TeXBook, p170
    case (.Large, .Opening), (.Large, .Fence): return .none
    case (.Large, _), (_, .Large): return .thin

    default:
      return .none
    }
  }
}
