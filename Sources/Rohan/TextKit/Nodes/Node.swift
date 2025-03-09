// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@inline(__always) func isArgumentNode(_ node: Node) -> Bool { node is ArgumentNode }
@inline(__always) func isElementNode(_ node: Node) -> Bool { node is ElementNode }
@inline(__always) func isRootNode(_ node: Node) -> Bool { node is RootNode }
@inline(__always) func isTextNode(_ node: Node) -> Bool { node is TextNode }

public class Node {
  internal final private(set) weak var parent: Node?
  /** Identifier of this node */
  internal final private(set) var id: NodeIdentifier = .init()
  class var nodeType: NodeType { preconditionFailure("overriding required") }
  final var nodeType: NodeType { Self.nodeType }

  internal final func setParent(_ parent: Node) {
    precondition(self.parent == nil)
    self.parent = parent
  }

  internal final func clearParent() {
    precondition(self.parent != nil)
    parent = nil
  }

  /**
   Reallocate the node's identifier.
   - Warning: Reallocation of node id can be disastrous if used incorrectly.
   */
  internal final func reallocateId() { id = .init() }

  /**
   Reset properties that cannot be reused.

   - Reallocate the node's identifier.
   - Clear the cached properties.
   */
  internal final func prepareForReuse() {
    reallocateId()
    resetCachedProperties(recursive: true)
  }

  // MARK: - Content

  final var isOpaque: Bool { !isTransparent }

  final var isTransparent: Bool { NodePolicy.isTransparent(nodeType) }

  /** Returns the child for the index. If not found, return nil. */
  func getChild(_ index: RohanIndex) -> Node? {
    preconditionFailure("overriding required")
  }

  /** Propagate content change. */
  internal func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    preconditionFailure("overriding required")
  }

  // MARK: - Location

  /** Returns the index for the upstream end */
  func firstIndex() -> RohanIndex? {
    preconditionFailure("overriding required")
  }

  /** Returns the index for the downstream end */
  func lastIndex() -> RohanIndex? {
    preconditionFailure("overriding required")
  }

  // MARK: - Layout

  /** How many length units the node contributes to the layout context. */
  var layoutLength: Int { preconditionFailure("overriding required") }

  /** Returns true if the node occupies a single block */
  var isBlock: Bool { preconditionFailure("overriding required") }

  /** Returns true if the node is dirty. */
  var isDirty: Bool { preconditionFailure("overriding required") }

  /**
   Returns true if tracing nodes from ancestor should stop at this node.

   - Note: The function returns true either when this node introduces a new
    layout context or when it is an apply node.
   */
  final var isPivotal: Bool { NodePolicy.isPivotal(nodeType) }

  /**
   Perform layout and clear the dirty flag.

   - For `fromScratch=true`, one should treat the node as if it was not laid-out before.
   - For `fromScratch=false`, one should update the existing layout incrementally.
   */
  func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    preconditionFailure("overriding required")
  }

  /**
   Returns __layout distance__ from the first child to the child at given index.

   - Returns: the layout distance; or `nil` if index is invalid or layout length
    is not well-defined for the kind of this node.
   - Note: The __layout distance__ is defined as
    "sum { children[i].layoutLength | i ∈ [0, index) }".
   */
  func getLayoutOffset(_ index: RohanIndex) -> Int? {
    preconditionFailure("overriding required")
  }

  /**
   Returns __rohan index__ of the node that contains the layout range
   `[layoutOffset, _ + 1)` together with the value of ``getLayoutOffset(_:)``
   over that index.

   - Invariant: If return value is non-nil, then access child/character with
   the returned index must succeed.
   */
  func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    preconditionFailure("overriding required")
  }

  /**
   Enumerate the text segments in the range given by `[path, endPath)`

   - Parameters:
      - path: path to the start of the range
      - endPath: path to the end of the range
      - context: layout context
      - layoutOffset: layout offset accumulated for the layout context. Initially 0.
      - originCorrection: correction to the origin of the text segment. Initially ".zero".
      - block: block to call for each segment
   - Returns: `true` if the enumeration is completed, `false` if the enumeration is interrupted.
   */
  func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /**
   Resolve the text location for the given point within the node.

   - Returns: `true` if text location is resolved, `false` otherwise.
   - Note: In the case of success, the text location is implicitly stored in the trace.
   */
  func resolveTextLocation(
    interactingAt point: CGPoint, _ context: LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    preconditionFailure("overriding required")
  }

  /**
   Ray shoot from the given path in the given direction.
   - Returns: The point where the ray hits a glyph with `hit=true`, or the current
    position of the ray with `hit=false`. Return `nil` if it is guaranteed that
    no glyph will be hit.
   - Note: The position is with respect to the origin of layout context.
   */
  func rayshoot(
    from path: ArraySlice<RohanIndex>,
    _ direction: TextSelectionNavigation.Direction,
    _ context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    precondition(direction == .up || direction == .down)
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
      case let (.some(inherited), .some(properties)):
        _cachedProperties = inherited.merging(properties) { $1 }
      }
    }
    return _cachedProperties!
  }

  func resetCachedProperties(recursive: Bool) {
    _cachedProperties = nil
  }

  // MARK: - Clone and Visitor

  /** Returns a deep copy of the node (intrinsic state only).  */
  public func deepCopy() -> Node {
    preconditionFailure("overriding required")
  }

  func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    preconditionFailure("overriding required")
  }

  // MARK: - LengthSummary

  final var lengthSummary: LengthSummary {
    LengthSummary(layoutLength: layoutLength)
  }

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
  final func resolveProperties<T>(_ styleSheet: StyleSheet) -> T
  where T: PropertyAggregate {
    T.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
  }

  final func resolveProperty(
    _ key: PropertyKey,
    _ styleSheet: StyleSheet
  ) -> PropertyValue {
    key.resolve(getProperties(styleSheet), styleSheet.defaultProperties)
  }
}
