// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
  var styleSheet: StyleSheet { get }

  // MARK: - State

  /// Cursor in the layout context
  var layoutCursor: Int { get }

  var isEditing: Bool { get }
  func beginEditing()
  func endEditing()

  // MARK: - Operations

  /// Add paragraph style to the range `[layoutCursor, _ + length)`
  func addParagraphStyle(_ source: Node, _ length: Int)

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

  /// Get the frame of the layout fragment at the given layout offset
  /// - Note: For this function, all frame origins are placed at the top-left corner,
  ///     and is the position relative to the container frame's top-left corner.
  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame?

  /// Enumerate text segments in `layoutRange` and process by `block`.
  /// - Returns: false if enumeration is interrupted by `block`, otherwise true.
  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool

  /// Pick the layout range at the given point in the layout context.
  /// - Parameter point: the point in the layout context (relative to __the top-left
  ///     corner__ of layout bounds).
  /// - Returns: the result of the hit test, or `nil` if no hit. If layout range
  ///     is empty, it indicates a position between glyphs is selected.
  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult?

  /// Ray shoot from given layout offset in the given direction.
  /// - Returns: The result of the ray shoot, or `nil` if it is impossible to shoot
  ///     further in the given direction. In the case of non-nil result, property
  ///     `position` is the position of the hit point within the layout context when
  ///     `isResolved=true`; otherwise, property `position` is the position where the
  ///     ray goes outside the layout context.
  /// - Note: `position` is relative to the __top-left corner__ of the layout context.
  ///     For TextLayoutContext, the origin is the __top-left corner__ of the text
  ///     container. For MathLayoutContext, the origin is the __top-left corner__ of
  ///     the math list.
  func rayshoot(
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult?
}
