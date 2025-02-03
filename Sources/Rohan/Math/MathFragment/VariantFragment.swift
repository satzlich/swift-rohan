// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

struct VariantFragment: MathFragment {
    /** base character of the variant */
    let char: UnicodeScalar

    let compositeGlyph: CompositeGlyph

    // MARK: - Metrics

    var width: Double { compositeGlyph.width }
    var height: Double { compositeGlyph.height }
    var ascent: Double { compositeGlyph.ascent }
    var descent: Double { compositeGlyph.descent }
    var italicsCorrection: Double { compositeGlyph.italicsCorrection }
    var accentAttachment: Double { compositeGlyph.accentAttachment }

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
        compositeGlyph.draw(at: point, in: context)
    }

    init(char: UnicodeScalar,
         composite: CompositeGlyph,
         clazz: MathClass,
         limits: Limits,
         isExtendedShape: Bool,
         isMiddleStretched: Optional<Bool>)
    {
        self.char = char
        self.compositeGlyph = composite
        self.clazz = clazz
        self.limits = limits
        self.isExtendedShape = isExtendedShape
        self.isMiddleStretched = isMiddleStretched
    }
}
