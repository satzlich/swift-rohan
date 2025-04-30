// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

extension CTLine {
  /// Creates a single immutable line object from an attributed string.
  /// - Parameter attrString: The string that creates the line.
  @inline(__always)
  static func createWithAttributedString(_ attrString: NSAttributedString) -> CTLine {
    CTLineCreateWithAttributedString(attrString)
  }

  /// Draws a complete line.
  /// - Parameter context: The context into which the line is drawn.
  @inline(__always)
  func draw(_ context: CGContext) {
    CTLineDraw(self, context)
  }

  /// Calculates the image bounds for a line.
  /// - Returns: A rectangle that tightly encloses the paths of the line’s glyphs,
  ///     or, if the line or context is invalid, CGRectNull.
  @inline(__always)
  func getImageBounds(_ context: CGContext?) -> CGRect {
    CTLineGetImageBounds(self, context)
  }

  /// Calculates the typographic bounds of a line.
  /// - Returns: The typographic width of the line. If the line is invalid,
  ///     this function returns 0.
  @inline(__always)
  func getTypographicBounds(
    _ ascent: UnsafeMutablePointer<CGFloat>?,
    _ descent: UnsafeMutablePointer<CGFloat>?,
    _ leading: UnsafeMutablePointer<CGFloat>?
  ) -> Double {
    CTLineGetTypographicBounds(self, ascent, descent, leading)
  }

  /// Performs hit testing.
  /// - Parameter position: The location of the mouse click relative to the
  ///     line’s origin.
  /// - Returns: The string index for the position, or if the line does not
  ///     support string access, `kCFNotFound`. Relative to the line’s string range,
  ///     this value can be no less than the first string index and no greater
  ///     than the last string index plus 1.
  @inline(__always)
  func getStringIndex(for position: CGPoint) -> CFIndex {
    CTLineGetStringIndexForPosition(self, position)
  }

  /// Determines the graphical offset or offsets for a string index.
  /// - Parameters:
  ///   - charIndex: The string index corresponding to the desired position.
  ///   - secondaryOffset: On output, the secondary offset along the baseline
  ///     for charIndex. When a single caret is sufficient for a string index,
  ///     this value will be the same as the primary offset, which is the return
  ///     value of this function. May be NULL.
  /// - Returns: The primary offset along the baseline for charIndex, or 0.0 if
  ///     the line does not support string access.
  @inline(__always)
  func getOffset(
    for charIndex: CFIndex, _ secondaryOffset: UnsafeMutablePointer<CGFloat>?
  ) -> Double {
    CTLineGetOffsetForStringIndex(self, charIndex, secondaryOffset)
  }

  /// Enumerates caret offsets for characters in a line.
  /// - Parameter block: The block to invoke once for each logical caret edge
  ///     in the line, in left-to-right visual order. The block’s offset parameter
  ///     is relative to the line origin. The block’s `leadingEdge` parameter
  ///     specifies logical order.
  @inline(__always)
  func enumerateCaretOffsets(
    _ block: @escaping (Double, CFIndex, Bool, UnsafeMutablePointer<Bool>) -> Void
  ) {
    CTLineEnumerateCaretOffsets(self, block)
  }
}
