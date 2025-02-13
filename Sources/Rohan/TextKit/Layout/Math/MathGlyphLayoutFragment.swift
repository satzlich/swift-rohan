// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

final class MathGlyphLayoutFragment: MathLayoutFragment {
    private let _glyph: GlyphFragment

    init(_ glyph: GlyphFragment, _ layoutLength: Int) {
        self._glyph = glyph
        self.layoutLength = layoutLength
        self._frameOrigin = .zero
    }

    convenience init?(_ char: UnicodeScalar,
                      _ font: Font,
                      _ table: MathTable,
                      _ layoutLength: Int)
    {
        guard let glyph = GlyphFragment(char, font, table) else { return nil }
        self.init(glyph, layoutLength)
    }

    // MARK: - Frame

    private var _frameOrigin: CGPoint

    var glyphFrame: CGRect {
        let size = CGSize(width: _glyph.width, height: _glyph.height)
        return CGRect(origin: _frameOrigin, size: size)
    }

    func setGlyphOrigin(_ origin: CGPoint) {
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

    let layoutLength: Int
}
