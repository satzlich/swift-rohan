// Copyright 2024 Lie Yan

import Foundation

typealias GlyphId = UInt16

enum MathUtils {
    /**

     - Parameters:
        - baseGlyph:    base glyph
        - baseExtent:   width or height of base glyph
        - target:       target width or height
        - shortfall:    the amount by which the base can be shorter than the target
     */
    static func stretchGlyph(
        context: MathContext,
        baseGlyph: GlyphId,
        baseExtent: AbsLength,
        target: AbsLength,
        shortfall: AbsLength
    ) {
        // If the base glyph is good enough , use it.
        let shortTarget = target - shortfall
        if shortTarget <= baseExtent {
            // TODO: turn base into result form
            // which will be determined later
        }

        // TODO: stretch glyph
    }
}
