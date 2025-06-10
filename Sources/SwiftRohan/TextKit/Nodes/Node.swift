// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

internal class Node: Codable {
  public init() {}

  /// Returns a deep copy of the node (intrinsic state only).
  internal func deepCopy() -> Self { preconditionFailure("overriding required") }

  internal func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {  // V for visitor, C for context, R for result
    preconditionFailure("overriding required")
  }

  internal class var type: NodeType { preconditionFailure("overriding required") }
  final var type: NodeType { Self.type }

  final private(set) var id: NodeIdentifier = NodeIdAllocator.allocate()

  final private(set) weak var parent: Node?

  /// Reallocate the node's identifier.
  final func reallocateId() {
    self.id = NodeIdAllocator.allocate()
  }

  final func setParent(_ parent: Node) {
    precondition(self.parent == nil)
    self.parent = parent
  }

  final func clearParent() {
    precondition(self.parent != nil)
    parent = nil
  }

  /// Reset properties that cannot be reused.
  final func resetForReuse() {
    reallocateId()
    resetCachedProperties()
  }

  // MARK: - Styles

  final var _cachedProperties: PropertyDictionary?

  /// Reset cached properties **recursively**.
  /// - Note: If only the node's properties are to be reset, just call
  ///     `self._cachedProperties = nil`.
  internal func resetCachedProperties() {
    _cachedProperties = nil
  }

  /// Returns the selector for the node class without instance properties.
  final class func selector() -> TargetSelector { TargetSelector(type) }

  /// Returns the selector for the node instance.
  internal func selector() -> TargetSelector { Self.selector() }

  internal func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      let inherited = parent?.getProperties(styleSheet)
      let ruleBased = styleSheet.getProperties(for: self.selector())

      var current: PropertyDictionary =
        switch (inherited, ruleBased) {
        case (.none, .none): [:]
        case let (.some(a), .none): a
        case let (.none, .some(b)): b
        case let (.some(a), .some(b)): a.merging(b) { $1 }
        }

      // process nested-level property
      if NodePolicy.shouldIncreaseLevel(self.type) {
        let key = InternalProperty.nestedLevel
        let level = key.resolveValue(current, styleSheet).integer()!
        current.updateValue(.integer(level + 1), forKey: key)
      }

      // set the cache
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Positioning

  /// Returns the child for the index. If not found or invalid, returns nil.
  internal func getChild(_ index: RohanIndex) -> Node? {
    preconditionFailure("overriding required")
  }

  /// Returns the index for the upstream end.
  internal func firstIndex() -> RohanIndex? { preconditionFailure("overriding required") }

  /// Returns the index for the downstream end.
  internal func lastIndex() -> RohanIndex? { preconditionFailure("overriding required") }

  /// Returns the layout offset for the given index, that is, the sum of layout
  /// lengths of all children before the child at the given index, taking into
  /// account additional units (e.g. newlines) that contribute to layout lengths.
  /// - Returns: the layout offset; or `nil` if the index is invalid or layout
  ///     length is not well-defined for the kind of this node.
  /// - Invariant: if `offset = getLayoutOffset(index)` is non-nil, then
  ///     `getPosition(offset) == index`.
  internal func getLayoutOffset(_ index: RohanIndex) -> Int? {
    preconditionFailure("overriding required")
  }

