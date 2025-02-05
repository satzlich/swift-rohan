// Copyright 2024-2025 Lie Yan

import _RopeModule
import Algorithms
import BitCollections

public class ElementNode: Node {
    final var _children: [Node]

    public init(_ children: [Node] = []) {
        // children and newlines
        self._children = children
        self._newlines = NewlineArray(children.lazy.map(\.isBlock))

        // length
        let summary = children.lazy.map(\._summary).reduce(.zero, +)
        self._length = summary.length
        self._intrinsicLength = summary.extrinsicLength
        self._layoutLength = summary.layoutLength

        // flags
        self._isDirty = false

        super.init()

        _children.forEach {
            assert($0.parent == nil)
            $0.parent = self
        }
    }

    internal init(deepCopyOf elementNode: ElementNode) {
        // children and newlines
        self._children = elementNode._children.map { $0.deepCopy() }
        self._newlines = elementNode._newlines
        // length
        self._length = elementNode._length
        self._intrinsicLength = elementNode._intrinsicLength
        self._layoutLength = elementNode._layoutLength
        // flags
        self._isDirty = false

        super.init()
        _children.forEach {
            // assert($0.parent == nil)
            $0.parent = self
        }
    }

    // MARK: - Content

    final var _intrinsicLength: Int
    override final var intrinsicLength: Int { @inline(__always) get { _intrinsicLength } }

