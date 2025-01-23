// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections

public class ElementNode: Node {
    @usableFromInline final var _children: [Node]
    @usableFromInline final var _newlines: NewlineArray

    override final func _getChild(_ index: RohanIndex) -> Node? {
        guard let i = index.arrayIndex()?.index,
              i < _children.count
        else { return nil }
        return _children[i]
    }

    override final func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        _nsLength += delta.nsLength
        _length += delta.length
        // content change implies dirty
        if inContentStorage { _isDirty = true }
        super._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    public init(_ children: [Node] = []) {
        self._children = children
        self._newlines = NewlineArray(children.map(\.isBlock))
        self._nsLength = children.reduce(0) { $0 + $1.nsLength }
        self._length = children.reduce(0) { $0 + $1.length }
        super.init()
        _children.forEach {
            assert($0.parent == nil)
            $0.parent = self
        }
    }

    internal init(deepCopyOf elementNode: ElementNode) {
        self._children = elementNode._children.map { $0.deepCopy() }
        self._newlines = elementNode._newlines
        self._nsLength = elementNode._nsLength
        self._length = elementNode._length
        super.init()
        _children.forEach {
            // assert($0.parent == nil)
            $0.parent = self
        }
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
            .map { SnapshotRecord($0, $1) }
    }

    private final func _performLayoutSimple(_ context: RhLayoutContext) {
        precondition(_original == nil && _children.count == _newlines.count)

        var i = _children.count - 1

        while true {
            if i < 0 { break }

            // skip clean
            while i >= 0 && !_children[i].isDirty {
                if _newlines[i] { context.skipBackwards(1) }
                context.skipBackwards(_children[i].nsLength)
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

    private final func _performLayoutFull(_ context: RhLayoutContext) {
        precondition(_original != nil && _children.count == _newlines.count)

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
        precondition(_children.count == _newlines.count)

        zip(_children, _newlines.asBitArray)
            .reversed()
            .forEach { (node, insertNewline) in
                if insertNewline { context.insertNewline() }
                node.performLayout(context, fromScratch: true)
            }
    }

    override final func performLayout(_ context: RhLayoutContext, fromScratch: Bool) {
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
        assert(node.parent == nil)
        node.parent = self
        _onContentChange(delta: delta, inContentStorage: inContentStorage)
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
        nodes.forEach {
            assert($0.parent == nil)
            $0.parent = self
        }
        _onContentChange(delta: delta, inContentStorage: inContentStorage)
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
        _children[range].forEach {
            $0.parent = nil
            delta -= $0._summary
        }

        // perform remove
        _children.removeSubrange(range)
        delta.nsLength -= _newlines.trueValueCount
        _newlines.removeSubrange(range)
        delta.nsLength += _newlines.trueValueCount

        // post update
        _onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    // MARK: - Length & Location

    /** nsLength excluding newlines */
    final var _nsLength: Int
    override final var nsLength: Int { _nsLength + _newlines.trueValueCount }

    /** length excluding start & end padding */
    final var _length: Int

    override final var length: Int {
        _length + Self.startPadding.intValue + Self.endPadding.intValue
    }

    override class var startPadding: Bool { true }
    override class var endPadding: Bool { true }

    override func _partialLength(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.index else { fatalError("invalid index") }
        assert(i <= _children.count)
        return Self.startPadding.intValue + _children[..<i].reduce(0) { $0 + $1.length }
    }

    override final func _locate(_ offset: Int, _ path: inout [RohanIndex]) -> Int? {
        precondition(offset >= Self.startPadding.intValue &&
            offset <= length - Self.endPadding.intValue)

        func index(_ i: Int) -> RohanIndex { .arrayIndex(i) }

        // shave start padding
        let offset = offset - Self.startPadding.intValue

        // special case: offset == 0
        if offset == 0 {
            if !_children.isEmpty,
               !_children[0].startPadding
            { // recurse on 0-th
                path.append(index(0))
                return _children[0]._locate(0, &path)
            }
            else { // stop recursion
                path.append(index(0))
                return nil
            }
        }

        assert(offset > 0)

        var s = 0
        // invariant: s = sum { length | 0 ..< i }
        for (i, node) in _children.enumerated() {
            let n = s + node.length
            if n < offset { // move on
                s = n
            }
            else if n == offset { // boundary
                if !node.endPadding { // recurse on i-th
                    path.append(index(i))
                    return node._locate(offset - s, &path)
                }
                else if i + 1 < _children.count &&
                    !_children[i + 1].startPadding
                { // recurse on (i+1)-th
                    path.append(index(i + 1))
                    return _children[i + 1]._locate(0, &path)
                }
                else { // stop recursion
                    path.append(index(i + 1))
                    return nil
                }
            }
            else { // n > offset
                path.append(index(i))
                return node._locate(offset - s, &path)
            }
        }
        assertionFailure()
        return nil
    }
}

// MARK: - Implementation Facilities for Layout

private struct SnapshotRecord {
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let length: Int
    let nsLength: Int

    @inline(__always)
    init(_ node: Node, _ insertNewline: Bool) {
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
    init(_ node: Node, _ insertNewline: Bool) {
        self.mark = node.isDirty ? .dirty : .none
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.length = node.length
        self.nsLength = node.nsLength
    }

    @inline(__always)
    init(_ mark: LayoutMark, _ node: Node, _ insertNewline: Bool) {
        self.mark = mark
        self.nodeId = node.id
        self.insertNewline = insertNewline
        self.length = node.length
        self.nsLength = node.nsLength
    }
}
