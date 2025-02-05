// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
    internal final weak var parent: Node?
    internal final var id: NodeIdentifier = .init()

    class var nodeType: NodeType { preconditionFailure("overriding required") }
    final var nodeType: NodeType { Self.nodeType }

    // MARK: - Content

    class var isTransparent: Bool { preconditionFailure("overriding required") }

    /**
     Returns true if the node is transparent, that is, its content contribute
     directly to the parent. Being transparent implies that extrinsic length
     equals to intrinsic length.
     */
    final var isTransparent: Bool { Self.isTransparent }
    /** How many edit units the node contains. */
    var intrinsicLength: Int { preconditionFailure("overriding required") }
    /** How many edit units the node contributes to the parent. */
    final var extrinsicLength: Int { isTransparent ? intrinsicLength : 1 }

    /** Propagate content change. */
    internal func contentDidChange(delta: Summary, inContentStorage: Bool) {
        preconditionFailure("overriding required")
    }

    // MARK: - Layout

    /** How much length units the node contributes to the layout context. */
    var layoutLength: Int { preconditionFailure("overriding required") }

    /** Returns true if the node is a block element. */
    var isBlock: Bool { preconditionFailure("overriding required") }

    /** Returns true if the node is dirty. */
    var isDirty: Bool { preconditionFailure("overriding required") }

    /** Perform layout and clear the dirty flag. */
    func performLayout(_ context: LayoutContext, fromScratch: Bool = false) {
        preconditionFailure("overriding required")
    }

    // MARK: - Styles

    final var _cachedProperties: PropertyDictionary?

    func selector() -> TargetSelector { TargetSelector(nodeType) }

    public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            let inherited = parent?.getProperties(styleSheet)
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

    // MARK: - Offset/Length

    var length: Int { preconditionFailure("overriding required") }
    final var _summary: Summary {
        Summary(length: length,
                extrinsicLength: extrinsicLength,
                layoutLength: layoutLength)
    }

    class var startPadding: Bool { preconditionFailure("overriding required") }
    class var endPadding: Bool { preconditionFailure("overriding required") }
    final var startPadding: Bool { Self.startPadding }
    final var endPadding: Bool { Self.endPadding }

    final func offset(for location: RohanTextLocation) -> Int {
        guard !location.path.isEmpty else { return location.offset }

        var offset = 0
        var node: Node = self
        // add all but last
        for index in location.path.dropLast() {
            offset += node.getOffset(before: index)
            // make progress
            node = node.getChild(index)!
        }
        // add last
        offset += node.getOffset(before: location.path.last!)

        return offset + location.offset
    }

    /** Returns the offset (sum of lengths) immediately before the specified child,
     taking paddings of current node into account. */
    internal func getOffset(before index: RohanIndex) -> Int {
        preconditionFailure("overriding required")
    }

    // MARK: - Index/Location

    /**
     Return the child at the specified index.
     - Complexity: `O(1)`
     */
    internal func getChild(_ index: RohanIndex) -> Node? {
        preconditionFailure("overriding required")
    }

    /** Returns the location of the given offset. */
    final func locate(_ offset: Int) -> RohanTextLocation {
        precondition(offset >= startPadding.intValue &&
            offset <= length - endPadding.intValue)
        var path: [RohanIndex] = []
        let offset = _getLocation(offset, &path)
        return RohanTextLocation(path, offset)
    }

    func _getLocation(_ offset: Int, _ path: inout [RohanIndex]) -> Int {
        preconditionFailure("overriding required")
    }

    // MARK: - Summary

    struct Summary: Equatable, Hashable, AdditiveArithmetic {
        var length: Int
        var extrinsicLength: Int
        var layoutLength: Int

        init(length: Int,
             extrinsicLength: Int,
             layoutLength: Int)
        {
            self.length = length
            self.extrinsicLength = extrinsicLength
            self.layoutLength = layoutLength
        }

        func with(length: Int) -> Self {
            Summary(length: length,
                    extrinsicLength: extrinsicLength,
                    layoutLength: layoutLength)
        }

        func with(extrinsicLength: Int) -> Self {
            Summary(length: length,
                    extrinsicLength: extrinsicLength,
                    layoutLength: layoutLength)
        }

        func with(layoutLength: Int) -> Self {
            Summary(length: length,
                    extrinsicLength: extrinsicLength,
                    layoutLength: layoutLength)
        }

        static let zero = Summary(length: 0,
                                  extrinsicLength: 0,
                                  layoutLength: 0)

        static func + (lhs: Summary, rhs: Summary) -> Summary {
            Summary(length: lhs.length + rhs.length,
                    extrinsicLength: lhs.extrinsicLength + rhs.extrinsicLength,
                    layoutLength: lhs.layoutLength + rhs.layoutLength)
        }

        static func - (lhs: Summary, rhs: Summary) -> Summary {
            Summary(length: lhs.length - rhs.length,
                    extrinsicLength: lhs.extrinsicLength - rhs.extrinsicLength,
                    layoutLength: lhs.layoutLength - rhs.layoutLength)
        }

        static prefix func - (summary: Summary) -> Summary {
            Summary(length: -summary.length,
                    extrinsicLength: -summary.extrinsicLength,
                    layoutLength: -summary.layoutLength)
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
    final func resolveProperties<T>(_ styleSheet: StyleSheet) -> T
    where T: PropertyAggregate {
        T.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
    }

    final func resolveProperty(_ key: PropertyKey,
                               _ styleSheet: StyleSheet) -> PropertyValue
    {
        key.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
    }
}