    override final func contentDidChange(delta: Summary, inContentStorage: Bool) {
        // apply delta
        _length += delta.length
        _intrinsicLength += delta.extrinsicLength
        _layoutLength += delta.layoutLength

        // content change implies dirty
        if inContentStorage { _isDirty = true }

        // change of extrinsic length is not propagated if the node is opaque
        let delta = isTransparent ? delta : delta.with(extrinsicLength: 0)
        // propagate to parent
        parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    // MARK: - Layout

    /** layout length excluding newlines */
    final var _layoutLength: Int
    /** true if a newline should be added after i-th child */
    final var _newlines: NewlineArray

    override final var layoutLength: Int { _layoutLength + _newlines.trueValueCount }

    override final var isBlock: Bool { NodeType.blockElements.contains(nodeType) }

    final var _isDirty: Bool
    override final var isDirty: Bool { @inline(__always) get { _isDirty } }

    /** lossy snapshot of original children */
    private final var _original: [SnapshotRecord]? = nil

    /** make snapshot once */
    private final func _makeSnapshotOnce() {
        guard _original == nil else { return }
        assert(_children.count == _newlines.count)
        _original = zip(_children, _newlines.asBitArray)
            .map { SnapshotRecord($0, $1) }
    }

    private final func _performLayoutSimple(_ context: LayoutContext) {
        precondition(_original == nil && _children.count == _newlines.count)

        var i = _children.count - 1

        while true {
            if i < 0 { break }

            // skip clean
            while i >= 0 && !_children[i].isDirty {
                if _newlines[i] { context.skipBackwards(1) }
                context.skipBackwards(_children[i].layoutLength)
                i -= 1
            }
            assert(i < 0 || _children[i].isDirty)

            // process dirty
            if i >= 0 {
                if _newlines[i] { context.skipBackwards(1) }
                _children[i].performLayout(context)
                i -= 1
            }
        }
    }

    private final func _performLayoutFull(_ context: LayoutContext) {
        precondition(_original != nil && _children.count == _newlines.count)

        // ID's of current children
        let currentIds = Set(_children.map(\.id))
        // ID's of dirty (current) children
        let dirtyIds = Set(_children.lazy.filter(\.isDirty).map(\.id))
        // ID's of original children
        let originalIds = Set(_original!.map(\.nodeId))

        // records of current children
        let current: [ExtendedRecord] = zip(_children, _newlines.asBitArray)
            .map { (node, insertNewline) in
                let mark: LayoutMark =
                    !originalIds.contains(node.id)
                    ? .added
                    : (node.isDirty ? .dirty : .none)
                return ExtendedRecord(mark, node, insertNewline)
            }
        // records of original children
        let original: [ExtendedRecord] = _original!.map { record in
            !currentIds.contains(record.nodeId)
                ? ExtendedRecord(.deleted, record)
                : dirtyIds.contains(record.nodeId)
                ? ExtendedRecord(.dirty, record)
                : ExtendedRecord(.none, record)
        }

        var i = current.count - 1
        var j = original.count - 1

        // invariant:
        //  [cursor, ...) is consistent with (i, ...)
        //  [0, cursor) is consistent with [0, j]
        while true {
            if i < 0 && j < 0 { break }

            // process added and deleted
            // (It doesn't matter whether to process add or delete first.)
            while i >= 0 && current[i].mark == .added {
                if current[i].insertNewline { context.insertNewline(self) }
                _children[i].performLayout(context, fromScratch: true)
                i -= 1
            }
            assert(i < 0 || Meta.matches(current[i].mark, .none, .dirty))

            while j >= 0 && original[j].mark == .deleted {
                if original[j].insertNewline { context.deleteBackwards(1) }
                context.deleteBackwards(original[j].layoutLength)
                j -= 1
            }
            assert(j < 0 || Meta.matches(original[j].mark, .none, .dirty))

            // skip none
            while i >= 0 && current[i].mark == .none {
                assert(j >= 0 && original[j].mark == .none)
                assert(current[i].nodeId == original[j].nodeId)
                if current[i].insertNewline { context.skipBackwards(1) }
                context.skipBackwards(current[i].layoutLength)
                i -= 1
                j -= 1
            }
            assert(i < 0 || Meta.matches(current[i].mark, .added, .dirty))
            assert(j < 0 || Meta.matches(original[j].mark, .deleted, .dirty))

            // process added or deleted by iterating again
            if i >= 0 && current[i].mark == .added { continue }
            if j >= 0 && original[j].mark == .deleted { continue }

            // process dirty
            assert(i < 0 || current[i].mark == .dirty)
            assert(j < 0 || original[j].mark == .dirty)
            if i >= 0 {
                assert(j >= 0 && current[i].nodeId == original[j].nodeId)
                assert(current[i].mark == .dirty && original[j].mark == .dirty)

                switch (original[i].insertNewline, current[i].insertNewline) {
                case (false, false):
                    break
                case (false, true):
                    context.insertNewline(self)
                case (true, false):
                    context.deleteBackwards(1)
                case (true, true):
                    context.skipBackwards(1)
                }
                _children[i].performLayout(context)
                i -= 1
                j -= 1
            }
        }
    }

    private final func _performLayoutFromScratch(_ context: LayoutContext) {
        precondition(_children.count == _newlines.count)

        zip(_children, _newlines.asBitArray)
            .reversed()
            .forEach { (node, insertNewline) in
                if insertNewline { context.insertNewline(self) }
                node.performLayout(context, fromScratch: true)
            }
    }

    override final func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        if fromScratch {
            _performLayoutFromScratch(context)
        }
        else if _original == nil {
            _performLayoutSimple(context)
        }
        else {
            _performLayoutFull(context)
        }

        // clear
        _isDirty = false
        _original = nil
    }

    // MARK: - Children

    @inline(__always)
    public final func childCount() -> Int { _children.count }

    @inline(__always)
    public final func getChild(_ index: Int) -> Node { _children[index] }

