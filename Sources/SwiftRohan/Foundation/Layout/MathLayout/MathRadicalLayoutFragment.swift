// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathRadicalLayoutFragment: MathLayoutFragment {

  let radicand: MathListLayoutFragment
  var index: MathListLayoutFragment?

  private var _composition: MathComposition

  init(_ radicand: MathListLayoutFragment, _ index: MathListLayoutFragment?) {
    self.radicand = radicand
    self.index = index
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  // MARK: - Layout

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { _composition.width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()
    let constants = mathContext.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    func metric(_ text: MathValueRecord, _ display: MathValueRecord) -> Double {
      switch mathContext.mathStyle {
      case .display:
        return metric(from: display)
      default:
        return metric(from: text)
      }
    }

    let gap = metric(
      constants.radicalVerticalGap, constants.radicalDisplayStyleVerticalGap)
    let thickness = metric(from: constants.radicalRuleThickness)
    let extra_ascender = metric(from: constants.radicalExtraAscender)
    let kern_before = metric(from: constants.radicalKernBeforeDegree)
    let kern_after = metric(from: constants.radicalKernAfterDegree)
    let raise_factor = Double(constants.radicalDegreeBottomRaisePercent) / 100

    // layout root symbol
    let target = radicand.height + thickness + gap
    let sqrt =
      GlyphFragment("√", font, mathContext.table)?
      .stretch(orientation: .vertical, target: target, shortfall: 0, mathContext)
      ?? RuleFragment(width: 1, height: target)

    // TeXbook, page 443, item 11
    // Keep original gap, and then distribute any remaining free space
    // equally above and below.
    let newGap = max(gap, (sqrt.height - thickness - radicand.height + gap) / 2)

    let sqrt_ascent = radicand.ascent + newGap + thickness
    let total_descent = sqrt.height - sqrt_ascent
    let inner_ascent = sqrt_ascent + extra_ascender

    var sqrt_offset = 0.0
    var shift_up = 0.0
    var total_ascent = inner_ascent

    if let index = self.index {
      sqrt_offset = kern_before + index.width + kern_after
      // The formula below for how much raise the index by comes from
      // the TeXbook, page 360, in the definition of `\root`.
      // However, the `+ index.descent()` part is different from TeX.
      // Without it, descenders can collide with the surd, a rarity
      // in practice, but possible.  MS Word also adjusts index positions
      // for descenders.
      shift_up = raise_factor * (inner_ascent - total_descent) + index.descent
      total_ascent = max(total_ascent, shift_up + index.ascent)
    }

    let sqrt_x = max(sqrt_offset, 0)
    let sqrt_y = -(sqrt_ascent - sqrt.ascent)
    let radicand_x = sqrt_x + sqrt.width
    let width = radicand_x + radicand.width

    // positions

    let sqrt_pos = CGPoint(x: sqrt_x, y: sqrt_y)
    let line_pos = CGPoint(x: radicand_x, y: -radicand.ascent - newGap - thickness / 2)
    let radicand_pos = CGPoint(x: radicand_x, y: 0)

    // compose
    var items: [MathComposition.Item] = []

    if let index = self.index {
      let index_x = -min(sqrt_offset, 0) + kern_before
      let index_y = -shift_up
      let index_pos = CGPoint(x: index_x, y: index_y)

      index.setGlyphOrigin(index_pos)
      items.append((index, index_pos))
    }

    do {
      items.append((sqrt, sqrt_pos))
      items.append((RuleFragment(width: radicand.width, height: thickness), line_pos))

      //
      radicand.setGlyphOrigin(radicand_pos)
      items.append((radicand, radicand_pos))
    }

    _composition = MathComposition(
      width: width, ascent: total_ascent, descent: total_descent, items: items)
  }

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    if let index = index {
      let midX = (index.maxX + radicand.minX) / 2
      return midX <= point.x ? .radicand : .index
    }
    else {
      let midX = (0 + radicand.minX) / 2
      return midX <= point.x ? .radicand : nil
    }
  }

  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    switch direction {
    case .up:
      let point = point.with(y: self.minY)
      return RayshootResult(point, false)

    case .down:
      let point = point.with(y: self.maxY)
      return RayshootResult(point, false)

    default:
      assertionFailure("Unsupported direction")
      return nil
    }
  }

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): MathRadicalLayoutFragment"
    let radicand = self.radicand.debugPrint("\(MathIndex.radicand)")
    let index = self.index?.debugPrint("\(MathIndex.index)")
    let children = [index, radicand].compactMap { $0 }
    return PrintUtils.compose([description], children)
  }
}
