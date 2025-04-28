// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathUnderOverlineLayoutFragment: MathLayoutFragment {

  typealias Subtype = _UnderOverlineNode.Subtype

  let subtype: Subtype
  let nucleus: MathListLayoutFragment
  private var _composition: MathComposition

  init(_ subtype: Subtype, _ nucleus: MathListLayoutFragment) {
    self.subtype = subtype
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

  var italicsCorrection: Double { nucleus.italicsCorrection }

  var accentAttachment: Double { _composition.width / 2 }

  var clazz: MathClass { nucleus.clazz }

  var limits: Limits { .never }

  var isSpaced: Bool { false }

  var isTextLike: Bool { nucleus.isTextLike }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
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

    switch subtype {
    case .underline:
      let sep = metric(from: constants.underbarExtraDescender)
      bar_height = metric(from: constants.underbarRuleThickness)
      let gap = metric(from: constants.underbarVerticalGap)
      extra_height = sep + bar_height + gap

      let line_y = content.descent + gap + bar_height / 2
      line_pos = CGPoint(x: 0, y: line_y)
      line_adjust = -content.italicsCorrection

      total_ascent = content.ascent
      total_descent = content.descent + extra_height

    case .overline:
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

    let width = content.width
    let line_width = width + line_adjust

    var items: [MathComposition.Item] = []
    // set rule position
    let rule = RuleFragment(width: line_width, height: bar_height)
    items.append((rule, line_pos))
    // set nucleus position
    items.append((content, .zero))
    content.setGlyphOrigin(.zero)

    _composition = MathComposition(
      width: width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "underoverline"
    let description: String = "\(name) \(boxDescription)"

    let subtype = ["subtype: \(self.subtype)"]
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [subtype, nucleus])
  }
}
