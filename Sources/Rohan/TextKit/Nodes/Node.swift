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

    @inlinable
    var debugDescription: String { "\(_id)" }
}

public class Node {
    @usableFromInline internal final weak var parent: Node? = nil
    @usableFromInline internal final var id: NodeIdentifier = .init()

    class var nodeType: NodeType { preconditionFailure("overriding required") }
    final var nodeType: NodeType { Self.nodeType }

    /**
     Return the child at the specified index.
     - Complexity: `O(1)`
     */
    internal func _getChild(_ index: RohanIndex) -> Node? {
        preconditionFailure("overriding required")
    }

    // MARK: - Layout

    /** Returns true if the node is a block element. */
    var isBlock: Bool { preconditionFailure("overriding required") }
    /** Returns true if the node is dirty. */
    var isDirty: Bool { preconditionFailure("overriding required") }
    /**
     Perform layout.
     - Postcondition: layout inconsistency and its indicators are cleared.
     */
    func performLayout(_ context: RhLayoutContext, fromScratch: Bool = false) {
        preconditionFailure("overriding required")
    }

    // MARK: - Styles

    final var _cachedProperties: PropertyDictionary?

    func selector() -> TargetSelector { TargetSelector(nodeType) }

    public func getProperties(with styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            let inherited = parent?.getProperties(with: styleSheet)
            let properties = styleSheet.getProperties(for: selector())

            switch (inherited, properties) {
            case (.none, .none):
                _cachedProperties = [:]
            case let (.none, .some(properties)):
                _cachedProperties = properties
            case let (.some(inherited), .none):
                _cachedProperties = inherited
            case (var .some(inherited), let .some(properties)):
                inherited.merge(properties) { $1 }
                _cachedProperties = inherited
            }
        }
        return _cachedProperties!
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
     Returns the length of the node's prefix before the given index.

     - Complexity: `O(n)`
     */
    internal func _length(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required")
    }

    // MARK: - Clone and Visitor

    /** Returns a deep copy of the node (intrinsic state only).  */
    public func deepCopy() -> Node {
        preconditionFailure("overriding required")
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure("overriding required")
    }

    // MARK: - Length

    @inlinable var length: Int { preconditionFailure("overriding required") }
    @inlinable var nsLength: Int { preconditionFailure("overriding required") }

    @inlinable @inline(__always)
    final var _summary: _Summary { _Summary(length: length,
                                            paddedLength: paddedLength,
                                            nsLength: nsLength) }

    internal func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        parent?._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    @usableFromInline
    struct _Summary: Equatable, Hashable {
        @usableFromInline var length: Int
        @usableFromInline var paddedLength: Int
        @usableFromInline var nsLength: Int

        @inlinable
        init(length: Int,
             paddedLength: Int,
             nsLength: Int)
        {
            self.length = length
            self.paddedLength = paddedLength
            self.nsLength = nsLength
        }

        func with(length: Int) -> Self {
            _Summary(length: length,
                     paddedLength: paddedLength,
                     nsLength: nsLength)
        }

        func with(paddedLength: Int) -> Self {
            _Summary(length: length,
                     paddedLength: paddedLength,
                     nsLength: nsLength)
        }

        func with(nsLength: Int) -> Self {
            _Summary(length: length,
                     paddedLength: paddedLength,
                     nsLength: nsLength)
        }

        static let zero = _Summary(length: 0,
                                   paddedLength: 0,
                                   nsLength: 0)

        static func + (lhs: _Summary, rhs: _Summary) -> _Summary {
            _Summary(length: lhs.length + rhs.length,
                     paddedLength: lhs.paddedLength + rhs.paddedLength,
                     nsLength: lhs.nsLength + rhs.nsLength)
        }

        static func += (lhs: inout _Summary, rhs: _Summary) {
            lhs = lhs + rhs
        }

        static func - (lhs: _Summary, rhs: _Summary) -> _Summary {
            _Summary(length: lhs.length - rhs.length,
                     paddedLength: lhs.paddedLength - rhs.paddedLength,
                     nsLength: lhs.nsLength - rhs.nsLength)
        }

        static func -= (lhs: inout _Summary, rhs: _Summary) {
            lhs = lhs - rhs
        }

        static prefix func - (summary: _Summary) -> _Summary {
            _Summary(length: -summary.length,
                     paddedLength: -summary.paddedLength,
                     nsLength: -summary.nsLength)
        }
    }

    // MARK: - Padded Length

    @usableFromInline
    var paddedLength: Int { preconditionFailure("overriding required") }
    class var startPadding: Bool { preconditionFailure("overriding required") }
    class var endPadding: Bool { preconditionFailure("overriding required") }
    final var startPadding: Bool { Self.startPadding }
    final var endPadding: Bool { Self.endPadding }

    func _paddedLength(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required")
    }

    final func paddedOffset(for path: [RohanIndex]) -> Int {
        guard !path.isEmpty else { return 0 }

        var offset = 0
        var node: Node = self
        // add all but last
        for index in path.dropLast() {
            offset += node.startPadding.intValue
            offset += node._paddedLength(before: index)
            // make progress
            node = node._getChild(index)!
        }
        // add last
        offset += node.startPadding.intValue
        offset += node._paddedLength(before: path.last!)

        return offset
    }

    func _locate(forPadded offset: Int, _ path: inout [RohanIndex]) -> Int? {
        preconditionFailure("overriding required")
    }

    /**
     Locate the path for the given offset and return the offset within the child node.
     When the path points to inner node, the offset is `nil`.
     */
    public final func locate(forPadded offset: Int)
    -> (path: [RohanIndex], offset: Int?) {
        precondition(offset >= Self.startPadding.intValue &&
            offset <= paddedLength - Self.endPadding.intValue)
        var path: [RohanIndex] = []
        let offset = _locate(forPadded: offset, &path)
        return (path, offset)
    }
}

extension Node {
    final func resolve<T>(with styleSheet: StyleSheet) -> T
    where T: PropertyAggregate {
        T.resolve(getProperties(with: styleSheet), styleSheet.defaultProperties)
    }
}
