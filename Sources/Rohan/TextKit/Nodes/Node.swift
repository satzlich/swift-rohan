// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@DebugDescription
struct NodeIdentifier: Equatable, Hashable {
    @usableFromInline static var _counter: Int = 1
    @usableFromInline let _id: Int

    @inlinable
    init() {
        self._id = NodeIdentifier._counter
        NodeIdentifier._counter += 1
    }
}

public class Node {
    @usableFromInline internal final weak var parent: Node? = nil
    internal final var id: NodeIdentifier = .init()

    class var nodeType: NodeType { preconditionFailure("overriding required") }
    final var nodeType: NodeType { Self.nodeType }

    /**
     Return the child at the specified index.
     - Complexity: `O(1)`
     */
    internal func _getChild(_ index: RohanIndex) -> Node? {
        preconditionFailure("overriding required")
    }

    /** Propagate content change. */
    internal func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        parent?._onContentChange(delta: delta, inContentStorage: inContentStorage)
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

    // MARK: - Length & Location

    @inlinable var nsLength: Int { preconditionFailure("overriding required") }
    @inlinable var length: Int { preconditionFailure("overriding required") }
    @inlinable
    final var _summary: _Summary { _Summary(length: length, nsLength: nsLength) }

    class var startPadding: Bool { preconditionFailure("overriding required") }
    class var endPadding: Bool { preconditionFailure("overriding required") }
    final var startPadding: Bool { Self.startPadding }
    final var endPadding: Bool { Self.endPadding }

    final func offset(for path: [RohanIndex]) -> Int {
        guard !path.isEmpty else { return 0 }

        var offset = 0
        var node: Node = self
        // add all but last
        for index in path.dropLast() {
            offset += node._partialLength(before: index)
            // make progress
            node = node._getChild(index)!
        }
        // add last
        offset += node._partialLength(before: path.last!)

        return offset
    }

    /**
     Returns the length of the children before the given index PLUS the start padding.
     */
    func _partialLength(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required")
    }

    /**
     Locate the path for the given offset and return the offset within the child node.
     When the path points to inner node, the offset is `nil`.
     */
    public final func locate(_ offset: Int) -> (path: [RohanIndex], offset: Int?) {
        precondition(offset >= Self.startPadding.intValue &&
            offset <= length - Self.endPadding.intValue)
        var path: [RohanIndex] = []
        let offset = _locate(offset, &path)
        return (path, offset)
    }

    func _locate(_ offset: Int, _ path: inout [RohanIndex]) -> Int? {
        preconditionFailure("overriding required")
    }

    @usableFromInline
    struct _Summary: Equatable, Hashable {
        @usableFromInline var length: Int
        @usableFromInline var nsLength: Int

        @inlinable
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

    // MARK: - Clone and Visitor

    /** Returns a deep copy of the node (intrinsic state only).  */
    public func deepCopy() -> Node {
        preconditionFailure("overriding required")
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure("overriding required")
    }
}

extension Node {
    final func resolve<T>(with styleSheet: StyleSheet) -> T
    where T: PropertyAggregate {
        T.resolve(getProperties(with: styleSheet), styleSheet.defaultProperties)
    }
}
