// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

private let SPREADER_GAP = Em(0.1)
private let SPREADER_SHORTFALL = Em(0.25)

final class MathUnderOverspreaderLayoutFragment: MathLayoutFragment {

  typealias Subtype = _UnderOverlineNode.Subtype

  let subtype: Subtype
  let spreader: Character
  let nucleus: MathListLayoutFragment
  private var _composition: MathComposition

  init(_ subtype: Subtype, _ spreader: Character, _ nucleus: MathListLayoutFragment) {
    self.subtype = subtype
    self.spreader = spreader
    self.nucleus = nucleus
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Metrics

  var width: Double { _composition.width }

  var height: Double { _composition.height }

  var ascent: Double { _composition.ascent }

  var descent: Double { _composition.descent }

  var italicsCorrection: Double { 0 }

  var accentAttachment: Double { _composition.width / 2 }

  var clazz: MathClass { nucleus.clazz }

  var limits: Limits { .always }

  var isSpaced: Bool { false }

  var isTextLike: Bool { false }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()

    let gap = font.convertToPoints(SPREADER_GAP)
    let shortfall = font.convertToPoints(SPREADER_SHORTFALL)
    let spreader = spreader.unicodeScalars.first!

    let glyph =
      GlyphFragment(spreader, font, mathContext.table)?
      .stretchHorizontal(nucleus.width, shortfall: shortfall, mathContext)
      ?? RuleFragment(width: nucleus.width, height: 1)

    let glyph_y: Double
    let total_ascent: Double
    let total_descent: Double
    switch subtype {
    case .under:
      glyph_y = nucleus.descent + gap + glyph.ascent
      total_ascent = nucleus.ascent
      total_descent = nucleus.descent + gap + glyph.height

    case .over:
      glyph_y = -(nucleus.ascent + gap + glyph.descent)
      total_ascent = nucleus.ascent + gap + glyph.height
      total_descent = nucleus.descent
    }

    var items: [MathComposition.Item] = []

    let total_width = max(glyph.width, nucleus.width)

    do {
      let position = CGPoint(x: (total_width - glyph.width) / 2, y: glyph_y)
      items.append((glyph, position))
    }
    do {
      let position = CGPoint(x: (total_width - nucleus.width) / 2, y: 0)
      items.append((nucleus, position))
      nucleus.setGlyphOrigin(position)
    }

    _composition = MathComposition(
      width: total_width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "underoverspreader"
    let description: String = "\(name) \(boxDescription)"

    let subtype = ["subtype: \(self.subtype)"]
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [subtype, nucleus])
  }
}
