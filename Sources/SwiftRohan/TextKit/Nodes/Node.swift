// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

public class Node: Codable {
  internal final private(set) weak var parent: Node?

  /// Identifier of this node
  internal final private(set) var id: NodeIdentifier = NodeIdAllocator.allocate()

  class var type: NodeType { preconditionFailure("overriding required") }
  final var type: NodeType { Self.type }

  internal final func setParent(_ parent: Node) {
    precondition(self.parent == nil)
    self.parent = parent
  }

  internal final func clearParent() {
    precondition(self.parent != nil)
    parent = nil
  }

  /// Reallocate the node's identifier.
  /// - Warning: Reallocation of node id can be disastrous if used incorrectly.
  internal final func reallocateId() {
    id = NodeIdAllocator.allocate()
  }

  /// Reset properties that cannot be reused.
  /// 1. Reallocate the node's identifier.
  /// 2. Clear the cached properties.
  internal final func prepareForReuse() {
    reallocateId()
    resetCachedProperties(recursive: true)
  }

  public init() {}

  // MARK: - Codable

  internal enum CodingKeys: CodingKey { case type }

  public required init(from decoder: any Decoder) throws {
    // This is unnecessary, but it's a good practice to check type consistency

    // for unknown node, the encoded type can be arbitrary
    guard Self.type != .unknown else { return }
    // for known node type, the encoded type must match
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nodeType = try container.decode(NodeType.self, forKey: .type)
    guard nodeType == Self.type else {
      throw DecodingError.dataCorruptedError(
        forKey: .type, in: container,
        debugDescription: "Node type mismatch: \(nodeType) vs \(Self.type)")
    }
  }

  public func encode(to encoder: any Encoder) throws {
    precondition(type != .unknown, "type must be known")
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
  }

  // MARK: - Storage

  typealias _LoadResult<T: Node> = LoadResult<T, UnknownNode>

  /// Restore the node from JSONValue.
  class func load(from json: JSONValue) -> _LoadResult<Node> {
    preconditionFailure("overriding required")
  }

  /// Store the node to JSONValue.
  func store() -> JSONValue {
    preconditionFailure("overriding required")
  }

  /// Tags associated with this node.
  /// - IMPORTANT: The set of storageTags should only expand, and never shrink.
  class var storageTags: [String] {
    preconditionFailure("overriding required")
  }

  // MARK: - Content

  final var isTransparent: Bool { NodePolicy.isTransparent(type) }

  /// Returns the child for the index. If not found, return nil.
  func getChild(_ index: RohanIndex) -> Node? {
    preconditionFailure("overriding required")
  }

