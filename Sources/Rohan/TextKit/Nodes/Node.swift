// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@usableFromInline
@DebugDescription
struct NodeIdentifier: Equatable, Hashable, CustomDebugStringConvertible {
    @usableFromInline static var _counter: Int = 1
    @usableFromInline let _id: Int

    @inlinable
    init() {
        self._id = NodeIdentifier._counter
        NodeIdentifier._counter += 1
    }

    @usableFromInline
    var debugDescription: String { "\(_id)" }
}

public class Node {
    @usableFromInline
    internal final weak var parent: Node?

    @usableFromInline
    internal final var id: NodeIdentifier = .init()

    class var nodeType: NodeType { .unknown }
    final var nodeType: NodeType { Self.nodeType }

    // MARK: - Layout

    /** Returns true if the node is a block element. */
    var isBlock: Bool { preconditionFailure("overriding required") }

    var isDirty: Bool { preconditionFailure("overriding required") }

    /**
     Perform layout.

     - Postcondition: layout inconsistency and its indicators are cleared.
     */
    func performLayout(_ context: RhLayoutContext, fromScratch: Bool = false) {
        preconditionFailure("overriding required")
    }

    // MARK: - Location and Length

    /**
     Convert input `offset` to `(path, offset')` where `path` points to a leaf node.

     - Returns: `(path, offset')` where `path` is a list of indices to a leaf node
     and `offset'` is the offset within the node

     - Precondition: argument `offset` must be in range `[0, length]`
     */
    public final func locate(
        _ offset: Int,
        _ affinity: SelectionAffinity = .upstream
    ) -> (path: [RohanIndex], offset: Int) {
        precondition(offset >= 0 && offset <= length)
        var path = [RohanIndex]()
        var offset = offset

        var node: Node = self
        while true {
            if let (index, offset_) = node._childIndex(for: offset, affinity) {
                path.append(index)
                offset = offset_
                // make progress
                node = node._getChild(index)!
            }
            else {
                break
            }
        }
        return (path, offset)
    }

    /**
     Returns the offset from the start of the node that corresponds to the given path.
     */
    public final func offset(_ path: [RohanIndex]) -> Int {
        var offset = 0
        var node: Node? = self

        for index in path {
            offset += node!._length(before: index)
            // make progress
            node = node!._getChild(index)
        }
        return offset
    }

    /**
     Returns the index of the child that contains the given offset. Ties are broken
     by affinity.

     - Returns: `(index, offset)` where `offset` is the offset from the start of
     the child; or `nil` if not found

     - Complexity: `O(n)`
     */
    internal func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        preconditionFailure("overriding required")
    }

    /**
     Return the child at the specified index.

     - Complexity: `O(1)`
     - Warning: Reference uniqueness is not guaranteed.
     */
    internal func _getChild(_ index: RohanIndex) -> Node? {
        preconditionFailure("overriding required")
    }

    /**
     Returns the length of the node's prefix before the given index.

     - Complexity: `O(n)`
     */
    internal func _length(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required")
    }

    // MARK: - Clone and Visitor

    /** Returns a deep copy of the node. Extrinsic state is not copied. */
    public func deepCopy() -> Node {
        preconditionFailure("overriding required")
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure("overriding required")
    }

    // MARK: - Length

    var length: Int { preconditionFailure("overriding required") }
    var nsLength: Int { preconditionFailure("overriding required") }

    final var _summary: _Summary { _Summary(length: length, nsLength: nsLength) }

    internal func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        parent?._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    struct _Summary: Equatable, Hashable {
        var length: Int
        var nsLength: Int

        init(length: Int, nsLength: Int) {
            self.length = length
            self.nsLength = nsLength
        }

        func with(length: Int) -> Self {
            _Summary(length: length, nsLength: nsLength)
        }

        func with(nsLength: Int) -> Self {
            _Summary(length: length, nsLength: nsLength)
        }

        static let zero = _Summary(length: 0, nsLength: 0)

        static func + (lhs: _Summary, rhs: _Summary) -> _Summary {
            _Summary(length: lhs.length + rhs.length,
                     nsLength: lhs.nsLength + rhs.nsLength)
        }

        static func += (lhs: inout _Summary, rhs: _Summary) {
            lhs = lhs + rhs
        }

        static func - (lhs: _Summary, rhs: _Summary) -> _Summary {
            _Summary(length: lhs.length - rhs.length,
                     nsLength: lhs.nsLength - rhs.nsLength)
        }

        static func -= (lhs: inout _Summary, rhs: _Summary) {
            lhs = lhs - rhs
        }

        static prefix func - (summary: _Summary) -> _Summary {
            _Summary(length: -summary.length,
                     nsLength: -summary.nsLength)
        }
    }
}
