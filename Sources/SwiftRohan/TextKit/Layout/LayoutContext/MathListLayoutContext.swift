// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import TTFParser
import UnicodeMathClass
import _RopeModule

final class MathListLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let layoutFragment: MathListLayoutFragment

  private var fragmentFactory: FragmentFactory
  var mathContext: MathContext { fragmentFactory.mathContext }

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

  var isEditing: Bool { @inline(__always) get { layoutFragment.isEditing } }

  func beginEditing() {
    layoutFragment.beginEditing()
  }

  func endEditing() {
    layoutFragment.endEditing()
    layoutFragment.fixLayout(mathContext)
  }

  // MARK: - Operations

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    // do nothing
  }

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

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing && layoutCursor >= 0)
    guard !text.isEmpty else { assertionFailure("empty text is invalid"); return }
    let mathProperty: MathProperty = source.resolvePropertyAggregate(styleSheet)
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

  // MARK: - Enumeration

  private func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    layoutFragment.getSegmentFrame(for: layoutOffset)
  }

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    self.getSegmentFrame(for: layoutOffset, affinity)
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

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    let point = CGPoint(x: point.x, y: point.y - layoutFragment.ascent)
    let (range, fraction) = layoutFragment.getLayoutRange(interactingAt: point)
    return PickingResult(range, fraction, .downstream)
  }

  func rayshoot(
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = getSegmentFrame(for: layoutOffset, affinity)
    else { return nil }
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

  func lineFrame(
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    nil
  }
}

private struct FragmentFactory {
  let mathContext: MathContext
  private let font: Font

  init(_ mathContext: MathContext) {
    self.mathContext = mathContext
    self.font = mathContext.getFont()
  }

  private lazy var _fallbackContext: MathContext = {
    let size = mathContext.getFont(for: .text).size
    let font = Font.createWithName("STIX Two Math", size, isFlipped: true)
    let mathStyle = mathContext.mathStyle
    let cramped = mathContext.cramped
    let textColor = mathContext.textColor
    return MathContext(font, mathStyle, cramped, textColor)!
  }()

  /// Glyph from fallback context
  private mutating func _fallbackGlyph(
    for char: Character, _ layoutLength: Int
  ) -> GlyphFragment? {
    let font = _fallbackContext.getFont()
    let table = _fallbackContext.table
    return GlyphFragment(char: char, font, table)
  }

  /// Glyph from fallback context
  private mutating func _fallbackGlyph(for char: Character) -> GlyphFragment? {
    let font = _fallbackContext.getFont()
    let table = _fallbackContext.table
    return GlyphFragment(char: char, font, table)
  }

  /// Replacement glyph for invalid character
  mutating func replacementGlyph(_ layoutLength: Int) -> MathGlyphLayoutFragment {
    let glyph = _fallbackGlyph(for: Chars.replacementChar, layoutLength)!
    return MathGlyphLayoutFragment(glyph, layoutLength)
  }

  mutating func makeFragments<S: Collection<Character>>(
    from string: S, _ property: MathProperty
  ) -> [any MathLayoutFragment] {
    string.map { char in resolveCharacter(char, property) }
      .map { (char, original) in makeFragment(for: char, original.length) }
  }

  private mutating func makeFragment(
    for char: Character, _ layoutLength: Int
  ) -> MathLayoutFragment {
    let table = mathContext.table

    let glyph: GlyphFragment
    if let glyph_ = GlyphFragment(char: char, font, table) {
      glyph = glyph_
    }
    else if let glyph_ = _fallbackGlyph(for: char, layoutLength) {
      glyph = glyph_
    }
    else {
      return replacementGlyph(layoutLength)
    }

    if glyph.clazz == .Large && mathContext.mathStyle == .display {
      let constants = mathContext.constants
      let minHeight = font.convertToPoints(constants.displayOperatorMinHeight)
      let height = max(minHeight, glyph.height * 2.squareRoot())
      let variant = glyph.stretchVertical(height, shortfall: 0, mathContext)
      return MathGlyphVariantLayoutFragment(variant, layoutLength)
    }
    else {
      return MathGlyphLayoutFragment(glyph, layoutLength)
    }
  }

  private mutating func resolveCharacter(
    _ char: Character, _ property: MathProperty
  ) -> (Character, original: Character) {
    let substituted = MathUtils.SUBS[char] ?? char
    let styled = MathUtils.styledChar(
      for: substituted, variant: property.variant, bold: property.bold,
      italic: property.italic, autoItalic: true)
    return (styled, char)
  }
}
