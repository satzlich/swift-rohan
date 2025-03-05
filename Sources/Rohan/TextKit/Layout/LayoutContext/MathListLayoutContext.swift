// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import UnicodeMathClass
import _RopeModule

final class MathListLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let mathContext: MathContext
  let layoutFragment: MathListLayoutFragment

  private lazy var fallbackContext: MathContext = {
    let size = mathContext.getFont(for: .text).size
    let font = Font.createWithName("STIX Two Math", size, isFlipped: true)
    return MathContext(font, mathContext.mathStyle, mathContext.textColor)!
  }()

  init(
    _ styleSheet: StyleSheet, _ mathContext: MathContext,
    _ layoutFragment: MathListLayoutFragment
  ) {
    self.styleSheet = styleSheet
    self.mathContext = mathContext

    self.layoutFragment = layoutFragment
    self.layoutCursor = layoutFragment.contentLayoutLength
    self._index = layoutFragment.count
  }

  private func replacementGlyph(_ layoutLength: Int) -> MathGlyphLayoutFragment {
    let font = fallbackContext.getFont()
    let table = fallbackContext.table
    return MathGlyphLayoutFragment(Character("\u{FFFD}"), font, table, layoutLength)!
  }

  // MARK: - State

  /** cursor in the math list, measured in layout length */
  private(set) var layoutCursor: Int = 0

  /** index in the math list, measured in number of fragments */
  private var _index: Int = 0

  var isEditing: Bool { @inline(__always) get { layoutFragment.isEditing } }

  func beginEditing() {
    layoutFragment.beginEditing()
  }

  func endEditing() {
    layoutFragment.endEditing()
    layoutFragment.fixLayout(mathContext)
  }

  // MARK: - Operations

  func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(_index, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // update location
    layoutCursor -= n
    _index = index
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(_index, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // remove
    layoutFragment.removeSubrange(index..<_index)

    // update location
    layoutCursor -= n
    _index = index
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(_index, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // invalidate
    layoutFragment.invalidateSubrange(index..<_index)

    // update location
    layoutCursor -= n
    _index = index
  }

  func insertText(_ text: TextNode) {
    precondition(isEditing && layoutCursor >= 0)
    guard text.stringLength > 0 else { return }
    let mathProperty = text.resolveProperties(styleSheet) as MathProperty
    let fragments = makeFragments(text.bigString, mathProperty)
    layoutFragment.insert(contentsOf: fragments, at: _index)
  }

  private func makeFragments(
    _ string: BigString, _ mathProperty: MathProperty
  ) -> [any MathLayoutFragment] {

    let font = mathContext.getFont()
    let table = mathContext.table
    func makeFragment(_ char: Character, _ layoutLength: Int) -> MathGlyphLayoutFragment {
      MathGlyphLayoutFragment(char, font, table, layoutLength)
        ?? replacementGlyph(layoutLength)
    }

    let fragments: [any MathLayoutFragment] =
      string
      // make substitutions
      .map { char in (MathUtils.SUBS[char] ?? char, char) }
      // convert to styled chars
      .map { (char, original) in
        let styled = MathUtils.styledChar(
          for: char, variant: mathProperty.variant, bold: mathProperty.bold,
          italic: mathProperty.italic, autoItalic: true)
        return (styled, original)
      }
      // make fragments
      .map { (char, original) in makeFragment(char, original.utf16.count) }

    assert(fragments.lazy.map(\.layoutLength).reduce(0, +) == string.utf16.count)
    return fragments
  }

  func insertNewline(_ context: Node) {
    preconditionFailure("newline is not allowed in math list")
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing && layoutCursor >= 0 && fragment is MathLayoutFragment)
    layoutFragment.insert(fragment as! MathLayoutFragment, at: _index)
  }

  // MARK: - Enumeration

  func getSegmentFrame(for layoutOffset: Int) -> SegmentFrame? {
    layoutFragment.getSegmentFrame(for: layoutOffset)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let (minAscent, minDescent) = {
      let font = mathContext.getFont()
      return (font.ascent, font.descent)
    }()
    return layoutFragment.enumerateTextSegments(
      layoutRange, (minAscent, minDescent),
      type: type, options: options, using: block)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> (Range<Int>, Double)? {
    let point = CGPoint(x: point.x, y: point.y - layoutFragment.ascent)
    return layoutFragment.getLayoutRange(interactingAt: point)
  }

  func rayshoot(
    from layoutOffset: Int, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = self.getSegmentFrame(for: layoutOffset) else { return nil }
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
      assertionFailure("unexpected direction")
      return nil
    }
  }
}
