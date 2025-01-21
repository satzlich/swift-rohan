// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections
import OrderedCollections

public class ElementNode: Node {
    @usableFromInline final var _children: [Node]
    final var _newlines: NewlineArray

    private final var _length: Int
    override final var length: Int { _length }
    /** nsLength excluding newlines */
    private final var _nsLength: Int
    override final var nsLength: Int { _nsLength + _newlines.trueValueCount }

    public init(_ children: [Node] = []) {
        self._children = children
        self._newlines = NewlineArray(children.map(\.isBlock))
        self._length = children.reduce(0) { $0 + $1.length }
        self._nsLength = children.reduce(0) { $0 + $1.nsLength }
        super.init()
        _children.forEach { $0.parent = self }
    }

    internal init(deepCopyOf elementNode: ElementNode) {
        self._children = elementNode._children.map { $0.deepCopy() }
        self._newlines = elementNode._newlines
        self._length = elementNode._length
        self._nsLength = elementNode._nsLength
        super.init()
        _children.forEach { $0.parent = self }
    }

    override public func deepCopy() -> ElementNode { preconditionFailure() }

    // MARK: - Layout

    override final var isBlock: Bool { NodeType.blockElements.contains(nodeType) }

    final var _isDirty: Bool = false
    override final var isDirty: Bool { _isDirty }

    /** lossy snapshot of original children */
    private final var _original: [SnapshotRecord]? = nil

    /** make snapshot once */
    @inline(__always)
    private final func _makeSnapshotOnce() {
        guard _original == nil else { return }
        assert(_children.count == _newlines.count)
        _original = zip(_children, _newlines.asBitArray)
            .map { SnapshotRecord($0, insertNewline: $1) }
    }

    private final func _performLayoutSimple(_ context: RhLayoutContext) {
        precondition(isDirty)

        var i = _children.count - 1

        while true {
            if i < 0 { break }

            // skip clean
            while i >= 0 && !_children[i].isDirty {
                if _newlines.at(i) { context.skipBackwards(1) }
                context.skipBackwards(_children[i].nsLength)
                i -= 1
            }
            assert(i < 0 || _children[i].isDirty)

            // process dirty
            if i >= 0 {
                if _newlines.at(i) { context.skipBackwards(1) }
                _children[i].performLayout(context)
                i -= 1
            }
        }
    }

