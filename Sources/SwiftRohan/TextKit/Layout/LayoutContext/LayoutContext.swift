// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
  var styleSheet: StyleSheet { get }

  // MARK: - State

  /// Cursor in the layout context
  var layoutCursor: Int { get }

  /// Reset layout cursor to the end of the layout context
  func resetCursor()

  var isEditing: Bool { get }
  func beginEditing()
  func endEditing()

  // MARK: - Paragraph Style

  /// Add paragraph style to the given range
  func addParagraphStyle(_ source: Node, _ range: Range<Int>)

  func addParagraphStyle(_ paragraphStyle: NSParagraphStyle, _ range: Range<Int>)

  // MARK: - Operations

  /// Place cursor at `layoutCursor - n`
  func skipBackwards(_ n: Int)

  /// Remove `[layoutCursor - n, layoutCursor)` and place cursor at `layoutCursor - n`
  func deleteBackwards(_ n: Int)

  /// Inform the layout context that the frames for `[layoutCursor - n, layoutCursor)`
  /// now become invalid, and place cursor at `layoutCursor - n`
  func invalidateBackwards(_ n: Int)

  /// Insert text at cursor. Cursor remains at the same location.
  func insertText<S: Collection<Character>>(_ text: S, _ source: Node)

  /// Insert newline at cursor. Cursor remains at the same location.
  func insertNewline(_ context: Node)

  /// Insert fragment at cursor. Cursor remains at the same location.
  func insertFragment(_ fragment: LayoutFragment, _ source: Node)

  // MARK: - Query

  /// Get the frame of the layout fragment at the given layout offset.
  /// - Parameters:
  ///     - layoutOffset: the layout offset to query the frame for.
  ///     - affinity: the affinity to use when querying the frame.
  /// - Note: For this function, all frame origins are placed at the **top-left corner**,
  ///     and is the position relative to the container frame's **top-left corner**.
  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame?

  /// Enumerate text segments in `layoutRange` and process by `block`.
  /// - Parameters:
  ///   - layoutRange: the range of layout offsets to enumerate.
  ///   - type: the type of segments to generate.
  ///   - options: the options to use when generating segments.
  ///   - block: the block to process each segment. The block is called with the
  ///       segment range, frame rectangle, and baseline offset. To break out of
  ///       enumeration, return **false** from the block.
  /// - Returns: false if enumeration is stopped by `block` or error, otherwise true.
  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool

  /// Pick the layout range at the given point in the layout context.
  /// - Parameter point: the point in the layout context (relative to **the top-left
  ///     corner** of layout bounds).
  /// - Returns: the result of the hit test, or `nil` if no hit. If layout range
  ///     is empty, it indicates a position between glyphs is selected.
  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult?

  /// Ray shoot from given layout offset in the given direction.
  /// - Returns: The result of the ray shoot, or `nil` if it is impossible to shoot
  ///     further in the given direction. In the case of non-nil result, property
  ///     `position` is the position of the hit point within the layout context when
  ///     `isResolved=true`; otherwise, property `position` is the position where the
  ///     ray goes outside the layout context.
  /// - Note: `position` is relative to the **top-left corner** of the layout context.
  ///     For TextLayoutContext, the origin is the **top-left corner** of the text
  ///     container. For MathLayoutContext, the origin is the **top-left corner** of
  ///     the math list.
  func rayshoot(
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult?

  /// Go from current offset in given direction and get a segment frame in the next line.
  /// - Note: We care about the vertical position of the line, horizontal position is
  ///     unused.
  func neighbourLineFrame(
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame?
}

extension LayoutContext {
  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    precondition(isEditing)
    // defeault implementation does nothing.
  }

  func addParagraphStyle(_ paragraphStyle: NSParagraphStyle, _ range: Range<Int>) {
    precondition(isEditing)
    // defeault implementation does nothing.
  }
}
