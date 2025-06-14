// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

private let SPREADER_GAP = Em(0.1)  // typst use 0.25em
private let SPREADER_SHORTFALL = Em(0.25)
private let XARROW_EXTENDER = Em(0.5)

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

  var clazz: MathClass {
    switch spreader.subtype {
    case .overline, .overspreader, .underline, .underspreader:
      return nucleus.clazz
    case .xarrow:
      return .Relation
    }
  }
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

    case .xarrow(let spreader):
      _composition = Self.layoutXarrow(spreader, nucleus, mathContext)
    }
  }

  static func layoutUnderOverspreader(
    _ isOver: Bool, _ spreader: Character, _ base: MathListLayoutFragment,
    _ mathContext: MathContext
  ) -> MathComposition {
    let font = mathContext.getFont()
    let gap = font.convertToPoints(SPREADER_GAP)
    let shortfall = font.convertToPoints(SPREADER_SHORTFALL)

    let attach: MathFragment
    let attach_y: Double
    let total_ascent: Double
    let total_descent: Double

    attach =
      GlyphFragment(char: spreader, font, mathContext.table)?
      .stretch(
        orientation: .horizontal, target: base.width, shortfall: shortfall,
        mathContext)
      ?? ColoredFragment(
        color: .red, wrapped: RuleFragment(width: base.width, height: 2))

    if isOver {
      attach_y = -(base.ascent + gap + attach.descent)
      total_ascent = base.ascent + gap + attach.height
      total_descent = base.descent
    }
    else {
      attach_y = base.descent + gap + attach.ascent
      total_ascent = base.ascent
      total_descent = base.descent + gap + attach.height
    }

    var items: Array<MathComposition.Item> = []
    let total_width = max(attach.width, base.width)
    do {
      let position = CGPoint(x: (total_width - attach.width) / 2, y: attach_y)
      items.append((attach, position))
    }
    do {
      let position = CGPoint(x: (total_width - base.width) / 2, y: 0)
      items.append((base, position))
      base.setGlyphOrigin(position)
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

    let extra_height: Double
    let content = nucleus
    let line_pos: CGPoint
    let bar_height: Double
    let line_adjust: Double
    let total_ascent: Double
    let total_descent: Double

    if isOver {
      let sep = font.convertToPoints(constants.overbarExtraAscender)
      bar_height = font.convertToPoints(constants.overbarRuleThickness)
      let gap = font.convertToPoints(constants.overbarVerticalGap)
      extra_height = sep + bar_height + gap

      let line_y = -(content.ascent + gap + bar_height / 2)
      line_pos = CGPoint(x: 0, y: line_y)
      line_adjust = .zero

      total_ascent = content.ascent + extra_height
      total_descent = content.descent
    }
    else {
      let sep = font.convertToPoints(constants.underbarExtraDescender)
      bar_height = font.convertToPoints(constants.underbarRuleThickness)
      let gap = font.convertToPoints(constants.underbarVerticalGap)
      extra_height = sep + bar_height + gap

      let line_y = content.descent + gap + bar_height / 2
      line_pos = CGPoint(x: 0, y: line_y)
      line_adjust = -content.italicsCorrection

      total_ascent = content.ascent
      total_descent = content.descent + extra_height
    }

    let width = content.width
    let line_width = width + line_adjust

    var items: Array<MathComposition.Item> = []
    // set rule position
    let rule = RuleFragment(width: line_width, height: bar_height)
    items.append((rule, line_pos))
    // set nucleus position
    items.append((content, .zero))

    content.setGlyphOrigin(.zero)

    return MathComposition(
      width: width, ascent: total_ascent, descent: total_descent, items: items)
  }

  static func layoutXarrow(
    _ spreader: Character, _ attach: MathListLayoutFragment, _ mathContext: MathContext
  ) -> MathComposition {
    let font = mathContext.getFont()
    let extender = font.convertToPoints(XARROW_EXTENDER)

    let base: MathFragment =
      GlyphFragment(char: spreader, font, mathContext.table)?
      .stretch(
        orientation: .horizontal, target: attach.width + extender, shortfall: 0,
        mathContext)
      ?? ColoredFragment(
        color: .red, wrapped: RuleFragment(width: attach.width, height: 2))

    let (t_shift, _) = MathUtils.computeLimitShift(mathContext, base, t: attach, b: nil)

    let attach_y = -t_shift
    let total_ascent = t_shift + attach.ascent
    let total_descent = base.descent

    var items: Array<MathComposition.Item> = []
    let total_width = max(attach.width, base.width)
    do {
      let position = CGPoint(x: (total_width - attach.width) / 2, y: attach_y)
      items.append((attach, position))
      attach.setGlyphOrigin(position)
    }
    do {
      let position = CGPoint(x: (total_width - base.width) / 2, y: 0)
      items.append((base, position))
    }

    return MathComposition(
      width: total_width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): MathUnderOverLayoutFragment"
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [nucleus])
  }

  // MARK: - Mouse Pick

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    switch spreader.subtype {
    case .overline: return .nuc
    case .overspreader: return .nuc
    case .underline: return .nuc
    case .underspreader: return .nuc
    case .xarrow:
      let minX = (0 + nucleus.minX) / 2
      let maxX = (width + nucleus.maxX) / 2
      return (point.x >= minX && point.x <= maxX) ? .nuc : nil
    }
  }
}