    private final func _performLayoutFull(_ context: RhLayoutContext) {
        precondition(_original != nil)

        // ID's of current children
        let currentIds = Set(_children.map(\.id))
        // ID's of dirty (current) children
        let dirtyIds = Set(_children.filter(\.isDirty).map(\.id))
        // ID's of original children
        let originalIds = Set(_original!.map(\.nodeId))

        // records of current children
        let current: [ExtendedRecord] = zip(_children, _newlines.asBitArray)
            .map { (node, insertNewline) in
                let mark: LayoutMark =
                    !originalIds.contains(node.id)
                    ? .added
                    : (node.isDirty ? .dirty : .none)
                return ExtendedRecord(mark, node, insertNewline: insertNewline)
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
        //  [k, ...) is consistent with (i, ...)
        //  [0, k) is consistent with [0, j]
        while true {
            if i < 0 && j < 0 { break }

            // process added and deleted
            do {
                // We add after cursor and delete before cursor.
                // So it doesn't matter whether we perform add or delete first.
                while i >= 0 && current[i].mark == .added {
                    if current[i].insertNewline { context.insertNewline() }
                    _children[i].performLayout(context, fromScratch: true)
                    i -= 1
                }
                assert(i < 0 || [.none, .dirty].contains(current[i].mark))

                while j >= 0 && original[j].mark == .deleted {
                    if original[j].insertNewline { context.deleteBackwards(1) }
                    context.deleteBackwards(original[j].nsLength)
                    j -= 1
                }
                assert(j < 0 || [.none, .dirty].contains(original[j].mark))
            }

            // skip none
            while i >= 0 && current[i].mark == .none {
                assert(j >= 0 && original[j].mark == .none)
                assert(current[i].nodeId == original[j].nodeId)
                if current[i].insertNewline { context.skipBackwards(1) }
                context.skipBackwards(current[i].nsLength)
                i -= 1
                j -= 1
            }
            assert(i < 0 || [.dirty, .added].contains(current[i].mark))
            assert(j < 0 || [.dirty, .deleted].contains(original[j].mark))

            // process added or deleted by iterate again
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
                    context.insertNewline()
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

    private final func _performLayoutFromScratch(_ context: RhLayoutContext) {
        zip(_children, _newlines.asBitArray)
            .reversed()
            .forEach { (node, insertNewline) in
                if insertNewline { context.insertNewline() }
                node.performLayout(context, fromScratch: true)
            }
    }

    override func performLayout(_ context: RhLayoutContext, fromScratch: Bool) {
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

    // MARK: - Location and Length

    override final func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)

        func index(_ i: Int) -> RohanIndex { .arrayIndex(i) }

        var s = 0
        // invariant: s = sum { length | 0 ..< i }
        for (i, node) in _children.enumerated() {
            let n = s + node.length
            if n < offset { // make progress
                s = n
            }
            else if n == offset,
                    affinity == .downstream,
                    i + 1 < _children.count
            { // boundary
                return (index(i + 1), 0)
            }
            else { // found
                return (index(i), offset - s)
            }
        }
        assert(s == 0)
        return nil
    }

    override final func _getChild(_ index: RohanIndex) -> Node? {
        guard let i = index.arrayIndex()?.index else { return nil }
        assert(i <= _children.count)
        return getChild(i)
    }

    override final func _length(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.index else { fatalError("invalid index") }
        assert(i <= _children.count)
        return _children[..<i].reduce(0) { $0 + $1.length }
    }

    override final func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        _length += delta.length
        _nsLength += delta.nsLength
        if inContentStorage {
            // content change implies dirty
            _isDirty = true
        }
        super._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    // MARK: - Children

    @inlinable
    public final func childCount() -> Int { _children.count }

    @inlinable
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
        delta.nsLength -= _newlines.trueValueCount
        _newlines.insert(node.isBlock, at: index)
        delta.nsLength += _newlines.trueValueCount

        // post update
        node.parent = self
        _onContentChange(delta: node._summary, inContentStorage: inContentStorage)
    }

    public final func insertChildren(
        contentsOf nodes: [Node],
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = nodes.reduce(.zero) { $0 + $1._summary }

        // perform insert
        _children.insert(contentsOf: nodes, at: index)

        delta.nsLength -= _newlines.trueValueCount
        _newlines.insert(contentsOf: nodes.map(\.isBlock), at: index)
        delta.nsLength += _newlines.trueValueCount

        // post update
        nodes.forEach { $0.parent = self }
        _onContentChange(delta: delta,
                         inContentStorage: inContentStorage)
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
        delta.nsLength -= _newlines.trueValueCount
        _newlines.remove(at: index)
        delta.nsLength += _newlines.trueValueCount

        // post update
        removed.parent = nil
        _onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    public final func removeSubrange(
        _ range: Range<Int>,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = _Summary.zero
        for node in _children[range] {
            node.parent = nil
            delta -= node._summary
        }

        // perform remove
        _children.removeSubrange(range)
        delta.nsLength -= _newlines.trueValueCount
        _newlines.removeSubrange(range)
        delta.nsLength += _newlines.trueValueCount

        // post update
        _onContentChange(delta: delta, inContentStorage: inContentStorage)
    }
}

// MARK: - Layout Facility

private struct SnapshotRecord {
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let length: Int
    let nsLength: Int

    @inline(__always)
    init(_ node: Node, insertNewline: Bool) {
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.length = node.length
        self.nsLength = node.nsLength
    }
}

private enum LayoutMark { case none; case dirty; case deleted; case added }

private struct ExtendedRecord {
    let mark: LayoutMark
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let length: Int
    let nsLength: Int

    @inline(__always)
    init(_ mark: LayoutMark, _ record: SnapshotRecord) {
        self.mark = mark
        self.nodeId = record.nodeId
        self.insertNewline = record.insertNewline
        self.length = record.length
        self.nsLength = record.nsLength
    }

    @inline(__always)
    init(_ node: Node, insertNewline: Bool) {
        self.mark = node.isDirty ? .dirty : .none
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.length = node.length
        self.nsLength = node.nsLength
    }

    @inline(__always)
    init(_ mark: LayoutMark, _ node: Node, insertNewline: Bool) {
        self.mark = mark
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.length = node.length
        self.nsLength = node.nsLength
    }
}
