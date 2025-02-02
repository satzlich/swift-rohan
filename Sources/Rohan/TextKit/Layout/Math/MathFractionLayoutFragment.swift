// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

/** How much a delimiter can be shorter than the wrapped */
let DELIMITER_SHORTFALL = Em(0.1)
/** Added space to each side of fraction */
let FRACTION_SPACING = Em(0.1)

final class MathFractionLayoutFragment: MathLayoutFragment {
    init(_ numerator: MathListLayoutFragment,
         _ denominator: MathListLayoutFragment,
         _ isBinomial: Bool = false)
    {
        self._numerator = numerator
        self._denominator = denominator
        self._frameOrigin = .zero
        self.isBinomial = isBinomial
        self._composition = MathComposition()
    }

    /** true if the fraction is a binomial */
    let isBinomial: Bool

    private let _numerator: MathListLayoutFragment
    var numerator: MathListLayoutFragment { @inline(__always) get { _numerator } }

    private let _denominator: MathListLayoutFragment
    var denominator: MathListLayoutFragment { @inline(__always) get { _denominator } }

    private var _composition: MathComposition

    // MARK: - Frame

    var _frameOrigin: CGPoint

    func setFrameOrigin(_ origin: CGPoint) {
        _frameOrigin = origin
    }

    var layoutFragmentFrame: CGRect {
        let size = CGSize(width: width, height: height)
        return CGRect(origin: _frameOrigin, size: size)
    }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        _composition.draw(at: point, in: context)
    }

    // MARK: - Length

    var layoutLength: Int { 1 }

    // MARK: - Metrics

    var width: Double { _composition.width }
    var height: Double { _composition.height }
    var ascent: Double { _composition.ascent }
    var descent: Double { _composition.descent }
    var italicsCorrection: Double { _composition.italicsCorrection }
    var accentAttachment: Double { _composition.accentAttachment }

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
        let shiftUp = metric(constants.fractionNumeratorShiftUp,
                             constants.fractionNumeratorDisplayStyleShiftUp)
        let shiftDown = metric(constants.fractionDenominatorShiftDown,
                               constants.fractionDenominatorDisplayStyleShiftDown)
        let numGapMin = metric(constants.fractionNumeratorGapMin,
                               constants.fractionNumDisplayStyleGapMin)
        let denomGapMin = metric(constants.fractionDenominatorGapMin,
                                 constants.fractionDenomDisplayStyleGapMin)

        // compute metrics
        let fractionSpace = font.convertToPoints(FRACTION_SPACING)
        let numGap = max(shiftUp - (axisHeight + thickness / 2) - numerator.descent,
                         numGapMin)
        let denomGap = max(shiftDown + (axisHeight - thickness / 2) - denominator.ascent,
                           denomGapMin)
        let ruleWidth = max(numerator.width, denominator.width)
        let width = ruleWidth + 2 * fractionSpace
        let height = numerator.height + numGap + thickness + denomGap + denominator.height

        // compute positions: from top to bottom
        let ascent = numerator.height + numGap + thickness / 2 + axisHeight
        let descent = height - ascent
        let numPosition = CGPoint(x: (width - numerator.width) / 2,
                                  y: -ascent + numerator.ascent)
        let rulePosition = CGPoint(x: (width - ruleWidth) / 2,
                                   y: -axisHeight)
        let denomPosition = CGPoint(x: (width - denominator.width) / 2,
                                    y: descent - denominator.descent)

        // set frame origin
        numerator.setFrameOrigin(numPosition)
        denominator.setFrameOrigin(denomPosition)

        // compose
        if isBinomial {
            let items = [(numerator, numPosition),
                         (denominator, denomPosition)]

            let nucleus = {
                let composition = MathComposition(width: width,
                                                  ascent: ascent,
                                                  descent: descent,
                                                  italicsCorrection: 0,
                                                  accentAttachment: width / 2,
                                                  items: items)
                return FrameFragment(composition)
            }()

            let left = GlyphFragment("(", font, mathContext.table)!
                .stretchVertical(height, shortfall: shortfall, mathContext)
            let right = GlyphFragment(")", font, mathContext.table)!
                .stretchVertical(height, shortfall: shortfall, mathContext)

            _composition = MathComposition.createHorizontal([left, nucleus, right])
        }
        else {
            let ruler = RuleFragment(width: ruleWidth, height: thickness)
            let items: [MathComposition.Item] = [(numerator, numPosition),
                                                 (ruler, rulePosition),
                                                 (denominator, denomPosition)]

            _composition = MathComposition(width: width,
                                           ascent: ascent,
                                           descent: descent,
                                           italicsCorrection: 0,
                                           accentAttachment: width / 2,
                                           items: items)
        }
    }
}
