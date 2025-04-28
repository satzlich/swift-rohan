// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

private let SPREADER_GAP = Em(0.25)

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
    let spreader = spreader.unicodeScalars.first!
    let glyph = GlyphFragment(spreader, font, mathContext.table)!
      .stretchHorizontal(nucleus.width, shortfall: 0, mathContext)

    let glyph_pos: CGPoint
    let total_ascent: Double
    let total_descent: Double
    switch subtype {
    case .under:
      let y = nucleus.descent + gap + glyph.ascent
      glyph_pos = CGPoint(x: 0, y: y)
      total_ascent = nucleus.ascent
      total_descent = nucleus.descent + gap + glyph.height

    case .over:
      let y = -(nucleus.ascent + gap + glyph.descent)
      glyph_pos = CGPoint(x: 0, y: y)
      total_ascent = nucleus.ascent + gap + glyph.height
      total_descent = nucleus.descent
    }

    var items: [MathComposition.Item] = []

    items.append((glyph, glyph_pos))
    //
    items.append((nucleus, .zero))
    nucleus.setGlyphOrigin(.zero)

    _composition = MathComposition(
      width: nucleus.width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "underoverspreader"
    let description: String = "\(name) \(boxDescription)"

    let subtype = ["subtype: \(self.subtype)"]
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [subtype, nucleus])
  }
}
