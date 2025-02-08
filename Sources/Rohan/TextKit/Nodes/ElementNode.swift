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
        let summary = children.lazy.map(\.lengthSummary).reduce(.zero, +)
        self._contentLength = summary.extrinsicLength
        self._layoutLength = summary.layoutLength
        // flags
        self._isDirty = false

        super.init()

        for child in _children {
            assert(child.parent == nil)
            child.parent = self
        }
    }

    internal init(deepCopyOf elementNode: ElementNode) {
        // children and newlines
        self._children = elementNode._children.map { $0.deepCopy() }
        self._newlines = elementNode._newlines
        // length
        self._contentLength = elementNode._contentLength
        self._layoutLength = elementNode._layoutLength
        // flags
        self._isDirty = false

        super.init()

        for child in _children {
            child.parent = self
        }
    }

    // MARK: - Content

    override final func getChild(_ index: RohanIndex) -> Node? {
        guard let index = index.nodeIndex(),
              index < _children.count
        else { return nil }
        assert(index >= 0)
        return _children[index]
    }

    final var _contentLength: Int
    final var contentLength: Int { @inline(__always) get { _contentLength } }
    override final var extrinsicLength: Int { isOpaque ? 1 : _contentLength }

    override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
        // apply delta
        _contentLength += delta.extrinsicLength
        _layoutLength += delta.layoutLength

        // content change implies dirty
        if inContentStorage { _isDirty = true }

        // change of extrinsic length is not propagated if the node is opaque
        let delta = isOpaque ? delta.with(extrinsicLength: 0) : delta
        // propagate to parent
        parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    private final func contentDidChangeLocally(delta: LengthSummary,
                                               newlinesDelta: Int,
                                               inContentStorage: Bool)
    {
        _contentLength += delta.extrinsicLength
        _layoutLength += delta.layoutLength

        // content change implies dirty
        if inContentStorage { _isDirty = true }

        var delta = delta
        // change to newlines should be added to propagated layout length
        delta.layoutLength += newlinesDelta
        // change of extrinsic length is not propagated if the node is opaque
        if isOpaque { delta.extrinsicLength = 0 }
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

        /*  Process insert newline for the same node */
        func processInsertNewline(_ original: ExtendedRecord, _ current: ExtendedRecord) {
            precondition(original.nodeId == current.nodeId)
            switch (original.insertNewline, current.insertNewline) {
            case (false, false):
                break
            case (false, true):
                context.insertNewline(self)
            case (true, false):
                context.deleteBackwards(1)
            case (true, true):
                context.skipBackwards(1)
            }
        }

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
                processInsertNewline(original[j], current[i])
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
                processInsertNewline(original[j], current[i])
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

    public final var childCount: Int { @inline(__always) get { _children.count } }

    @inline(__always)
    public final func getChild(_ index: Int) -> Node { _children[index] }

    public final func insertChild(
        _ node: Node,
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        let delta = node.lengthSummary

        // perform insert
        _children.insert(node, at: index)

        // update newlines
        var newlinesDelta = -_newlines.trueValueCount
        _newlines.insert(node.isBlock, at: index)
        newlinesDelta += _newlines.trueValueCount

        // post update
        assert(node.parent == nil)
        node.parent = self

        contentDidChangeLocally(delta: delta, newlinesDelta: newlinesDelta,
                                inContentStorage: inContentStorage)
    }

    public final func insertChildren(
        contentsOf nodes: [Node],
        at index: Int,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        let delta = nodes.lazy.map(\.lengthSummary).reduce(.zero, +)

        // perform insert
        _children.insert(contentsOf: nodes, at: index)

        // update newlines
        var newlinesDelta = -_newlines.trueValueCount
        _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)
        newlinesDelta += _newlines.trueValueCount

        // post update
        nodes.forEach {
            assert($0.parent == nil)
            $0.parent = self
        }

        contentDidChangeLocally(delta: delta, newlinesDelta: newlinesDelta,
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

        let delta = -removed.lengthSummary

        // update newlines
        var newlinesDelta = -_newlines.trueValueCount
        _newlines.remove(at: index)
        newlinesDelta += _newlines.trueValueCount

        // post update
        removed.parent = nil

        contentDidChangeLocally(delta: delta, newlinesDelta: newlinesDelta,
                                inContentStorage: inContentStorage)
    }

    public final func removeSubrange(
        _ range: Range<Int>,
        inContentStorage: Bool = false
    ) {
        // pre update
        if inContentStorage { _makeSnapshotOnce() }

        var delta = LengthSummary.zero
        _children[range].forEach {
            $0.parent = nil
            delta -= $0.lengthSummary
        }

        // perform remove
        _children.removeSubrange(range)

        // update newlines
        var newlinesDelta = -_newlines.trueValueCount
        _newlines.removeSubrange(range)
        newlinesDelta += _newlines.trueValueCount

        // post update

        contentDidChangeLocally(delta: delta, newlinesDelta: newlinesDelta,
                                inContentStorage: inContentStorage)
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
        guard let (newRange, delta) = ElementNode.compactSubrange(&_children, range, self)
        else { return false }

        assert(range.lowerBound == newRange.lowerBound)

        // update newlines
        _newlines.removeSubrange(range)
        _newlines.insert(contentsOf: _children[newRange].lazy.map(\.isBlock),
                         at: newRange.lowerBound)

        // post update
        assert(delta == .zero)
        if delta != .zero {
            contentDidChangeLocally(delta: delta, newlinesDelta: 0,
                                    inContentStorage: inContentStorage)
        }

        return true
    }

    /**
     Compact nodes in a range so that there are no neighbouring mergeable nodes.

     - Returns: the new range and the length delta
     */
    internal static func compactSubrange(
        _ nodes: inout [Node],
        _ range: Range<Int>,
        _ parent: Node?
    ) -> (newRange: Range<Int>, delta: LengthSummary)? {
        precondition(range.lowerBound >= 0 && range.upperBound <= nodes.count)

        func isCandidate(_ i: Int) -> Bool {
            nodes[i].nodeType == .text
        }

        func isMergeable(_ i: Int, _ j: Int) -> Bool {
            nodes[i].nodeType == .text && nodes[j].nodeType == .text
        }

        func mergeSubrange(_ range: Range<Int>) -> (node: Node, delta: LengthSummary) {
            let result = nodes[range]
                .lazy.map { $0 as! TextNode }
                .reduce(into: (string: BigString(), extrinsicLength: 0)) {
                    $0.string += $1.bigString
                    $0.extrinsicLength += $1.extrinsicLength
                }
            let node = TextNode(result.string)
            node.parent = parent

            let delta = LengthSummary(
                extrinsicLength: node.extrinsicLength - result.extrinsicLength,
                layoutLength: 0
            )
            return (node, delta)
        }

        var delta = LengthSummary.zero
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
