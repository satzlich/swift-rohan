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

  internal func getFragments(for string: String, _ source: Node) -> Array<MathFragment> {
    let mathProperty: MathProperty = source.resolvePropertyAggregate(styleSheet)
    return fragmentFactory.makeFragments(from: string, mathProperty)
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
    let font = mathContext.getFont()
    let (minAscent, minDescent) = (font.ascent, font.descent)
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

  // MARK: - Reflow

  /// Convert a layout offset to a reflowed offset assuming the initial text offset
  /// is zero.`
  func reflowedOffset(for layoutOffset: Int) -> Int {
    layoutFragment.reflowedOffset(for: layoutOffset)
  }

  /// Convert a reflowed offset to a layout offset assuming the initial text offset
  /// is zero.
  func originalOffset(for reflowedOffset: Int) -> Int {
    layoutFragment.originalOffset(for: reflowedOffset)
  }

  /// The layout length of the content when reflowed.
  /// - Invariant: When the content is empty, this should be zero.
  var reflowedLength: Int { layoutFragment.reflowedLength }

  internal typealias ReflowElement = MathListLayoutFragment.ReflowElement

  func reflowedContent() -> Array<ReflowElement> {
    layoutFragment.reflowedContent()
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
    MathUtils.fallbackMathContext(for: mathContext)
  }()

  /// Glyph from fallback context
  private mutating func _fallbackGlyph(for char: Character) -> GlyphFragment? {
    let font = _fallbackContext.getFont()
    let table = _fallbackContext.table
    return GlyphFragment(char: char, font, table)
  }

  /// Replacement glyph for invalid character
  mutating func replacementGlyph(_ layoutLength: Int) -> MathGlyphLayoutFragment {
    let glyph = _fallbackGlyph(for: Chars.replacementChar)!
    return MathGlyphLayoutFragment(glyph, layoutLength)
  }

  mutating func makeFragments<S: Collection<Character>>(
    from string: S, _ property: MathProperty
  ) -> [any MathLayoutFragment] {
    string.map { char in
      let styled = MathUtils.resolveCharacter(char, property)
      return makeFragment(for: styled, char.length)
    }
  }

  private mutating func makeFragment(
    for char: Character, _ layoutLength: Int
  ) -> MathLayoutFragment {

    if Chars.isPrime(char) {
      if let fragment =
        primeFragment(char, mathContext) ?? primeFragment(char, _fallbackContext)
      {
        return MathGlyphVariantLayoutFragment(fragment, layoutLength)
      }
      else {
        return replacementGlyph(layoutLength)
      }
    }
    else {
      let table = mathContext.table
      guard
        let glyph = GlyphFragment(char: char, font, table) ?? _fallbackGlyph(for: char)
      else {
        return replacementGlyph(layoutLength)
      }
      if glyph.clazz == .Large && mathContext.mathStyle == .display {
        let constants = mathContext.constants
        let minHeight = font.convertToPoints(constants.displayOperatorMinHeight)
        let axisHeight = font.convertToPoints(constants.axisHeight)
        let height = max(minHeight, glyph.height * 2.squareRoot())
        let variant = glyph.stretch(
          orientation: .vertical, target: height, shortfall: 0, mathContext)
        return MathGlyphVariantLayoutFragment.createCentered(
          variant, layoutLength, axisHeight: axisHeight)
      }
      else {
        return MathGlyphLayoutFragment(glyph, layoutLength)
      }
    }
  }

  /// Resolve a character to a styled character
  mutating func resolveCharacter(
    _ char: Character, _ property: MathProperty
  ) -> (Character, original: Character) {
    let substituted = MathUtils.SUBS[char] ?? char
    let styled = MathUtils.styledChar(
      for: substituted, variant: property.variant, bold: property.bold,
      italic: property.italic, autoItalic: true)
    return (styled, char)
  }

  /// Fragment for prime character
  private mutating func primeFragment(
    _ char: Character, _ mathContext: MathContext
  ) -> MathFragment? {
    precondition(Chars.isPrime(char))

    let table = mathContext.table
    if let scaledUp = mathContext.mathStyle.scaleUp() {
      let font = mathContext.getFont(for: scaledUp)

      // xHeight may be negative
      // 0.8 works well for Latin Modern, Libertinus, STIX Two
      let shiftDown = Swift.abs(font.xHeight) * 0.8
      return GlyphFragment(char: char, font, table)
        .map { glyph in TranslatedFragment(source: glyph, shiftDown: shiftDown) }
    }
    else {
      return GlyphFragment(char: char, font, table)
    }
  }
}
