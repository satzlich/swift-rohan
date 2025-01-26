// Copyright 2024-2025 Lie Yan

import CoreGraphics
import DequeModule
import UnicodeMathClass

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
    var _ascent: Double = 0
    var _descent: Double = 0

    var width: Double { _width }
    var ascent: Double { _ascent }
    var descent: Double { _descent }
    var height: Double { ascent + descent }

    var italicsCorrection: Double {
        _fragments.count == 1 ? _fragments[0].italicsCorrection : 0
    }

    var accentAttachment: Double {
        _fragments.count == 1 ? _fragments[0].accentAttachment : _width / 2
    }

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

    var _nsLength: Int = 0
    var nsLength: Int { _nsLength }

    // MARK: - Helpers

    func _performLayout(_ context: LayoutContext) {
        // TODO: add inter fragment spacing

        // update positions of subfragments
        var position = CGPoint.zero
        for fragment in _fragments {
            fragment.setFrameOrigin(position)
            position.x += fragment.width
        }

        // update metrics
        _width = position.x
        _ascent = _fragments.lazy.map(\.ascent).max() ?? 0
        _descent = _fragments.lazy.map(\.descent).max() ?? 0

        // update nsLength
        _nsLength = _fragments.lazy.map(\.nsLength).reduce(0, +)
    }
}
