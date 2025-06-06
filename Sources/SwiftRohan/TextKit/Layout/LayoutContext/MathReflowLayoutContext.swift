// Copyright 2024-2025 Lie Yan

import Foundation

final class MathReflowLayoutContext: LayoutContext {

  var styleSheet: StyleSheet { textLayoutContext.styleSheet }

  let textLayoutContext: TextLayoutContext
  let mathListLayoutContext: MathListLayoutContext

  init(
    _ textLayoutContext: TextLayoutContext,
    _ mathListLayoutContext: MathListLayoutContext
  ) {
    self.textLayoutContext = textLayoutContext
    self.mathListLayoutContext = mathListLayoutContext
  }

  var layoutCursor: Int { mathListLayoutContext.layoutCursor }

  func resetCursor() {
    mathListLayoutContext.resetCursor()
  }

  var isEditing: Bool { mathListLayoutContext.isEditing }

  func beginEditing() {
    beginReflow()
    mathListLayoutContext.beginEditing()
  }

  func endEditing() {
    mathListLayoutContext.endEditing()
    commitReflow()
  }

  // MARK: - Layout

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    precondition(isEditing)
    mathListLayoutContext.addParagraphStyle(source, range)
  }

  func skipBackwards(_ n: Int) {
    precondition(isEditing)
    mathListLayoutContext.skipBackwards(n)
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing)
    mathListLayoutContext.deleteBackwards(n)
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing)
    mathListLayoutContext.invalidateBackwards(n)
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    mathListLayoutContext.insertText(text, source)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing)
    mathListLayoutContext.insertNewline(context)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    mathListLayoutContext.insertFragment(fragment, source)
  }

  // MARK: - Query

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    precondition(!isEditing)
    let reflowedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.getSegmentFrame(for: reflowedOffset, affinity, node)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(!isEditing)
    let reflowedRange = reflowedRange(for: layoutRange)
    return textLayoutContext.enumerateTextSegments(
      reflowedRange, type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(!isEditing)
    if let result = textLayoutContext.getLayoutRange(interactingAt: point) {
      let originalRange = originalRange(for: result.layoutRange)
      return result.with(layoutRange: originalRange)
    }
    else {
      return nil
    }
  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(!isEditing)
    let reflowedRange = reflowedOffset(for: layoutOffset)
    return textLayoutContext.rayshoot(
      from: reflowedRange, affinity: affinity, direction: direction)
  }

  func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    precondition(!isEditing)
    let reflowedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.lineFrame(
      from: reflowedOffset, affinity: affinity, direction: direction)
  }

  // MARK: - Reflow

  private func reflowedOffset(for layoutOffset: Int) -> Int {
    preconditionFailure()
  }

  private func reflowedRange(for layoutRange: Range<Int>) -> Range<Int> {
    preconditionFailure()
  }

  private func originalOffset(for reflowedOffset: Int) -> Int {
    preconditionFailure()
  }

  private func originalRange(for reflowedRange: Range<Int>) -> Range<Int> {
    preconditionFailure()
  }

  /// Begin a reflow operation.
  private func beginReflow() {
    // Implementation: remove previous reflowed segments
    preconditionFailure()
  }

  /// Commit the reflow operation.
  private func commitReflow() {
    // Implementation: insert reflowed segments into the layout context
    preconditionFailure()
  }
}
