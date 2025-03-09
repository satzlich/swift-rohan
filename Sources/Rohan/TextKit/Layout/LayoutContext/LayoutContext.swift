// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

protocol LayoutContext {
  var styleSheet: StyleSheet { get }

  // MARK: - State

  /** Cursor in the layout context */
  var layoutCursor: Int { get }

  var isEditing: Bool { get }
  func beginEditing()
  func endEditing()

  // MARK: - Operations

  /** Move cursor backwards */
  func skipBackwards(_ n: Int)
  /** Remove `[layoutCursor-n, layoutCursor)` and move cursor backwards */
  func deleteBackwards(_ n: Int)
  /** Inform the layout context that the frames for `[layoutCursor-n, layoutCursor)`
   now become invalid, and move cursor backwards */
  func invalidateBackwards(_ n: Int)

  /** Insert text at cursor. Cursor remains at the same location. */
  func insertText<S>(_ text: S, _ source: Node) where S: Collection, S.Element == Character
  /** Insert newline at cursor. Cursor remains at the same location. */
  func insertNewline(_ context: Node)
  /** Insert fragment at cursor. Cursor remains at the same location. */
  func insertFragment(_ fragment: LayoutFragment, _ source: Node)

  // MARK: - Query

  /**
   Get the frame of the layout fragment at the given layout offset
   - Note: For this function, all frame origins are placed at the top-left corner,
   and is the position relative to the container frame's top-left corner.
   */
  func getSegmentFrame(for layoutOffset: Int) -> SegmentFrame?

  /**
   Enumerate text segments in `layoutRange` and process by `block`.
   - Returns: `true` if enumeration is completed, `false` if enumeration is interrupted.
   */
  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool

  /** Return the layout range of the glyph selected by the point using character
   granularity, and fraction of distance from upstream edge of glyph. Or `nil` if
   no hit.
   - Note: If layout range is empty, then a position between glyphs is selected.
   - Note: `point` is relative to the top-left corner of layout bounds.
   */
  func getLayoutRange(interactingAt point: CGPoint) -> (Range<Int>, Double)?

  /**
   Ray shoot from given layout offset in the given direction.
   - Returns: The result of the ray shoot, or `nil` if it is impossible to shoot
    further in the given direction. In the case of a hit where the `hit` property
    is set to `true`, the `position` property is the position of the hit point
    within the layout context. Otherwise, the `position` property is the position
    of the point where the ray goes outside the layout context.
   - Note: `position` is relative to the __top-left corner__ of the layout context.
    For TextLayoutContext, the origin is the __top-left corner__ of the text container.
    For MathLayoutContext, the origin is the __top-left corner__ of the math list.
   */
  func rayshoot(
    from layoutOffset: Int, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult?
}
