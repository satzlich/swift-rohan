// Copyright 2024-2025 Lie Yan

import Foundation

/// Reflow context aligns **layout offset** with the math layout context, while
/// aligns **coordinates** with the text layout context.
final class MathReflowLayoutContext: LayoutContext {

  var styleSheet: StyleSheet { textLayoutContext.styleSheet }

  private let textLayoutContext: TextLayoutContext
  private let mathLayoutContext: MathListLayoutContext

  /// The node that initiated the reflow operation.
  private let sourceNode: EquationNode

  /// Starting offset in the text layoutcontext where the math list starts.
  /// This is used to calculate the original text offset for reflowed segments.
  /// Invalid when `isEditing` is true as the text layout context is not finalized yet.
  private let textOffset: Int

  init(
    _ textLayoutContext: TextLayoutContext,
    _ mathListLayoutContext: MathListLayoutContext,
    _ sourceNode: EquationNode,
    _ textOffset: Int = -1
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

  /// Returns an **accessible** index for reflow segment that can answer queries
  /// over given layout offset.
  /// - Precondition: reflow segments is not empty.
  /// - Note: an index is called **accessible** if `index ∈ [0, reflowSegmentCount)`.
  private func getAccessibleIndex(
    _ layoutOffset: Int, _ affinity: TextAffinity
  ) -> Int {
    precondition(!isEditing && textOffset >= 0)
    precondition(mathLayoutContext.reflowSegmentCount > 0)

    var i = mathLayoutContext.reflowSegmentIndex(layoutOffset)
    if i == mathLayoutContext.reflowSegmentCount {
      i -= 1
    }
    else if affinity == .upstream {
      let segment = mathLayoutContext.reflowSegments[i]
      if i > 0 && segment.offsetRange.lowerBound == layoutOffset { i -= 1 }
    }
    return i
  }

  /// Returns the segment frame of the reflow segment at given index.
  /// - Parameter index: index of the reflow segment, **not** the layout offset.
  private func getReflowSegmentFrame(_ index: Int) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)
    guard index >= 0 && index < mathLayoutContext.reflowSegmentCount else { return nil }

    let nextOffset = textOffset + index + 1
    // query for downstream edge with affinity=upstream.
    guard var frame = textLayoutContext.getSegmentFrame(nextOffset, .upstream)
    else { return nil }
    frame.frame.origin.x -= mathLayoutContext.reflowSegments[index].width
    return frame
  }

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: TextAffinity
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)

    guard mathLayoutContext.reflowSegmentCount > 0 else {
      return textLayoutContext.getSegmentFrame(textOffset, affinity)
    }
    let i = getAccessibleIndex(layoutOffset, affinity)
    guard var frame = getReflowSegmentFrame(i) else { return nil }
    let segment = mathLayoutContext.reflowSegments[i]
    let index = segment.fragmentIndex(layoutOffset)
    let distance = segment.distanceThroughSegment(index)
    frame.frame.origin.x += distance
    return frame
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(!isEditing && textOffset >= 0)

    let preferUpstream = options.contains(.upstreamAffinity)

    preconditionFailure()
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(!isEditing && textOffset >= 0)
    guard mathLayoutContext.reflowSegmentCount > 0,
      let result = textLayoutContext.getLayoutRange(interactingAt: point)
    else { return nil }
    let i = result.layoutRange.lowerBound - textOffset
    guard i >= 0 && i < mathLayoutContext.reflowSegmentCount,
      let frame = getReflowSegmentFrame(i)
    else { return nil }
    var relPoint = point.relative(to: frame.frame.origin)
    let segment = mathLayoutContext.reflowSegments[i]
    relPoint.x = segment.equivalentPosition(relPoint.x)
    return mathLayoutContext.getLayoutRange(interactingAt: relPoint)
  }

  func rayshoot(
    from layoutOffset: Int, affinity: TextAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(!isEditing && textOffset >= 0)

    guard mathLayoutContext.reflowSegmentCount > 0 else {
      return textLayoutContext.rayshoot(
        from: textOffset, affinity: affinity, direction: direction)
    }
    let i = getAccessibleIndex(layoutOffset, affinity)
    guard let segmentFrame = getReflowSegmentFrame(i) else { return nil }

    let segment = mathLayoutContext.reflowSegments[i]
    let index = segment.fragmentIndex(layoutOffset)
    let distance = segment.cursorDistanceThroughSegment(index)

    let frame = segmentFrame.frame
    let x = frame.origin.x + distance
    let y = (direction == .up ? frame.minY : frame.maxY)
    return RayshootResult(CGPoint(x: x, y: y), false)
  }

  func neighbourLineFrame(
    from layoutOffset: Int, affinity: TextAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)

    guard mathLayoutContext.reflowSegmentCount > 0 else {
      return textLayoutContext.neighbourLineFrame(
        from: textOffset, affinity: affinity, direction: direction)
    }

    let i = getAccessibleIndex(layoutOffset, affinity)
    // query with affinity=downstream.
    return mathLayoutContext.neighbourLineFrame(
      from: textOffset + i, affinity: .downstream, direction: direction)
  }
}

extension MathReflowLayoutContext {

}
