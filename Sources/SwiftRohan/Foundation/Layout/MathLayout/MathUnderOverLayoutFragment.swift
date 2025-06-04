// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

private let SPREADER_GAP = Em(0.1)
private let SPREADER_SHORTFALL = Em(0.25)

final class MathUnderOverLayoutFragment: MathLayoutFragment {
  let spreader: MathSpreader
  let nucleus: MathListLayoutFragment
  private var _composition: MathComposition

  init(_ spreader: MathSpreader, _ nucleus: MathListLayoutFragment) {
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
    switch spreader.subtype {
    case .overline:
      _composition = Self.layoutUnderOverline(true, nucleus, mathContext)

    case .overspreader(let spreader):
      _composition = Self.layoutUnderOverspreader(true, spreader, nucleus, mathContext)

    case .underline:
      _composition = Self.layoutUnderOverline(false, nucleus, mathContext)

    case .underspreader(let spreader):
      _composition = Self.layoutUnderOverspreader(false, spreader, nucleus, mathContext)

    case .xarrow:
      preconditionFailure()
    }
  }

  static func layoutUnderOverspreader(
    _ isOver: Bool, _ spreader: Character, _ nucleus: MathListLayoutFragment,
    _ mathContext: MathContext
  ) -> MathComposition {
    let font = mathContext.getFont()
    let gap = font.convertToPoints(SPREADER_GAP)
    let shortfall = font.convertToPoints(SPREADER_SHORTFALL)

    let glyph: MathFragment
    let glyph_y: Double
    let total_ascent: Double
    let total_descent: Double

    glyph =
      GlyphFragment(char: spreader, font, mathContext.table)?
      .stretch(
        orientation: .horizontal, target: nucleus.width, shortfall: shortfall,
        mathContext)
      ?? ColoredFragment(
        color: .red, wrapped: RuleFragment(width: nucleus.width, height: 2))

    if isOver {
      glyph_y = -(nucleus.ascent + gap + glyph.descent)
      total_ascent = nucleus.ascent + gap + glyph.height
      total_descent = nucleus.descent
    }
    else {
      glyph_y = nucleus.descent + gap + glyph.ascent
      total_ascent = nucleus.ascent
      total_descent = nucleus.descent + gap + glyph.height
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

    return MathComposition(
      width: total_width, ascent: total_ascent, descent: total_descent, items: items)
  }

  /// Layout the under/over line
  /// - Returns: a MathComposition with the line and nucleus.
  /// - Note: The `glyphOrigin` of the nucleus is set to zero after layout.
  static func layoutUnderOverline(
    _ isOver: Bool, _ nucleus: MathListLayoutFragment, _ mathContext: MathContext
  ) -> MathComposition {
    let font = mathContext.getFont()
    let constants = mathContext.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    let extra_height: Double
    let content = nucleus
    let line_pos: CGPoint
    let bar_height: Double
    let line_adjust: Double
    let total_ascent: Double
    let total_descent: Double

    if isOver {
      let sep = metric(from: constants.overbarExtraAscender)
      bar_height = metric(from: constants.overbarRuleThickness)
      let gap = metric(from: constants.overbarVerticalGap)
      extra_height = sep + bar_height + gap

      let line_y = -(content.ascent + gap + bar_height / 2)
      line_pos = CGPoint(x: 0, y: line_y)
      line_adjust = .zero

      total_ascent = content.ascent + extra_height
      total_descent = content.descent
    }
    else {
      let sep = metric(from: constants.underbarExtraDescender)
      bar_height = metric(from: constants.underbarRuleThickness)
      let gap = metric(from: constants.underbarVerticalGap)
      extra_height = sep + bar_height + gap

      let line_y = content.descent + gap + bar_height / 2
      line_pos = CGPoint(x: 0, y: line_y)
      line_adjust = -content.italicsCorrection

      total_ascent = content.ascent
      total_descent = content.descent + extra_height
    }

    let width = content.width
    let line_width = width + line_adjust

    var items: [MathComposition.Item] = []
    // set rule position
    let rule = RuleFragment(width: line_width, height: bar_height)
    items.append((rule, line_pos))
    // set nucleus position
    items.append((content, .zero))

    content.setGlyphOrigin(.zero)

    return MathComposition(
      width: width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description =
      (name.map { "\($0): " } ?? "") + "spreader \(boxDescription)"
    let subtype = ["subtype: \(self.spreader)"]
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [subtype, nucleus])
  }
}
