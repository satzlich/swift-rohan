// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

/// How much a delimiter can be shorter than the wrapped
private let DELIMITER_SHORTFALL = Em(0.1)
/// Space to be added to each side of fraction
private let FRACTION_SPACING = Em(0.1)
/// Minimum width of fraction rule
private let MIN_RULE_WIDTH = Em(0.3)

final class MathFractionLayoutFragment: MathLayoutFragment {
  internal typealias Subtype = FractionNode.Subtype

  let subtype: Subtype
  let numerator: MathListLayoutFragment
  let denominator: MathListLayoutFragment
  private(set) var rulePosition: CGPoint
  private(set) var ruleWidth: CGFloat

  private var _composition: MathComposition

  init(
    _ numerator: MathListLayoutFragment,
    _ denominator: MathListLayoutFragment,
    _ subtype: FractionNode.Subtype
  ) {
    self.numerator = numerator
    self.denominator = denominator
    self.subtype = subtype

    // use default values
    self.rulePosition = .zero
    self.ruleWidth = 0
    self.glyphOrigin = .zero
    self._composition = MathComposition()
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Length

  var layoutLength: Int { 1 }

  // MARK: - Layout Attributes

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  // MARK: - Layout

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

    // obtain parameters
    let shortfall = font.convertToPoints(DELIMITER_SHORTFALL)
    let axisHeight = metric(from: constants.axisHeight)
    let thickness = metric(from: constants.fractionRuleThickness)
    let shiftUp = metric(
      constants.fractionNumeratorShiftUp,
      constants.fractionNumeratorDisplayStyleShiftUp)
    let shiftDown = metric(
      constants.fractionDenominatorShiftDown,
      constants.fractionDenominatorDisplayStyleShiftDown)
    let numGapMin = metric(
      constants.fractionNumeratorGapMin,
      constants.fractionNumDisplayStyleGapMin)
    let denomGapMin = metric(
      constants.fractionDenominatorGapMin,
      constants.fractionDenomDisplayStyleGapMin)
    let fractionSpace = font.convertToPoints(FRACTION_SPACING)
    let minRuleWidth = font.convertToPoints(MIN_RULE_WIDTH)

    // compute metrics
    let numGap =
      max(shiftUp - (axisHeight + thickness / 2) - numerator.descent, numGapMin)
    let denomGap =
      max(shiftDown + (axisHeight - thickness / 2) - denominator.ascent, denomGapMin)
    let ruleWidth = max(numerator.width, denominator.width, minRuleWidth)
    let width = ruleWidth + 2 * fractionSpace
    let height = numerator.height + numGap + thickness + denomGap + denominator.height
    let ascent = numerator.height + numGap + thickness / 2 + axisHeight
    let descent = height - ascent

    // compute positions: from top to bottom
    var numPosition = CGPoint(
      x: (width - numerator.width) / 2,
      y: -ascent + numerator.ascent)
    var rulePosition = CGPoint(
      x: (width - ruleWidth) / 2,
      y: -axisHeight)
    var denomPosition = CGPoint(
      x: (width - denominator.width) / 2,
      y: descent - denominator.descent)
    var rightPosition = CGPoint(x: width, y: 0)

    // export rule width
    self.ruleWidth = ruleWidth

    do {
      var items: [MathComposition.Item] = []

      let delimiters = subtype.delimiters
      let (open, close) = (delimiters.open.value, delimiters.close.value)

      let left = open.flatMap {
        GlyphFragment(char: $0, font, mathContext.table)?
          .stretchVertical(height, shortfall: shortfall, mathContext)
      }
      let right = close.flatMap {
        GlyphFragment(char: $0, font, mathContext.table)?
          .stretchVertical(height, shortfall: shortfall, mathContext)
      }

      var total_width = width
      var total_ascent = ascent
      var total_descent = descent

      if let left = left {
        total_width += left.width
        total_ascent = max(total_ascent, left.ascent)
        total_descent = max(total_descent, left.descent)
        // add left delimiter
        items.append((left, .zero))
        // shift positions
        numPosition.x += left.width
        denomPosition.x += left.width
        rulePosition.x += left.width
        rightPosition.x += left.width
      }
      if let right = right {
        total_width += right.width
        total_ascent = max(total_ascent, right.ascent)
        total_descent = max(total_descent, right.descent)
        // add right delimiter
        items.append((right, rightPosition))
      }

      if subtype.ruler {
        let ruler = RuleFragment(width: ruleWidth, height: thickness)
        items.append((ruler, rulePosition))
      }

      // add numerator and denominator
      items.append((numerator, numPosition))
      items.append((denominator, denomPosition))

      // create composition
      _composition = MathComposition(
        width: total_width, ascent: total_ascent, descent: total_descent, items: items)

      // set glyph origins
      numerator.setGlyphOrigin(numPosition)
      denominator.setGlyphOrigin(denomPosition)

      // set rule position
      self.rulePosition = rulePosition
    }
  }

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    let leftX = (0 + rulePosition.x) / 2
    let rightX = (rulePosition.x + ruleWidth + self.width) / 2

    if point.x < leftX || point.x > rightX {
      return nil
    }
    else {
      return point.y <= rulePosition.y ? .num : .denom
    }
  }

  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    switch direction {
    case .up:
      if component == .num {  // numerator
        // move to top of fraction
        return RayshootResult(point.with(y: self.minY), false)
      }
      else {  // denominator
        // move to bottom of numerator
        return RayshootResult(point.with(y: self.numerator.maxY), true)
      }

    case .down:
      if component == .num {  // numerator
        // move to top of denominator
        if self.denominator.isEmpty {
          // special workaround for empty denominator
          let y = self.rulePosition.y + 0.1
          return RayshootResult(point.with(y: y), true)
        }
        else {
          return RayshootResult(point.with(y: self.denominator.minY), true)
        }
      }
      else {  // denominator
        // move to bottom of fraction
        return RayshootResult(point.with(y: self.maxY), false)
      }
    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  // MARK: - Debug Description

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "fraction \(boxDescription)"
    let children: [Array<String>]
    do {
      let ruler: [String] = ["ruler \(rulePosition.formatted(2))"]
      let numerator = self.numerator.debugPrint("\(MathIndex.num)")
      let denominator = self.denominator.debugPrint("\(MathIndex.denom)")
      children = [ruler, numerator, denominator]
    }
    return PrintUtils.compose([description], children)
  }
}
