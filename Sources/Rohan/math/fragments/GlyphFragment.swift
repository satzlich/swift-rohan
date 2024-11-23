// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

/**

 - Note: Given a character or glyph together with font family and font size, we know
  **everything** about its GlyphFragment.
 */
struct GlyphFragment: MathFragment {
    let glyph: GlyphId

    let width: AbsLength
    var height: AbsLength {
        ascent + descent
    }

    let ascent: AbsLength
    let descent: AbsLength
    let italicsCorrection: AbsLength
    let accentAttachment: AbsLength

    let `class`: MathClass
    let limits: Limits

    let isSpaced: Bool
    let isTextLike: Bool
}
