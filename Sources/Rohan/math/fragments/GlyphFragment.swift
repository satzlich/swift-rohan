// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

/**

 - Note: Given a character, along with its font family and font size,
 we can determine **everything** about its `GlyphFragment`.

 - `width`, `height`, `ascent`, and `descent` are obtained by querying the font.
 - `italicsCorrection` and `accentAttachment` are obtained by querying the font, with preference given to a math table when available.
 - `limits` are determined using ``Limits/forChar(_:)``.
 - `class` is determined using ``UnicodeMathClass/mathClass(_:)``.
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

    /// Indicates whether the fragment should be surrounded by spaces.
    /// Only fences should be surrounded by spaces.
    var isSpaced: Bool {
        self.class == .Fence
    }

    /// Indicates whether the fragment has text-like behavior.
    /// A fragment is considered text-like if its class is not `.Large`.
    var isTextLike: Bool {
        self.class != .Large
    }
}
