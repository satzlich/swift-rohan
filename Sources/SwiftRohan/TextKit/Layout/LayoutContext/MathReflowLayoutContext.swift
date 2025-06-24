// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SatzAlgorithms

/// Reflow context aligns **layout offset** with the math layout context, while
/// aligns **coordinates** with the text layout context.
final class MathReflowLayoutContext: LayoutContext {

  var styleSheet: StyleSheet { textLayoutContext.styleSheet }

  private let textLayoutContext: TextLayoutContext
  internal let mathLayoutContext: MathListLayoutContext
  private var mathList: MathListLayoutFragment { mathLayoutContext.layoutFragment }

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

  func resetCursorForForwardEditing() {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  var isEditing: Bool { mathLayoutContext.isEditing }

  func beginEditing() {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func endEditing() {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  // MARK: - Edit

  func skipForward(_ n: Int) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func deleteForward(_ n: Int) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func invalidateForward(_ n: Int) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func insertTextForward(_ text: some Collection<Character>, _ source: Node) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func insertNewlineForward(_ context: Node) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func insertFragmentForward(_ fragment: any LayoutFragment, _ source: Node) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  // MARK: - Query

  /// Returns an **accessible** index for reflow segment that can answer queries
  /// over given layout offset.
  /// - Precondition: reflow segments is not empty.
  /// - Note: an index is called **accessible** if `index ∈ [0, reflowSegmentCount)`.
  private func getAccessibleIndex(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> Int {
    precondition(!isEditing && textOffset >= 0)
    precondition(mathList.reflowSegmentCount > 0)

    var i = mathList.reflowSegmentIndex(containing: layoutOffset)
    if i == mathList.reflowSegmentCount {
      i -= 1
    }
    else if affinity == .upstream {
      let segment = mathList.reflowSegments[i]
      if i > 0 && segment.offsetRange.lowerBound == layoutOffset { i -= 1 }
    }
    return i
  }

  /// Returns the segment frame of the reflow segment at given index.
  /// - Parameter index: index of the reflow segment, **not** the layout offset.
  private func getReflowSegmentFrame(_ index: Int) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)
    guard index >= 0 && index < mathList.reflowSegmentCount else { return nil }

    let nextOffset = textOffset + index + 1
    // query for downstream edge with affinity=upstream.
    guard var frame = textLayoutContext.getSegmentFrame(nextOffset, .upstream)
    else { return nil }
    // subtracting the width to obtain the upstream edge.
    frame.frame.origin.x -= mathList.reflowSegments[index].width
    return frame
  }

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)

    guard mathList.reflowSegmentCount > 0 else {
      return textLayoutContext.getSegmentFrame(textOffset, affinity)
    }
    let i = getAccessibleIndex(layoutOffset, affinity)
    guard var frame = getReflowSegmentFrame(i) else { return nil }
    let segment = mathList.reflowSegments[i]

    // compute distance from the fragment edge to segment upstream edge.
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
    // check precondition of `enumerateSubrange()`.
    let count = mathList.reflowSegmentCount
    guard count > 0,
      layoutRange.lowerBound >= 0,
      layoutRange.upperBound <= mathList.contentLayoutLength
    else { return false }

    var cachedArray = ReflowSegmentArray(textLayoutContext, textOffset, count: count)
    let index = cachedArray.splitPoint()

    if index == count {
      return enumerateSubrange(layoutRange, type: type, options: options, using: block)
    }
    let k = mathList.reflowSegments[index].offsetRange.lowerBound
    if k <= layoutRange.lowerBound || k >= layoutRange.upperBound {
      return enumerateSubrange(layoutRange, type: type, options: options, using: block)
    }
    // split the range into two parts, one before the split point and one after.
    let beforeRange = layoutRange.lowerBound..<k
    let afterRange = k..<layoutRange.upperBound
    var shouldContinue = true
    shouldContinue = enumerateSubrange(
      beforeRange, type: type, options: options, using: block)
    if shouldContinue {
      shouldContinue = enumerateSubrange(
        afterRange, type: type, options: options, using: block)
    }
    return shouldContinue
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(!isEditing && textOffset >= 0)
    guard mathList.reflowSegmentCount > 0,
      let result = textLayoutContext.getLayoutRange(interactingAt: point)
    else { return nil }
    let i = result.layoutRange.lowerBound - textOffset
    guard i >= 0 && i < mathList.reflowSegmentCount,
      let frame = getReflowSegmentFrame(i)
    else { return nil }
    let relPoint = point.relative(to: frame.frame.origin)
    let segment = mathList.reflowSegments[i]
    if relPoint.x < segment.upstream {
      let offset = segment.offsetRange.lowerBound
      return PickingResult(offset..<offset, 0, .downstream)
    }
    else if relPoint.x > segment.width {
      let offset = segment.offsetRange.upperBound
      return PickingResult(offset..<offset, 0, .upstream)
    }
    else {
      let x = segment.equivalentPosition(relPoint.x)
      return mathLayoutContext.getLayoutRange(interactingAt: relPoint.with(x: x))
        .map { $0.with(affinity: result.affinity) }
    }
  }

