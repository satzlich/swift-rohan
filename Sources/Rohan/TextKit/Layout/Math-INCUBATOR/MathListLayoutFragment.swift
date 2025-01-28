// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
    private(set) var _fragments: Deque<any MathLayoutFragment> = []

    // MARK: - Subfragments

    var isEmpty: Bool { _fragments.isEmpty }
    var count: Int { _fragments.count }

    func insert(_ fragment: MathLayoutFragment, at index: Int) {
        _fragments.insert(fragment, at: index)
    }

    func insert(contentsOf fragments: [MathLayoutFragment], at index: Int) {
        _fragments.insert(contentsOf: fragments, at: index)
    }

    func remove(at index: Int) -> MathLayoutFragment {
        return _fragments.remove(at: index)
    }

    func removeSubrange(_ range: Range<Int>) {
        _fragments.removeSubrange(range)
    }

    /**
     Returns the index of the first fragment that is __exactly__ n units
     of `layoutLength` away from i, or nil if no such fragment exists.
     */
    func index(_ i: Int, llOffsetBy n: Int) -> Int? {
        precondition(i >= 0 && i <= count)
        if n >= 0 {
            var j = i
            var s = 0
            // let s(j) = sum { fragments[k].layoutLength | k in [i, j) }
            // result = argmin { s(j) >= n } st. s(j) == n
            while s < n && j < _fragments.count {
                s += _fragments[j].layoutLength
                j += 1
            }
            return n == s ? j : nil
        }
        else {
            let m = -n
            var j = i
            var s = 0
            // let s(j) = sum { fragments[k].layoutLength | k in [j, i) }
            // result = argmax { s(j) >= |n| } st. s(j) == |n|
            while s < m && j > 0 {
                s += _fragments[j - 1].layoutLength
                j -= 1
            }
            return m == s ? j : nil
        }
    }

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

    var layoutLength: Int { 1 }

    // MARK: - Layout

    /**

     - Parameters:
       - startIndex: the index of the first fragment to be updated
     */
    func fragmentsDidChange(_ mathContext: MathContext,
                            _ mathStyle: MathStyle,
                            _ startIndex: Int? = nil)
    {
        let startIndex: Int = {
            let i = startIndex ?? 0
            return self._fragments[...i].lastIndex(where: { $0.clazz != .Vary }) ?? 0
        }()

        // ensure we are processing non-empty fragments
        guard startIndex < _fragments.count else { return }

        let font = mathContext.getFont(for: mathStyle)

        // compute inter-fragment spacing
        let spacings = chain(
            // part 0
            MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))
                .adjacentPairs()
                .lazy.map { MathUtils.resolveSpacing($0, $1, mathStyle) },
            // part 1
            CollectionOfOne(nil)
        )

        // update positions of fragments
        var position = startIndex == 0
            ? CGPoint.zero
            : _fragments[startIndex].layoutFragmentFrame.origin
        for (fragment, spacing) in zip(_fragments[startIndex...], spacings) {
            fragment.setFrameOrigin(position)
            let space = spacing.map { font.convertToPoints($0) } ?? 0
            position.x += fragment.width + space
        }

        // update metrics
        _width = position.x
        _ascent = _fragments.lazy.map(\.ascent).max() ?? 0
        _descent = _fragments.lazy.map(\.descent).max() ?? 0
    }
}
