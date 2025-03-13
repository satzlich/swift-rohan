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
    self.fragmentIndex = layoutFragment.count
  }

  private func replacementGlyph(_ layoutLength: Int) -> MathGlyphLayoutFragment {
    let font = fallbackContext.getFont()
    let table = fallbackContext.table
    let replacementChar = Character("\u{FFFD}")
    return MathGlyphLayoutFragment(replacementChar, font, table, layoutLength)!
  }

  // MARK: - State

  /** cursor in the math list, measured in layout length */
  private(set) var layoutCursor: Int = 0

  /** index in the math list, measured in number of fragments */
  private var fragmentIndex: Int = 0

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

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // remove
    layoutFragment.removeSubrange(index..<fragmentIndex)

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    guard let index = layoutFragment.index(fragmentIndex, llOffsetBy: -n)
    else { preconditionFailure("index not found; there may be a bug") }

    // invalidate
    layoutFragment.invalidateSubrange(index..<fragmentIndex)

    // update location
    layoutCursor -= n
    fragmentIndex = index
  }

  func insertText<S>(_ text: S, _ source: Node)
  where S: Collection, S.Element == Character {
    precondition(isEditing && layoutCursor >= 0)
    guard !text.isEmpty else { return }
    let mathProperty = source.resolveProperties(styleSheet) as MathProperty
    let fragments = makeFragments(from: text, mathProperty)
    layoutFragment.insert(contentsOf: fragments, at: fragmentIndex)
  }

  private func makeFragments<S>(
    from string: S, _ mathProperty: MathProperty
  ) -> [any MathLayoutFragment]
  where S: Collection, S.Element == Character {

    let font = mathContext.getFont()
    let table = mathContext.table

    let fragments: [any MathLayoutFragment] =
      string.lazy
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
      .map { (char, original) in
        self.makeFragment(for: char, font, table, original.utf16.count)
      }

    return fragments
  }

  private func makeFragment(
    for char: Character, _ font: Font, _ table: MathTable, _ layoutLength: Int
  ) -> MathGlyphLayoutFragment {
    MathGlyphLayoutFragment(char, font, table, layoutLength)
      ?? replacementGlyph(layoutLength)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing && layoutCursor >= 0)
    assertionFailure("newline is invalid")
    // newline is invalid; insert a replacement glyph instead
    layoutFragment.insert(replacementGlyph(1), at: fragmentIndex)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing && layoutCursor >= 0)
    assert(fragment is MathLayoutFragment)
    // for robustness, insert a replacement glyph for invalid fragment
    let f = (fragment as? MathLayoutFragment) ?? replacementGlyph(fragment.layoutLength)
    layoutFragment.insert(f, at: fragmentIndex)
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
