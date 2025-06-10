// Copyright 2024-2025 Lie Yan

import Foundation

final class MathReflowLayoutContext: LayoutContext {

  var styleSheet: StyleSheet { textLayoutContext.styleSheet }

  private let textLayoutContext: TextLayoutContext
  private let mathLayoutContext: MathListLayoutContext

  /// The node that initiated the reflow operation.
  private let sourceNode: EquationNode

  /// Starting offset in the text layoutcontext where the math list starts.
  /// This is used to calculate the original text offset for reflowed segments.
  /// Unavailable when `isEditing` is true.
  private let textOffset: Int?

  init(
    _ textLayoutContext: TextLayoutContext,
    _ mathListLayoutContext: MathListLayoutContext,
    _ sourceNode: EquationNode,
    _ textOffset: Int? = nil
  ) {
    self.textLayoutContext = textLayoutContext
    self.mathLayoutContext = mathListLayoutContext
    self.sourceNode = sourceNode
    self.textOffset = textOffset
  }

  var layoutCursor: Int { mathLayoutContext.layoutCursor }

  func resetCursor() {
    mathLayoutContext.resetCursor()
  }

  var isEditing: Bool { mathLayoutContext.isEditing }

  func beginEditing() {
    mathLayoutContext.beginEditing()
  }

  func endEditing() {
    mathLayoutContext.endEditing()
  }

  // MARK: - Layout

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    mathLayoutContext.addParagraphStyle(source, range)
  }

  func skipBackwards(_ n: Int) {
    mathLayoutContext.skipBackwards(n)
  }

  func deleteBackwards(_ n: Int) {
    mathLayoutContext.deleteBackwards(n)
  }

  func invalidateBackwards(_ n: Int) {
    mathLayoutContext.invalidateBackwards(n)
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    mathLayoutContext.insertText(text, source)
  }

  func insertNewline(_ context: Node) {
    mathLayoutContext.insertNewline(context)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    mathLayoutContext.insertFragment(fragment, source)
  }

  // MARK: - Query

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset != nil)

    preconditionFailure()

  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(!isEditing && textOffset != nil)

    preconditionFailure()

  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(!isEditing && textOffset != nil)

    preconditionFailure()

  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(!isEditing && textOffset != nil)

    preconditionFailure()
  }

  func neighbourLineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset != nil)

    preconditionFailure()
  }
}