    public final func insertChild(
        _ node: Node,
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = node._summary

        // perform insert
        _children.insert(node, at: index)

        // update newlines
        delta.layoutLength -= _newlines.trueValueCount
        _newlines.insert(node.isBlock, at: index)
        delta.layoutLength += _newlines.trueValueCount

        // post update
        assert(node.parent == nil)
        node.parent = self

        contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    public final func insertChildren(
        contentsOf nodes: [Node],
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = nodes.lazy.map(\._summary).reduce(.zero, +)

        // perform insert
        _children.insert(contentsOf: nodes, at: index)

        // update newlines
        delta.layoutLength -= _newlines.trueValueCount
        _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)
        delta.layoutLength += _newlines.trueValueCount

        // post update
        nodes.forEach {
            assert($0.parent == nil)
            $0.parent = self
        }

        contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    public final func removeChild(
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        // perform remove
        let removed = _children.remove(at: index)

        var delta = -removed._summary

        // update newlines
        delta.layoutLength -= _newlines.trueValueCount
        _newlines.remove(at: index)
        delta.layoutLength += _newlines.trueValueCount

        // post update
        removed.parent = nil

        contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    public final func removeSubrange(
        _ range: Range<Int>,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = Summary.zero
        _children[range].forEach {
            $0.parent = nil
            delta -= $0._summary
        }

        // perform remove
        _children.removeSubrange(range)

        // update newlines
        delta.layoutLength -= _newlines.trueValueCount
        _newlines.removeSubrange(range)
        delta.layoutLength += _newlines.trueValueCount

        // post update
        contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    /**
     Compact mergeable nodes in a range
     - Returns: true if compacted
     */
    internal final func compactSubrange(_ range: Range<Int>,
                                        inContentStorage: Bool) -> Bool
    {
        guard range.count > 1 else { return false }

        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        // perform compact
        guard let (newRange, delta) = Self.compactSubrange(&_children, range, self)
        else { return false }

        assert(range.lowerBound == newRange.lowerBound)

        // update newlines
        _newlines.removeSubrange(range)
        _newlines.insert(contentsOf: _children[newRange].lazy.map(\.isBlock),
                         at: newRange.lowerBound)

        // post update
        assert(delta == .zero)
        if delta != .zero {
            contentDidChange(delta: delta, inContentStorage: inContentStorage)
        }

        return true
    }

    /**
     Compact mergeable nodes in a range
     - Returns: the new range and the length delta
     */
    internal static func compactSubrange(
        _ nodes: inout [Node],
        _ range: Range<Int>,
        _ parent: Node?
    ) -> (newRange: Range<Int>, delta: Summary)? {
        precondition(range.lowerBound >= 0 && range.upperBound <= nodes.count)

        func isCandidate(_ i: Int) -> Bool {
            nodes[i].nodeType == .text
        }

        func isMergeable(_ i: Int, _ j: Int) -> Bool {
            nodes[i].nodeType == .text && nodes[j].nodeType == .text
        }

        func mergeSubrange(_ range: Range<Int>) -> (node: Node, delta: Summary) {
            let result = nodes[range]
                .lazy.map { $0 as! TextNode }
                .reduce(into: (string: BigString(), length: 0)) {
                    $0.string += $1.bigString
                    $0.length += $1.length
                }
            let node = TextNode(result.string)
            node.parent = parent
            return (node, Summary(length: node.length - result.length,
                                  extrinsicLength: node.length - result.length,
                                  layoutLength: 0))
        }

        var delta = Summary.zero
        var i = range.lowerBound
        var j = i
        // invariant:
        //  (a) j <= upperBound;
        //  (b) i <= j;
        //  (c) current[..< i] is the compact result of original[..< j];
        //  (d) current[i ..< j] is vacuum.
        while j < range.upperBound {
            if !isCandidate(j) {
                if i != j { nodes[i] = nodes[j] }
                i += 1
                j += 1
            }
            else {
                // merge as much as possible
                var k = j + 1
                // invariant: [j, k) is mergeable
                while k < range.upperBound && isMergeable(j, k) {
                    k += 1
                }
                if j + 1 == k { // only one node
                    if i != j { nodes[i] = nodes[j] }
                    i += 1
                    j = k
                }
                else { // multiple nodes
                    let merged = mergeSubrange(j ..< k)
                    nodes[i] = merged.node
                    delta += merged.delta
                    i += 1
                    j = k
                }
            }
        }
        assert(j == range.upperBound)
        // remove vacuum
        guard i != j else { return nil }
        nodes.removeSubrange(i ..< j)
        return (range.lowerBound ..< i, delta)
    }

    // MARK: - Length & Location

    /** length excluding start & end padding */
    final var _length: Int

    override final var length: Int {
        _length + startPadding.intValue + endPadding.intValue
    }

    override class var startPadding: Bool { true }
    override class var endPadding: Bool { true }

    override final func getChild(_ index: RohanIndex) -> Node? {
        switch index {
        case let .stableOffset(stableOffset):
            let (_, index, _) = _getLocation(stableOffset.locatingValue)
            return index.map { i in _children[i] }
        case let .arrayIndex(index):
            guard index < _children.count else { return nil }
            return _children[index]
        default:
            return nil
        }
    }

    override final func getOffset(before index: RohanIndex) -> Int {
        switch index {
        case let .stableOffset(stableOffset):
            return stableOffset.offset
        case let .arrayIndex(i):
            assert(i <= _children.count)
            return startPadding.intValue + _children[..<i].lazy.map(\.length).reduce(0, +)
        default:
            fatalError("Expect stable offset or array index")
        }
    }

    /** Given an offset, returns the stable offset and the index for accessing the
     child node, and the remainder of the offset within the child node. */
    @inline(__always)
    private final func _getLocation(_ offset: Int) -> (offset: StableOffset,
                                                       index: Int?,
                                                       offsetRemainder: Int)
    {
        precondition(offset >= startPadding.intValue &&
            offset <= length - endPadding.intValue)

        func isText(_ node: Node) -> Bool { node.nodeType == .text }

        // shave start padding
        let m = offset - startPadding.intValue

        // special boundary case: m == 0
        if m == 0 {
            if !_children.isEmpty,
               !_children[0].startPadding,
               !isText(_children[0])
            { // recurse on 0-th
                return (StableOffset(offset, false), 0, 0)
            }
            else { // stop recursion
                return (StableOffset(offset, false), nil, 0)
            }
        }

        assert(m > 0 && !_children.isEmpty)

        var s = startPadding.intValue
        // invariant:
        //  s = sum { length | 0 ..< i } + startPadding
        //  s < offset
        for (i, node) in _children.enumerated() {
            let n = s + node.length
            if n < offset { // move on
                s = n
            }
            else if n == offset { // boundary
                // if the node is non-text and has no end padding
                if !isText(node) && !node.endPadding {
                    // recurse on i-th
                    return (StableOffset(s, node.startPadding), i, offset - s)
                }
                // if there is a next sibling which is non-text and has no start padding
                else if i + 1 < _children.count,
                        !isText(_children[i + 1]),
                        !_children[i + 1].startPadding
                {
                    // recurse on (i+1)-th
                    return (StableOffset(offset, false), i + 1, 0)
                }
                // no way to go
                else {
                    // stop recursion
                    return (StableOffset(offset, false), nil, 0)
                }
            }
            else { // n > offset
                if !isText(node) {
                    return (StableOffset(s, node.startPadding), i, offset - s)
                }
                else {
                    return (StableOffset(offset, false), nil, 0)
                }
            }
        }
        assertionFailure("impossible")
        return (StableOffset(offset, false), nil, 0)
    }

    override final func _getLocation(_ offset: Int, _ path: inout [RohanIndex]) -> Int {
        // post-condition:
        //  (a) (path, offset') is the left-most, deepest path corresponding to
        //      the offset;
        //  (b) positions immediately before start padding or immediately after
        //      end padding are not allowed;
        //  (c) text node is regarded as expanded inplace

        let (stableOffset, index, offsetRemainder) = _getLocation(offset)
        if index != nil {
            path.append(.stableOffset(stableOffset))
            return _children[index!]._getLocation(offsetRemainder, &path)
        }
        else {
            assert(stableOffset.offset == offset)
            return offset
        }
    }
}

// MARK: - Implementation Facilities for Layout

private struct SnapshotRecord {
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let layoutLength: Int

    init(_ node: Node, _ insertNewline: Bool) {
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.layoutLength = node.layoutLength
    }
}

private enum LayoutMark { case none; case dirty; case deleted; case added }

private struct ExtendedRecord {
    let mark: LayoutMark
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let layoutLength: Int

    init(_ mark: LayoutMark, _ record: SnapshotRecord) {
        self.mark = mark
        self.nodeId = record.nodeId
        self.insertNewline = record.insertNewline
        self.layoutLength = record.layoutLength
    }

    init(_ node: Node, _ insertNewline: Bool) {
        self.mark = node.isDirty ? .dirty : .none
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.layoutLength = node.layoutLength
    }

    init(_ mark: LayoutMark, _ node: Node, _ insertNewline: Bool) {
        self.mark = mark
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.layoutLength = node.layoutLength
    }
}
