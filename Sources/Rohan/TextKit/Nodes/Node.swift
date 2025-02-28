// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
  internal final weak var parent: Node?
  /** Identifier of this node */
  internal final private(set) var id: NodeIdentifier = .init()

  /**
   Reallocate the node's identifier.
   - Warning: Reallocation of node id can be disastrous if used incorrectly.
   */
  internal final func reallocateId() { id = .init() }

  class var nodeType: NodeType { preconditionFailure("overriding required") }
  final var nodeType: NodeType { Self.nodeType }

  // MARK: - Content

  /**
   Returns __false__ if including this node is equivalent to including its
   children and optional newline corresponding to its associated __insertNewline__
   value. In this case, the node is called __transparent__.
   */
  final var isOpaque: Bool { NodeType.isOpaque(nodeType) }

  /** Returns the child for the index. If not found, return nil. */
  func getChild(_ index: RohanIndex) -> Node? {
    preconditionFailure("overriding required")
  }

  /** Propagate content change. */
  internal func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
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
  final var isPivotal: Bool { NodeType.isPivotal(nodeType) }

  /**
   Perform layout and clear the dirty flag.

   For fromScratch=true, one should treat the node as if it was not laid-out before.
   For fromScratch=false, one should update the existing layout incrementally.
   */
  func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    preconditionFailure("overriding required")
  }

  /**
   Returns __layout distance__ from the first child to the child at given index.

   - Note: sum { child.layoutLength | child ∈ children[0, index) }; or `nil` if
    index is invalid or layout length is not well-defined for the kind of this node.
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
      - context: layout context
      - path: path to the start of the range
      - endPath: path to the end of the range
      - layoutOffset: layout offset accumulated for the layout context. Initially 0.
      - originCorrection: correction to the origin of the text segment. Initially .zero.
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

  func resolveMoveUp(
    _ path: ArraySlice<RohanIndex>, _ context: LayoutContext,
    layoutOffset: Int, originCorrection: CGPoint
  ) -> (CGRect, CGPoint) {
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
