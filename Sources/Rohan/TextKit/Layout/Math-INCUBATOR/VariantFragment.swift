// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

struct VariantFragment: MathFragment {
    /** base character of the variant */
    let char: UnicodeScalar
    let fontSize: FontSize

    let composition: MathComposition

    // MARK: - Metrics

    var width: AbsLength { composition.width }
    var height: AbsLength { composition.height }
    var ascent: AbsLength { composition.ascent }
    var descent: AbsLength { composition.descent }
    let italicsCorrection: AbsLength
    let accentAttachment: AbsLength

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
        for (position, item) in composition.items {
            let point = CGPoint(x: point.x + position.x,
                                y: point.y + position.y)
            item.draw(at: point, in: context)
        }
    }

    init(char: UnicodeScalar,
         fontSize: FontSize,
         composition: MathComposition,
         italicsCorrection: AbsLength,
         accentAttachment: AbsLength,
         clazz: MathClass,
         limits: Limits,
         isExtendedShape: Bool,
         isMiddleStretched: Optional<Bool>)
    {
        self.char = char
        self.fontSize = fontSize
        self.composition = composition
        self.italicsCorrection = italicsCorrection
        self.accentAttachment = accentAttachment
        self.clazz = clazz
        self.limits = limits
        self.isExtendedShape = isExtendedShape
        self.isMiddleStretched = isMiddleStretched
    }
}

/** Composite of math fragments */
struct MathComposition {
    typealias Item = (position: CGPoint, item: MathFragment)
    let items: [Item]

    // MARK: - Metrics

    let width: AbsLength
    var height: AbsLength { ascent + descent }
    let ascent: AbsLength
    let descent: AbsLength

    init(width: AbsLength,
         ascent: AbsLength,
         descent: AbsLength,
         items: [Item])
    {
        precondition(items.isEmpty == false)
        self.width = width
        self.ascent = ascent
        self.descent = descent
        self.items = items
    }
}
