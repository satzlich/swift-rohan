// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

/** How much a delimiter can be shorter than the wrapped */
private let DELIMITER_SHORTFALL = Em(0.1)
/** Space to be added to each side of fraction */
private let FRACTION_SPACING = Em(0.1)

final class MathFractionLayoutFragment: MathLayoutFragment {
  init(
    _ numerator: MathListLayoutFragment,
    _ denominator: MathListLayoutFragment,
    _ isBinomial: Bool = false
  ) {
    self.numerator = numerator
    self.denominator = denominator
    self._glyphOrigin = .zero
    self.isBinomial = isBinomial
    self._composition = MathComposition()
    self.rulePosition = .zero
  }

  /** true if the fraction is a binomial */
  let isBinomial: Bool
  let numerator: MathListLayoutFragment
  let denominator: MathListLayoutFragment
  private(set) var rulePosition: CGPoint

  private var _composition: MathComposition

  // MARK: - Frame

  private var _glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    _glyphOrigin = origin
  }

  var glyphFrame: CGRect {
    let size = CGSize(width: width, height: height)
    return CGRect(origin: _glyphOrigin, size: size)
  }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Length

  var layoutLength: Int { 1 }

  // MARK: - Metrics

  var width: Double { @inline(__always) get { _composition.width } }
  var height: Double { @inline(__always) get { _composition.height } }
  var ascent: Double { @inline(__always) get { _composition.ascent } }
  var descent: Double { @inline(__always) get { _composition.descent } }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  // MARK: - Categories

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  // MARK: - Flags

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

    // compute metrics
    let numGap =
      max(shiftUp - (axisHeight + thickness / 2) - numerator.descent, numGapMin)
    let denomGap =
      max(shiftDown + (axisHeight - thickness / 2) - denominator.ascent, denomGapMin)
    let ruleWidth = max(numerator.width, denominator.width)
    let width = ruleWidth + 2 * fractionSpace
    let height = numerator.height + numGap + thickness + denomGap + denominator.height
    let ascent = numerator.height + numGap + thickness / 2 + axisHeight
    let descent = height - ascent

    // compute positions: from top to bottom
    let numPosition = CGPoint(
      x: (width - numerator.width) / 2,
      y: -ascent + numerator.ascent)
    let rulePosition = CGPoint(
      x: (width - ruleWidth) / 2,
      y: -axisHeight)
    let denomPosition = CGPoint(
      x: (width - denominator.width) / 2,
      y: descent - denominator.descent)

    // expose rule position
    self.rulePosition = rulePosition

    // compose
    if isBinomial {
      let nucleus = {
        let items: [MathComposition.Item] = [
          (numerator, numPosition),
          (denominator, denomPosition),
        ]
        let composition = MathComposition(
          width: width,
          ascent: ascent, descent: descent,
          items: items)
        return FrameFragment(composition)
      }()

      let left = GlyphFragment("(", font, mathContext.table)!
        .stretchVertical(height, shortfall: shortfall, mathContext)
      let right = GlyphFragment(")", font, mathContext.table)!
        .stretchVertical(height, shortfall: shortfall, mathContext)

      _composition = MathComposition.createHorizontal([left, nucleus, right])

      // set glyph origin of components
      numerator.setGlyphOrigin(CGPoint(x: left.width + numPosition.x, y: numPosition.y))
      denominator.setGlyphOrigin(
        CGPoint(x: left.width + denomPosition.x, y: denomPosition.y))
    }
    else {
      let ruler = RuleFragment(width: ruleWidth, height: thickness)
      let items: [MathComposition.Item] = [
        (numerator, numPosition),
        (ruler, rulePosition),
        (denominator, denomPosition),
      ]
      _composition = MathComposition(
        width: width, ascent: ascent, descent: descent, items: items)

      // set frame origin of components
      numerator.setGlyphOrigin(numPosition)
      denominator.setGlyphOrigin(denomPosition)
    }
  }

  // MARK: - Debug Description

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "fraction"
    let description: String = "\(name) \(boxDescription)"
    let ruler: [String] = {
      let position = rulePosition.formatted(2)
      return ["rule \(position)"]
    }()
    let numerator = self.numerator.debugPrint("numerator")
    let denominator = self.denominator.debugPrint("denominator")
    return PrintUtils.compose([description], [numerator, ruler, denominator])
  }
}