  func rayshoot(
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(!isEditing && textOffset >= 0)

    guard mathList.reflowSegmentCount > 0 else {
      return textLayoutContext.rayshoot(
        from: textOffset, affinity: affinity, direction: direction)
    }
    let i = getAccessibleIndex(layoutOffset, affinity)
    guard let segmentFrame = getReflowSegmentFrame(i) else { return nil }

    let segment = mathList.reflowSegments[i]
    let index = segment.fragmentIndex(layoutOffset)
    let distance = segment.cursorDistanceThroughSegment(index)

    let frame = segmentFrame.frame
    let x = frame.origin.x + distance
    let y = (direction == .up ? frame.minY : frame.maxY)
    return RayshootResult(CGPoint(x: x, y: y), false)
  }

  func neighbourLineFrame(
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    precondition(!isEditing && textOffset >= 0)

    guard mathList.reflowSegmentCount > 0 else {
      return textLayoutContext.neighbourLineFrame(
        from: textOffset, affinity: affinity, direction: direction)
    }

    let i = getAccessibleIndex(layoutOffset, affinity)
    // query with affinity=downstream.
    return textLayoutContext.neighbourLineFrame(
      from: textOffset + i, affinity: .downstream, direction: direction)
  }

  // MARK: - Enumerate Segments

