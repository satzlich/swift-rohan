// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

struct VariantFragment: MathFragment {
    /** base character of the variant */
    let char: UnicodeScalar
    let fontSize: FontSize

    let composition: MathComposition<GlyphFragment>

    // MARK: - Metrics

    var width: Double { composition.width }
    var height: Double { composition.height }
    var ascent: Double { composition.ascent }
    var descent: Double { composition.descent }
    var italicsCorrection: Double { composition.italicsCorrection }
    var accentAttachment: Double { composition.accentAttachment }

    // MARK: - Categories

    let clazz: MathClass
    let limits: Limits

    // MARK: - Flags

    var isSpaced: Bool { clazz == .Fence }
    var isTextLike: Bool { isExtendedShape == true }
    let isExtendedShape: Bool

    /**
     Returns true if the variant is a __middle stretched__ symbol within a
     surrounding `\left` and `\right` pair.

     - Example: `\mid`
     */
    let isMiddleStretched: Optional<Bool>

    func draw(at point: CGPoint, in context: CGContext) {
        for (item, position) in composition.items {
            let point = CGPoint(x: point.x + position.x,
                                y: point.y + position.y)
            item.draw(at: point, in: context)
        }
    }

    init(char: UnicodeScalar,
         fontSize: FontSize,
         composition: MathComposition<GlyphFragment>,
         clazz: MathClass,
         limits: Limits,
         isExtendedShape: Bool,
         isMiddleStretched: Optional<Bool>)
    {
        self.char = char
        self.fontSize = fontSize
        self.composition = composition
        self.clazz = clazz
        self.limits = limits
        self.isExtendedShape = isExtendedShape
        self.isMiddleStretched = isMiddleStretched
    }
}

/** Composite of math fragments */
struct MathComposition<T: MathFragment> {
    typealias Item = (item: T, position: CGPoint)
    let items: [Item]

    // MARK: - Metrics

    let width: Double
    var height: Double { ascent + descent }
    let ascent: Double
    let descent: Double
    let italicsCorrection: Double
    let accentAttachment: Double

    init(width: Double,
         ascent: Double,
         descent: Double,
         italicsCorrection: Double,
         accentAttachment: Double,
         items: [Item])
    {
        precondition(items.isEmpty == false)
        self.width = width
        self.ascent = ascent
        self.descent = descent
        self.italicsCorrection = italicsCorrection
        self.accentAttachment = accentAttachment
        self.items = items
    }
}
