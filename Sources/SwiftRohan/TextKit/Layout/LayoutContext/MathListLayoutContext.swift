// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import TTFParser
import UnicodeMathClass
import _RopeModule

final class MathListLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let layoutFragment: MathListLayoutFragment

  internal var mathContext: MathContext { fragmentFactory.mathContext }
  private var fragmentFactory: FragmentFactory

  init(
    _ styleSheet: StyleSheet, _ mathContext: MathContext,
    _ layoutFragment: MathListLayoutFragment
  ) {
    self.styleSheet = styleSheet
    self.fragmentFactory = FragmentFactory(mathContext)

    self.layoutFragment = layoutFragment
    self.layoutCursor = layoutFragment.contentLayoutLength
    self.fragmentIndex = layoutFragment.count
  }

  // MARK: - State

  /// cursor in the layout fragment, measured in layout length
  private(set) var layoutCursor: Int = 0

  /// index in the math list, measured in number of fragments
  private var fragmentIndex: Int = 0

  func resetCursor() {
    self.layoutCursor = layoutFragment.contentLayoutLength
    self.fragmentIndex = layoutFragment.count
  }

  var isEditing: Bool { layoutFragment.isEditing }

  func beginEditing() {
    layoutFragment.beginEditing()
  }

  func endEditing() {
    layoutFragment.endEditing()
    layoutFragment.fixLayout(mathContext)
  }

  // MARK: - Operations

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) { /* no-op */  }

  func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found") }

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found") }

    // remove
    layoutFragment.removeSubrange(index..<fragmentIndex)

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found") }

    // invalidate
    layoutFragment.invalidateSubrange(index..<fragmentIndex)

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing && layoutCursor >= 0)
    guard !text.isEmpty else { return }
    let mathProperty: MathProperty = source.resolveAggregate(styleSheet)
    let fragments = fragmentFactory.makeFragments(from: text, mathProperty)
    layoutFragment.insert(contentsOf: fragments, at: fragmentIndex)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing && layoutCursor >= 0)
    assertionFailure("newline is invalid")
    // newline is invalid; insert a replacement glyph instead
    let glyph = fragmentFactory.replacementGlyph(1)
    layoutFragment.insert(glyph, at: fragmentIndex)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing && layoutCursor >= 0)
    assert(fragment is MathLayoutFragment)
    // for robustness, insert a replacement glyph for invalid fragment
    if let fragment = fragment as? MathLayoutFragment {
      layoutFragment.insert(fragment, at: fragmentIndex)
    }
    else {
      let glyph = fragmentFactory.replacementGlyph(fragment.layoutLength)
      layoutFragment.insert(glyph, at: fragmentIndex)
    }
  }

  /// Get math fragments for the given string.
  internal func getFragments(for string: String, _ source: Node) -> Array<MathFragment> {
    let mathProperty: MathProperty = source.resolveAggregate(styleSheet)
    return fragmentFactory.makeFragments(from: string, mathProperty)
  }

  // MARK: - Query

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame? {
    layoutFragment.getSegmentFrame(layoutOffset)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let (minAscent, minDescent) = mathContext.cursorHeight()
    return layoutFragment.enumerateTextSegments(
      layoutRange, (minAscent, minDescent),
      type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    let point = CGPoint(x: point.x, y: point.y - layoutFragment.ascent)
    let (range, fraction) = layoutFragment.getLayoutRange(interactingAt: point)
    let affinity: SelectionAffinity = fraction > 0.51 ? .upstream : .downstream
    return PickingResult(range, fraction, affinity)
  }

  func rayshoot(
    from layoutOffset: Int,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = getSegmentFrame(layoutOffset, affinity) else { return nil }
    switch direction {
    case .up:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.minY
      return RayshootResult(CGPoint(x: x, y: y), false)

    case .down:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.maxY
      return RayshootResult(CGPoint(x: x, y: y), false)

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }

  func neighbourLineFrame(
    from layoutOffset: Int,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    nil
  }
}
