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

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    textLayoutContext.getSegmentFrame(for: layoutOffset, affinity, node)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    textLayoutContext.enumerateTextSegments(
      layoutRange, type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    textLayoutContext.getLayoutRange(interactingAt: point)
  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    textLayoutContext.rayshoot(
      from: layoutOffset, affinity: affinity, direction: direction)
  }

  func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    textLayoutContext.lineFrame(
      from: layoutOffset, affinity: affinity, direction: direction)
  }
}