  private func enumerateSubrange(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(!isEditing && textOffset >= 0)
    precondition(mathList.reflowSegmentCount > 0)
    precondition(layoutRange.lowerBound >= 0)
    precondition(layoutRange.upperBound <= mathList.contentLayoutLength)

    guard let indexRange = mathList.indexRange(matching: layoutRange)
    else { return false }

    let (cursorAscent, cursorDescent) =
      mathList.cursorHeight(indexRange, mathLayoutContext.mathContext.cursorHeight())

    func localBlock(
      _ segmentRange: Range<Int>?, _ frame: CGRect, _ baseline: CGFloat
    ) -> Bool {
      let original = SegmentFrame(frame, baseline)
      let recomposed =
        SegmentFrame.recompose(original, ascent: cursorAscent, descent: cursorDescent)
      return block(segmentRange, recomposed.frame, recomposed.baselinePosition)
    }

    let affinity: SelectionAffinity =
      options.contains(.upstreamAffinity) ? .upstream : .downstream

    // alias
    let segments = mathList.reflowSegments
    let segmentCount = segments.count

    // iteration
    let endOffset = layoutRange.upperBound

    enum State { case initial, next, final, exit }
    var state: State = .initial
    var offset = layoutRange.lowerBound
    var i = getAccessibleIndex(offset, affinity)
    var shouldContinue = true

    while state != .exit {
      switch state {
      case .initial:
        let segment = segments[i]
        assert(offset >= segment.offsetRange.lowerBound)
        // the upstream edge of the segment meets the offset.
        if offset == segment.offsetRange.lowerBound {
          // process in the next state.
          state = .next
        }
        else {
          guard var frame = getReflowSegmentFrame(i) else { return false }
          let i0 = segment.fragmentIndex(offset)
          let d0 = segment.cursorDistanceThroughSegment(i0)
          frame.frame.origin.x += d0
          // the range is empty.
          if offset == endOffset {
            shouldContinue = localBlock(nil, frame.frame, frame.baselinePosition)
            // no more segments, end the loop.
            state = .exit
          }
          // the range is nonempty, and ends in this segment.
          else if endOffset <= segment.offsetRange.upperBound {
            let i1 = segment.fragmentIndex(endOffset)
            let d1 = segment.cursorDistanceThroughSegment(i1)
            frame.frame.size.width = d1 - d0
            shouldContinue = localBlock(nil, frame.frame, frame.baselinePosition)
            // no more segments, end the loop.
            state = .exit
          }
          // the range is nonempty, and spans to the next segment.
          else {
            let i1 = segment.fragmentIndex(segment.offsetRange.upperBound)
            let d1 = segment.cursorDistanceThroughSegment(i1)
            frame.frame.size.width = d1 - d0
            shouldContinue = localBlock(nil, frame.frame, frame.baselinePosition)
            // prepare state for next round.
            if shouldContinue,
              i + 1 < segmentCount
            {
              offset = segment.offsetRange.upperBound
              i += 1
              state = .next
            }
            else {
              // no more segments, end the loop.
              state = .exit
            }
          }
        }

      case .next:
        assert(offset == segments[i].offsetRange.lowerBound)

        guard segments[i].offsetRange.upperBound <= endOffset
        else {
          // if there is no entire segment to process, transition to final state.
          state = .final
          continue
        }

        var j = i
        // determine the last index which is entire.
        while j + 1 < segmentCount {
          if segments[j + 1].offsetRange.upperBound <= endOffset {
            j += 1
          }
          else {
            break
          }
        }
        let range = textOffset + i..<textOffset + j + 1
        shouldContinue = textLayoutContext.enumerateTextSegments(
          range, type: type, options: options, using: localBlock)
        // prepare state for next round.
        if shouldContinue,
          j + 1 < segmentCount
        {
          i = j + 1
          offset = segments[j].offsetRange.upperBound
          state = .final
        }
        else {
          // no more segments, end the loop.
          state = .exit
        }

      case .final:
        let segment = segments[i]
        assert(offset == segment.offsetRange.lowerBound)
        assert(endOffset <= segment.offsetRange.upperBound)
        guard var frame = getReflowSegmentFrame(i) else { return false }
        let i1 = segment.fragmentIndex(endOffset)
        let d1 = segment.cursorDistanceThroughSegment(i1)
        frame.frame.size.width = d1

        shouldContinue = localBlock(nil, frame.frame, frame.baselinePosition)
        // no more segments, end the loop.
        state = .exit

      case .exit:
        break  // no-op
      }
    }

    return shouldContinue
  }
}

/// Array of quantised baseline positions of reflow segments.
///
/// Quantisation is used to place segments that have the same baseline position
/// into the same group, so that we can find the **split point** of segments.
/// Grouping may fail in the rare case where baselines of the same group lies around
/// quantisation boundary.
struct ReflowSegmentArray {
  private let textLayoutContext: TextLayoutContext
  /// layout offset of the first segment in the array.
  private let textOffset: Int
  /// the number of segments in the array.
  internal let count: Int
  /// Quantised baseline position of the segments.
  private var _yQuantised: Array<Optional<Int>>

  internal init(
    _ textLayoutContext: TextLayoutContext, _ textOffset: Int, count: Int
  ) {
    precondition(count > 0)
    self.textLayoutContext = textLayoutContext
    self.textOffset = textOffset
    self.count = count
    self._yQuantised = Array<Optional<Int>>(repeating: nil, count: count)
  }

  internal mutating func get(_ index: Int) -> Int {
    precondition(index >= 0 && index < count)
    if _yQuantised[index] == nil {
      _yQuantised[index] = fetch(index)
    }
    return _yQuantised[index]!
  }

  private func fetch(_ index: Int) -> Int {
    precondition(index >= 0 && index < count)
    let offset = textOffset + index
    guard let frame = textLayoutContext.getSegmentFrame(offset, .downstream)
    else { return 0 }
    // quantise the basseline position.
    return Self.quantise(frame.frame.origin.y + frame.baselinePosition)
  }

  /// Returns the first index whose quantised baseline position is different
  /// from the first segment.
  /// - Returns: the index of the first segment with different baseline position,
  ///     or `count` if all segments have the same baseline position.
  internal mutating func splitPoint() -> Int {
    let first = get(0)
    return Satz.lowerBound(0..<count, first) { self.get($0) <= $1 }
  }

  static func quantise(_ y: Double) -> Int {
    Int(Foundation.floor(y / 4))
  }
}
