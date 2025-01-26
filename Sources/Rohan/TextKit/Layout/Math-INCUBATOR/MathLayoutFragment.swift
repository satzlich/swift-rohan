// Copyright 2024-2025 Lie Yan

import CoreGraphics
import DequeModule
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment {
    // MARK: - Frame

    func setFrameOrigin(_ origin: CGPoint)

    // MARK: Metrics

    var width: Double { get }
    var ascent: Double { get }
    var descent: Double { get }
    var height: Double { get }
    var italicsCorrection: Double { get }
    var accentAttachment: Double { get }

    // MARK: - Categories

    var clazz: MathClass { get }
    var limits: Limits { get }

    // MARK: - Flags

    var isSpaced: Bool { get }
    var isTextLike: Bool { get }

    // MARK: Length

    var nsLength: Int { get }
}

final class MathListLayoutFragment: MathLayoutFragment {
    var _fragments: Deque<MathLayoutFragment> = []

    // MARK: Frame

    /** origin with respect to enclosing frame */
    var _frameOrigin: CGPoint = .zero

    var layoutFragmentFrame: CGRect {
        CGRect(origin: _frameOrigin,
               size: CGSize(width: width, height: height))
    }

    func setFrameOrigin(_ origin: CGPoint) {
        _frameOrigin = origin
    }

    // MARK: Metrics

    var _width: Double = 0
    var width: Double { _width }
    var ascent: Double { _computeAscent() }
    var descent: Double { _computeDescent() }
    var height: Double { ascent + descent }

    var italicsCorrection: Double { preconditionFailure() }
    var accentAttachment: Double { preconditionFailure() }

    func _computeAscent() -> Double { _fragments.lazy.map(\.ascent).max() ?? .zero }
    func _computeDescent() -> Double { _fragments.lazy.map(\.descent).max() ?? .zero }

    // MARK: - Categories

    var clazz: MathClass { preconditionFailure() }
    var limits: Limits { preconditionFailure() }

    // MARK: - Flags

    var isSpaced: Bool { preconditionFailure() }
    var isTextLike: Bool { preconditionFailure() }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        for fragment in _fragments {
            let point = CGPoint(x: point.x + fragment.layoutFragmentFrame.origin.x,
                                y: point.y + fragment.layoutFragmentFrame.origin.y)
            fragment.draw(at: point, in: context)
        }
    }

    // MARK: Length

    var nsLength: Int { _computeNsLength() }

    func _computeNsLength() -> Int {
        _fragments.lazy.map(\.nsLength).reduce(0, +)
    }

    // MARK: - Helpers

    func _positionSubfragments(_ context: LayoutContext) {
        // TODO: add inter fragment spacing

        // update positions of subfragments
        var position = CGPoint.zero
        for fragment in _fragments {
            fragment.setFrameOrigin(position)
            position.x += fragment.width
        }

        // update width
        _width = position.x
    }
}

final class MathGlyphLayoutFragment: MathLayoutFragment {
    let _glyph: GlyphFragment

    init(glyph: GlyphFragment, nsLength: Int) {
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
