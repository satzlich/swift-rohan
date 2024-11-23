// Copyright 2024 Lie Yan

import Foundation

enum MathUtils {
    /**

     - Parameters:
        - baseGlyph:    base glyph
        - baseExtent:   width or height of base glyph
        - target:       target width or height
        - shortfall:    the amount by which the base extent can be shorter than the target
        - isHorizontal: true if streching is horizontal
     */
    static func stretchGlyph(
        _ baseGlyph: GlyphId,
        baseExtent: AbsLength,
        target: AbsLength,
        shortfall: AbsLength,
        _ isHorizontal: Bool
    ) {
        // If the base extent is large enough, use the base glyph.
        let minExtent = target - shortfall
        if baseExtent >= minExtent {
            // return the base glyph, possibly in a different format.
        }

        // Otherwise, make an extended glyph.
        
    }
}
