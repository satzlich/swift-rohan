// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

final class MathGlyphLayoutFragment: MathLayoutFragment {
    /** glyph fragment or variant fragment */
    let _glyph: MathFragment

    init(glyph: MathFragment, nsLength: Int) {
        self._glyph = glyph
        self._nsLength = nsLength
        self._frameOrigin = .zero
    }

    convenience init?(_ char: UnicodeScalar,
                      _ font: Font,
                      _ table: MathTable,
                      _ nsLength: Int)
    {
        guard let glyph = GlyphFragment(char, font, table) else { return nil }
        self.init(glyph: glyph, nsLength: nsLength)
    }

    // MARK: - Frame

    var _frameOrigin: CGPoint

    var layoutFragmentFrame: CGRect {
        let size = CGSize(width: _glyph.width, height: _glyph.height)
        return CGRect(origin: _frameOrigin, size: size)
    }

    func setFrameOrigin(_ origin: CGPoint) {
        _frameOrigin = origin
    }

    // MARK: - Metrics

    var width: Double { _glyph.width }
    var ascent: Double { _glyph.ascent }
    var descent: Double { _glyph.descent }
    var height: Double { _glyph.height }
    var italicsCorrection: Double { _glyph.italicsCorrection }
    var accentAttachment: Double { _glyph.accentAttachment }

    // MARK: - Categories

    var clazz: MathClass { _glyph.clazz }
    var limits: Limits { _glyph.limits }

    // MARK: - Flags

    var isSpaced: Bool { _glyph.isSpaced }
    var isTextLike: Bool { _glyph.isTextLike }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        _glyph.draw(at: point, in: context)
    }

    // MARK: - Length

    var _nsLength: Int
    var nsLength: Int { _nsLength }
}