  /// Propagate content change.
  internal func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    preconditionFailure("overriding required")
  }

  // MARK: - Location

  /// Returns the index for the upstream end
  func firstIndex() -> RohanIndex? { preconditionFailure("overriding required") }

  /// Returns the index for the downstream end
  func lastIndex() -> RohanIndex? { preconditionFailure("overriding required") }

  // MARK: - Layout

  /// How many length units the node contributes to the layout context.
  func layoutLength() -> Int {
    preconditionFailure("overriding required")
  }

  /// Returns true if the node occupies a single block.
  var isBlock: Bool { false }

  /// Returns true if the node is dirty.
  var isDirty: Bool { preconditionFailure("overriding required") }

  /// Returns true if the node is pivotal.
  final var isPivotal: Bool { NodePolicy.isPivotal(type) }

  /// Perform layout and clear the dirty flag.
  /// * For `fromScratch=true`, one should treat the node as if it was not
  ///   laid-out before.
  /// * For `fromScratch=false`, one should update the existing layout
  func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    preconditionFailure("overriding required")
  }

  /// Returns the layout offset for the given index, that is, the sum of layout
  /// lengths of all children before the child at the given index, taking into
  /// account newlines.
  /// - Returns: the layout offset; or `nil` if the index is invalid or layout
  ///     length is not well-defined for the kind of this node.
  func getLayoutOffset(_ index: RohanIndex) -> Int? {
    preconditionFailure("overriding required")
  }

  /// Returns the rohan index of the child node that is picked by `[layoutOffset, _ + 1)`
  /// together with the layout offset of the child.
  /// - Parameter layoutOffset: layout offset
  /// - Invariant: If return value is non-nil, then access child/character with
  ///     the returned index must succeed.
  /// - Invariant: `consumed == nil || consumed <= layoutOffset`
  func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    preconditionFailure("overriding required")
  }

  /// Returns a position within the node that is picked by `layoutOffset`.
  /// - Parameter layoutOffset: layout offset
  /// - Invariant: If return value is non-nil, then the index must be valid for the node.
  ///     For example, for an `ElementNode`, the index must be a valid child index which
  ///     is in the range `[0, childCount]` (inclusive).
  func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    preconditionFailure("overriding required")
  }

  /// Enumerate the text segments in the range given by `[path, endPath)`
  /// - Parameters:
  ///   - path: path to the start of the range
  ///   - endPath: path to the end of the range
  ///   - context: layout context
  ///   - layoutOffset: layout offset accumulated for the layout context. Initially 0.
  ///   - originCorrection: correction to the origin of the text segment. Initially ".zero".
  ///   - block: block to call for each segment
  /// - Returns: `false` if the enumeration is interrupted by the block, `true` otherwise.
  func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /// Resolve the text location for the given point within the node.
  /// - Returns: true if text location is resolved, false otherwise.
  /// - Note: In the case of success, the text location is implicitly stored in the trace.
  func resolveTextLocation(
    with point: CGPoint, _ context: LayoutContext, _ trace: inout Trace,
    _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /// Ray shoot from the given path in the given direction.
  /// - Returns: The point where the ray hits a glyph with `isResolved=true`, or
  ///     the current position of the ray with `isResolved=false`. Return `nil` if
  ///     it is guaranteed that no glyph will be hit.
  /// - Note: The position is with respect to the origin of layout context.
  func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    precondition(direction == .up || direction == .down)
    preconditionFailure("overriding required")
  }

  // MARK: - Styles

  final var _cachedProperties: PropertyDictionary?

  func selector() -> TargetSelector { TargetSelector(type) }

  public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      let inherited = parent?.getProperties(styleSheet)
      // apply style rule for given selector
      do {
        let properties = styleSheet.getProperties(for: selector())
        switch (inherited, properties) {
        case (.none, .none):
          _cachedProperties = [:]
        case let (.none, .some(properties)):
          _cachedProperties = properties
        case let (.some(inherited), .none):
          _cachedProperties = inherited
        case let (.some(inherited), .some(properties)):
          _cachedProperties = inherited.merging(properties) { $1 }
        }
      }
      // process for nested-level
      if NodePolicy.shouldIncreaseLevel(self.type) {
        let key = InternalProperty.nestedLevel
        let level = key.resolve(_cachedProperties!, styleSheet).integer()!
        _cachedProperties?.updateValue(.integer(level + 1), forKey: key)
      }
    }
    return _cachedProperties!
  }

  func resetCachedProperties(recursive: Bool) {
    _cachedProperties = nil
  }

  // MARK: - Clone and Visitor

  /// Returns a deep copy of the node (intrinsic state only).
  public func deepCopy() -> Node {
    preconditionFailure("overriding required")
  }

  func accept<V, R, C>(_ visitor: V, _ context: C) -> R where V: NodeVisitor<R, C> {
    preconditionFailure("overriding required")
  }

  // MARK: - LengthSummary

  final var lengthSummary: LengthSummary {
    LengthSummary(layoutLength: layoutLength())
  }

  /// Previously there were multiple kinds of lengths involved. Now there is only one.
  struct LengthSummary: Equatable, Hashable, AdditiveArithmetic {
    var layoutLength: Int

    init(layoutLength: Int) {
      self.layoutLength = layoutLength
    }

    func with(layoutLength: Int) -> Self {
      LengthSummary(layoutLength: layoutLength)
    }

    static let zero = LengthSummary(layoutLength: 0)

    static func + (lhs: LengthSummary, rhs: LengthSummary) -> LengthSummary {
      LengthSummary(layoutLength: lhs.layoutLength + rhs.layoutLength)
    }

    static func - (lhs: LengthSummary, rhs: LengthSummary) -> LengthSummary {
      LengthSummary(layoutLength: lhs.layoutLength - rhs.layoutLength)
    }

    static prefix func - (summary: LengthSummary) -> LengthSummary {
      LengthSummary(layoutLength: -summary.layoutLength)
    }
  }
}

extension Node {
  /// Resolve the value of property aggregate for given type.
  final func resolvePropertyAggregate<T>(_ styleSheet: StyleSheet) -> T
  where T: PropertyAggregate {
    T.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
  }

  /// Resolve the value of property for given key.
  final func resolveProperty(
    _ key: PropertyKey, _ styleSheet: StyleSheet
  ) -> PropertyValue {
    key.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
  }

  // MARK: - Styles

  class func selector() -> TargetSelector {
    TargetSelector(type)
  }
}
