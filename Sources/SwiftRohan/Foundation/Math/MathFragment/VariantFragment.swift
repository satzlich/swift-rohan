// Copyright 2024-2025 Lie Yan

import CoreGraphics
import TTFParser
import UnicodeMathClass

struct VariantFragment: MathFragment {
  /// base character of the variant
  let char: UnicodeScalar

  private let _composition: GlyphComposite

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  let italicsCorrection: Double
  let accentAttachment: Double

  let clazz: MathClass
  let limits: Limits

  var isSpaced: Bool { clazz == .Fence }
  var isTextLike: Bool { isExtendedShape == true }

  let isExtendedShape: Bool

  /// Returns true if the variant is a __middle stretched__ symbol within a
  /// surrounding `\left` and `\right` pair.
  /// - Example: `\mid`
  let isMiddleStretched: Optional<Bool>

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  fileprivate init(
    char: UnicodeScalar,
    glyphComposite: GlyphComposite,
    italicsCorrection: Double,
    accentAttachment: Double,
    clazz: MathClass,
    limits: Limits,
    isExtendedShape: Bool,
    isMiddleStretched: Optional<Bool>
  ) {
    self.char = char
    self._composition = glyphComposite
    self.italicsCorrection = italicsCorrection
    self.accentAttachment = accentAttachment
    self.clazz = clazz
    self.limits = limits
    self.isExtendedShape = isExtendedShape
    self.isMiddleStretched = isMiddleStretched
  }
}

extension VariantFragment {
  enum Orientation {
    case horizontal
    /// The vertical orientation with the given axis height in points.
    case vertical(axisHeight: Double)
  }

  /// Create a variant fragment from the given glyph part records.
  /// - Parameters:
  ///   - parts: The glyph part records.
  ///   - ratio: The ratio to apply to `maxOverlap-minOverlap`.
  ///   - totalAdvance: The total advance of the glyph in the given orientation.
  ///   - base: The base glyph fragment.
  ///   - orientation: The orientation of the glyph.
  ///   - minOverlap: The minimum overlap between the glyphs (in design units).
  static func from(
    parts: Array<GlyphPartRecord>, ratio: Double, totalAdvance: Double,
    base: GlyphFragment, orientation: Orientation, minOverlap: Int
  ) -> VariantFragment {

    // compute fragments and advance for each
    typealias _Fragment = (fragment: SuccinctGlyph, advance: Double)
    let fragments: [_Fragment] = parts.enumerated().map { (i, part) in
      var advance = CGFloat(part.fullAdvance)
      if i + 1 < parts.count {
        let next = parts[i + 1]
        let maxOverlap = CGFloat(min(part.endConnectorLength, next.startConnectorLength))
        advance -= maxOverlap
        advance += ratio * (maxOverlap - CGFloat(minOverlap))
      }
      return (
        SuccinctGlyph(part.glyphID, base.font),
        base.font.convertToPoints(fromUnits: advance)
      )
    }

    // compute metrics
    let width: Double
    let ascent: Double
    let descent: Double
    let accentAttachment: Double
    switch orientation {
    case .horizontal:
      width = totalAdvance
      ascent = base.ascent
      descent = base.descent
      accentAttachment = width / 2
    case .vertical(let axisHeight):
      width = fragments.lazy.map(\.fragment.width).max() ?? .zero
      ascent = totalAdvance / 2 + axisHeight
      descent = totalAdvance - ascent
      accentAttachment = base.accentAttachment
    }

    // compute positions
    var offset = 0.0
    typealias _Item = GlyphComposite.Item
    let items = fragments.map { fragment, advance in
      let position: CGPoint =
        switch orientation {
        case .horizontal: CGPoint(x: offset, y: 0)
        case .vertical: CGPoint(x: 0, y: descent - offset - fragment.descent)
        }
      offset += advance
      return _Item(fragment, position)
    }

    let compositeGlyph = GlyphComposite(
      width: width, ascent: ascent, descent: descent, font: base.font, items: items)

    return VariantFragment(
      char: base.char,
      glyphComposite: compositeGlyph,
      italicsCorrection: 0,
      accentAttachment: accentAttachment,
      clazz: base.clazz,
      limits: base.limits,
      isExtendedShape: true,
      isMiddleStretched: nil)
  }
}

/// A succinct representation of a glyph whose contextual font is implicitly known.
fileprivate struct SuccinctGlyph {
  let glyph: GlyphId

  let width: Double
  var height: Double { ascent + descent }
  let ascent: Double
  let descent: Double

  init(_ glyph: GlyphId, _ font: Font) {
    let width = font.getAdvance(for: glyph, .horizontal)
    let (ascent, descent) = font.getAscentDescent(for: glyph)

    self.glyph = glyph
    self.width = width
    self.ascent = ascent
    self.descent = descent
  }
}

fileprivate struct GlyphComposite {
  typealias Item = (fragment: SuccinctGlyph, position: CGPoint)

  private let glyphs: Array<GlyphId>
  private let positions: Array<CGPoint>
  private let font: Font

  let width: Double
  var height: Double { ascent + descent }
  let ascent: Double
  let descent: Double

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    font.drawGlyphs(glyphs, positions, context)
    context.restoreGState()
  }

  init<S: Sequence<Item>>(
    width: Double, ascent: Double, descent: Double,
    font: Font, items: S
  ) {
    self.width = width
    self.ascent = ascent
    self.descent = descent
    self.font = font
    self.glyphs = items.map(\.fragment.glyph)
    self.positions = items.map(\.position)
  }
}
