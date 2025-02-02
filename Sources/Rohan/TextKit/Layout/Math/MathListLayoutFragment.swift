// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
    private var _fragments: Deque<any MathLayoutFragment> = []

    /** index where the left-most modification is made */
    private var _dirtyIndex: Int? = nil

    @inline(__always)
    private func update(dirtyIndex: Int) {
        _dirtyIndex = _dirtyIndex.map { min($0, dirtyIndex) } ?? dirtyIndex
    }

    // MARK: - State

    private var _isEditing: Bool = false
    var isEditing: Bool { @inline(__always) get { _isEditing } }

    func beginEditing() {
        precondition(!isEditing && _dirtyIndex == nil)
        _isEditing = true
    }

    func endEditing() {
        precondition(isEditing)
        _isEditing = false
    }

    // MARK: - Subfragments

    var isEmpty: Bool { @inline(__always) get { _fragments.isEmpty } }
    var count: Int { @inline(__always) get { _fragments.count } }

    func insert(_ fragment: MathLayoutFragment, at index: Int) {
        precondition(isEditing)
        _fragments.insert(fragment, at: index)
        update(dirtyIndex: index)
    }

    func insert(contentsOf fragments: [MathLayoutFragment], at index: Int) {
        precondition(isEditing)
        _fragments.insert(contentsOf: fragments, at: index)
        update(dirtyIndex: index)
    }

    func remove(at index: Int) -> MathLayoutFragment {
        precondition(isEditing)
        let removed = _fragments.remove(at: index)
        update(dirtyIndex: index)
        return removed
    }

    func removeSubrange(_ range: Range<Int>) {
        precondition(isEditing)
        _fragments.removeSubrange(range)
        update(dirtyIndex: range.lowerBound)
    }

    func invalidateSubrange(_ range: Range<Int>) {
        precondition(isEditing)
        update(dirtyIndex: range.lowerBound)
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
    private var _frameOrigin: CGPoint = .zero

    var layoutFragmentFrame: CGRect {
        let size = CGSize(width: width, height: height)
        return CGRect(origin: _frameOrigin, size: size)
    }

    func setFrameOrigin(_ origin: CGPoint) {
        _frameOrigin = origin
    }

    // MARK: Metrics

    private var _width: Double = 0
    private var _ascent: Double = 0
    private var _descent: Double = 0

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

    var clazz: MathClass { _fragments.count == 1 ? _fragments[0].clazz : .Normal }
    var limits: Limits { _fragments.count == 1 ? _fragments[0].limits : .never }

    // MARK: - Flags

    var isSpaced: Bool { _fragments.count == 1 ? _fragments[0].isSpaced : false }
    var isTextLike: Bool { _fragments.count == 1 ? _fragments[0].isTextLike : false }

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
    private var _contentLayoutLength: Int = 0
    var contentLayoutLength: Int { @inline(__always) get { _contentLayoutLength } }

    // MARK: - Layout

    func fixLayout(_ mathContext: MathContext) {
        precondition(!isEditing)

        guard _dirtyIndex != nil else { return }
        defer { _dirtyIndex = nil }

        // find the start index
        let startIndex: Int =
            _fragments[..._dirtyIndex!].lastIndex(where: { $0.clazz != .Vary }) ?? 0

        func updateMetricsLength(_ width: CGFloat) {
            // update metrics
            _width = width
            _ascent = _fragments.lazy.map(\.ascent).max() ?? 0
            _descent = _fragments.lazy.map(\.descent).max() ?? 0
            // update length
            _contentLayoutLength = _fragments.lazy.map(\.layoutLength).reduce(0, +)
        }

        // ensure we are processing non-empty fragments
        guard startIndex < _fragments.count else {
            assert(startIndex == _fragments.count)
            let width = (_fragments.last?.layoutFragmentFrame)
                .map { $0.origin.x + $0.width } ?? 0
            updateMetricsLength(width)
            return
        }

        // compute inter-fragment spacing
        let spacings = chain(
            // part 0
            MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))
                .adjacentPairs()
                .lazy.map { MathUtils.resolveSpacing($0, $1, mathContext.mathStyle) },
            // part 1
            CollectionOfOne(nil)
        )

        let font = mathContext.getFont()

        // update positions of fragments
        var position = startIndex == 0
            ? CGPoint.zero
            : _fragments[startIndex].layoutFragmentFrame.origin
        for (fragment, spacing) in zip(_fragments[startIndex...], spacings) {
            fragment.setFrameOrigin(position)
            let space = spacing.map { font.convertToPoints($0) } ?? 0
            position.x += fragment.width + space
        }

        updateMetricsLength(position.x)
    }
}