  /// Returns a position within the node that is picked by `layoutOffset`.
  /// - Parameter layoutOffset: layout offset
  /// - Invariant: If return value is non-nil, then the index must be valid for the node.
  ///     For example, for an `ElementNode`, the index must be a valid child index which
  ///     is in the range `[0, childCount]` (inclusive).
  internal func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    preconditionFailure("overriding required")
  }

  // MARK: - Layout

  /// Notify the node that the content has changed.
  internal func contentDidChange() {
    preconditionFailure("overriding required")
  }

  /// How many length units the node contributes to the layout context.
  /// - Invariant: For nodes whose layout length can be known since instantiation,
  ///     this method must always return the same value. For the rest, this method
  ///     must return the accurate length computed by the last call to `performLayout`.
  internal func layoutLength() -> Int { preconditionFailure("overriding required") }

  /// Returns true if the node produces a block layout.
  internal var isBlock: Bool { false }  // default is inline.

  /// Returns true if the node is dirty.
  internal var isDirty: Bool { preconditionFailure("overriding required") }

  /// Perform layout. When the method is returned, the node must be laid out
  /// with dirty flag cleared and layout length updated.
  /// - Returns: the number of layout units contributed by the node.
  internal func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
    preconditionFailure("overriding required")
  }

  // MARK: - Codable

  internal enum CodingKeys: CodingKey { case type }

  internal required init(from decoder: any Decoder) throws {
    // type check is unnecessary, but let's keep it for safety.

    // for unknown node, the encoded type can be arbitrary.
    guard Self.type != .unknown else { return }

    // for known node type, the encoded type must match.
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nodeType = try container.decode(NodeType.self, forKey: .type)
    guard nodeType == Self.type else {
      throw DecodingError.dataCorruptedError(
        forKey: .type, in: container,
        debugDescription: "Node type mismatch: \(nodeType) vs \(Self.type)")
    }
  }

  internal func encode(to encoder: any Encoder) throws {
    precondition(type != .unknown)  // unknown node is processed separately
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
  }

  // MARK: - Storage

  typealias NodeLoaded<T: Node> = LoadResult<T, UnknownNode>

  /// Tags associated with this node.
  /// - IMPORTANT: The set of storageTags should only expand, and never shrink.
  internal class var storageTags: Array<String> {
    preconditionFailure("overriding required")
  }

  /// Restore the node from JSONValue.
  internal class func load(from json: JSONValue) -> NodeLoaded<Node> {
    preconditionFailure("overriding required")
  }

  /// Store the node to JSONValue.
  internal func store() -> JSONValue { preconditionFailure("overriding required") }

  // MARK: - Tree API

  /// Enumerate the text segments in the range given by `[path, endPath)`
  /// - Parameters:
  ///   - path: path to the start of the range
  ///   - endPath: path to the end of the range
  ///   - context: layout context
  ///   - layoutOffset: layout offset accumulated for the layout context. Initially 0.
  ///   - originCorrection: correction to the origin of the text segment. Initially ".zero".
  ///   - block: block to call for each segment
  /// - Returns: `false` if the enumeration is interrupted by the block, `true` otherwise.
  internal func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /// Resolve the text location for the given point within the node.
  /// - Returns: true if trace is modified, false otherwise.
  /// - Postcondition: the location is stored implicitly in the trace.
  internal func resolveTextLocation(
    with point: CGPoint, context: LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout TextAffinity
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /// Ray shoot from the given path in the given direction.
  /// - Returns: The point where the ray hits a glyph with `isResolved=true`, or
  ///     the current position of the ray with `isResolved=false`. Return `nil` if
  ///     it is guaranteed that no glyph will be hit.
  /// - Note: The position is with respect to the origin of layout context.
  internal func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: TextAffinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    precondition(direction == .up || direction == .down)
    preconditionFailure("overriding required")
  }
}

extension Node {
  final var isTransparent: Bool { NodePolicy.isTransparent(type) }
  final var isPivotal: Bool { NodePolicy.isPivotal(type) }

  final func resolveAggregate<T: PropertyAggregate>(_ styleSheet: StyleSheet) -> T {
    T.resolveAggregate(getProperties(styleSheet), styleSheet.defaultProperties)
  }

  /// Resolve the value of property for given key.
  final func resolveValue(_ key: PropertyKey, _ styleSheet: StyleSheet) -> PropertyValue {
    key.resolveValue(getProperties(styleSheet), styleSheet.defaultProperties)
  }
}
