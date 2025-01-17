// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
    @usableFromInline
    internal weak var parent: Node?
    class var nodeType: NodeType { .unknown }
    final var nodeType: NodeType { Self.nodeType }

    // MARK: - Layout

    internal class var isLayoutRoot: Bool { false }
    final var isLayoutRoot: Bool { Self.isLayoutRoot }

    /** Returns `true` if custom layout is required. */
    var needsCustomLayout: Bool { false }
    /** Returns the layout fragment if custom layout is required. */
    var layoutFragment: (any RhLayoutFragment)? { nil }

    func performCustomLayout(_ context: RhLayoutContext) {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    /** Returns `true` if block layout is required */
    var isBlock: Bool { false }

    // MARK: - Location and Length

    /**
     Convert input `([], offset)` to `(path, offset')` where `path` points to a leaf node.

     - Returns: `(path, offset')` where `path` is a list of indices to a leaf node
     and `offset'` is the offset within the node

     - Precondition: argument `offset` must be in range `[0, length]`
     */
    public final func locate(
        _ offset: Int,
        _ affinity: Affinity = .upstream
    ) -> (path: [RohanIndex], offset: Int) {
        precondition(offset >= 0 && offset <= length)
        var path = [RohanIndex]()
        var offset = offset

        var node: Node = self
        while true {
            if let (index, offset_) = node._childIndex(for: offset, affinity) {
                path.append(index)
                offset = offset_
                // move on
                node = node._getChild(index)!
            }
            else {
                break
            }
        }
        return (path, offset)
    }

    public final func offset(_ path: [RohanIndex]) -> Int {
        var offset = 0
        var node: Node? = self

        for index in path {
            offset += node!._length(before: index)
            // move on
            node = node!._getChild(index)
        }
        return offset
    }

    /**
     Returns the index of the child that contains the given offset.
     Break ties by affinity.

     - Returns: `(index, offset)` where `offset` is the offset within the child;
     or `nil` if not found

     - Complexity: `O(n)`
     */
    internal func _childIndex(
        for offset: Int,
        _ affinity: Affinity
    ) -> (index: RohanIndex, offset: Int)? {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    /**
     Return the child at the specified index.

     - Complexity: `O(1)`
     */
    internal func _getChild(_ index: RohanIndex) -> Node? {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    /**
     Returns the length of the node's prefix before the given index.

     - Complexity: `O(n)`
     */
    internal func _length(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    // MARK: - Clone and Visitor

    public func copy() -> Node {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    // MARK: - Length

    var length: Int { preconditionFailure("overriding required for \(type(of: self))") }
    var nsLength: Int { preconditionFailure("overriding required for \(type(of: self))") }

    final var _summary: _Summary {
        _Summary(length: length, nsLength: nsLength)
    }

    internal func _onContentChange(delta: _Summary) {
        parent?._onContentChange(delta: delta)
    }

    struct _Summary: Equatable, Hashable {
        let length: Int
        let nsLength: Int

        init(length: Int = 0, nsLength: Int = 0) {
            self.length = length
            self.nsLength = nsLength
        }

        func with(length: Int) -> Self {
            _Summary(length: length, nsLength: nsLength)
        }

        func with(nsLength: Int) -> Self {
            _Summary(length: length, nsLength: nsLength)
        }

        static func + (lhs: _Summary, rhs: _Summary) -> _Summary {
            _Summary(length: lhs.length + rhs.length,
                     nsLength: lhs.nsLength + rhs.nsLength)
        }

        static func += (lhs: inout _Summary, rhs: _Summary) {
            lhs = lhs + rhs
        }

        static prefix func - (summary: _Summary) -> _Summary {
            _Summary(length: -summary.length,
                     nsLength: -summary.nsLength)
        }
    }
}
