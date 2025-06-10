// Copyright 2024-2025 Lie Yan

import Foundation

final class MathReflowLayoutContext: LayoutContext {

  var styleSheet: StyleSheet { textLayoutContext.styleSheet }

  private let textLayoutContext: TextLayoutContext
  private let mathListLayoutContext: MathListLayoutContext

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
    self.mathListLayoutContext = mathListLayoutContext
    self.sourceNode = sourceNode
    self.textOffset = textOffset
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
    _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset != nil)
    let reflowedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.getSegmentFrame(reflowedOffset, affinity)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(!isEditing && textOffset != nil)
    let reflowedRange = reflowedRange(for: layoutRange)
    return textLayoutContext.enumerateTextSegments(
      reflowedRange, type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(!isEditing && textOffset != nil)
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
    precondition(!isEditing && textOffset != nil)
    let reflowedRange = reflowedOffset(for: layoutOffset)
    return textLayoutContext.rayshoot(
      from: reflowedRange, affinity: affinity, direction: direction)
  }

  func neighbourLineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset != nil)
    let reflowedOffset = reflowedOffset(for: layoutOffset)
    return textLayoutContext.neighbourLineFrame(
      from: reflowedOffset, affinity: affinity, direction: direction)
  }

  // MARK: - Reflow

  private func reflowedOffset(for layoutOffset: Int) -> Int {
    precondition(!isEditing && textOffset != nil)
    return textOffset! + mathListLayoutContext.reflowedOffset(for: layoutOffset)
  }

  private func reflowedRange(for layoutRange: Range<Int>) -> Range<Int> {
    precondition(!isEditing && textOffset != nil)
    let start = reflowedOffset(for: layoutRange.lowerBound)
    let end = reflowedOffset(for: layoutRange.upperBound)
    return start..<end
  }

  private func originalOffset(for reflowedOffset: Int) -> Int {
    precondition(!isEditing && textOffset != nil)
    return mathListLayoutContext.originalOffset(for: reflowedOffset - textOffset!)
  }

  private func originalRange(for reflowedRange: Range<Int>) -> Range<Int> {
    precondition(!isEditing && textOffset != nil)
    let start = originalOffset(for: reflowedRange.lowerBound)
    let end = originalOffset(for: reflowedRange.upperBound)
    return start..<end
  }

  /// Clear the reflowed segments from the layout context.
  private func clearReflow() {
    // Implementation: remove previous reflowed segments
    let n = mathListLayoutContext.reflowedLength
    textLayoutContext.deleteBackwards(n)
  }

  /// Commit the reflow operation.
  private func commitReflow() {
    // Implementation: insert reflowed segments into the layout context
    let content = mathListLayoutContext.reflowedContent()

    #if DEBUG
    var sum = 0
    #endif

    for segment in content.reversed() {
      switch segment {
      case .fragment(let fragment):
        #if DEBUG
        assert(fragment.layoutLength >= 1)
        sum += 1
        #endif
        textLayoutContext.insertFragment(fragment, sourceNode)

      case .string(let string):
        #if DEBUG
        sum += string.length
        #endif
        textLayoutContext.insertText(string, sourceNode)
      }
    }

    #if DEBUG
    assert(sum == mathListLayoutContext.reflowedLength)
    #endif
  }
}
