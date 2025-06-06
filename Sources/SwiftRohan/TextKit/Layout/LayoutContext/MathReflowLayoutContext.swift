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
    mathListLayoutContext.beginEditing()
  }

  func endEditing() {
    mathListLayoutContext.endEditing()
  }

  // MARK: - Layout

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    mathListLayoutContext.addParagraphStyle(source, range)
  }

  func skipBackwards(_ n: Int) {
    mathListLayoutContext.skipBackwards(n)
  }

  func deleteBackwards(_ n: Int) {
    mathListLayoutContext.deleteBackwards(n)
  }

  func invalidateBackwards(_ n: Int) {
    mathListLayoutContext.invalidateBackwards(n)
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    mathListLayoutContext.insertText(text, source)
  }

  func insertNewline(_ context: Node) {
    mathListLayoutContext.insertNewline(context)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    mathListLayoutContext.insertFragment(fragment, source)
  }

  // MARK: - Query

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

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    let convertedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.getSegmentFrame(for: convertedOffset, affinity, node)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let convertedRange = reflowedRange(for: layoutRange)
    return textLayoutContext.enumerateTextSegments(
      convertedRange, type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    if let result = textLayoutContext.getLayoutRange(interactingAt: point) {
      let restoredRange = originalRange(for: result.layoutRange)
      return result.with(layoutRange: restoredRange)
    }
    else {
      return nil
    }
  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    let convertedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.rayshoot(
      from: convertedOffset, affinity: affinity, direction: direction)
  }

  func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    let convertedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.lineFrame(
      from: convertedOffset, affinity: affinity, direction: direction)
  }
}
