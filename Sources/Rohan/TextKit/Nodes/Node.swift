// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
  internal final weak var parent: Node?
  internal final private(set) var id: NodeIdentifier = .init()

  /**
   Reallocate the node's identifier.
   - Warning: Reallocation can be dangerous if used incorrectly.
   */
  final func reallocateId() { id = .init() }

  class var nodeType: NodeType { preconditionFailure("overriding required") }
  final var nodeType: NodeType { Self.nodeType }

  // MARK: - Content

  final var isOpaque: Bool { NodeType.isOpqaueNode(nodeType) }
  final var isAllowedToBeEmpty: Bool { NodeType.isAllowedToBeEmpty(nodeType) }

  /** Propagate content change. */
  internal func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    preconditionFailure("overriding required")
  }

  func getChild(_ index: RohanIndex) -> Node? { preconditionFailure("overriding required") }

  // MARK: - Layout

  /** How much length units the node contributes to the layout context. */
  var layoutLength: Int { preconditionFailure("overriding required") }

  /** Returns true if the node is a block node. */
  var isBlock: Bool { preconditionFailure("overriding required") }

  /** Returns true if the node is dirty. */
  var isDirty: Bool { preconditionFailure("overriding required") }

  /**
   Perform layout and clear the dirty flag.
   - Important: When `fromScratch=true`, one should treat the node as if it is a new node.
   */
  func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    preconditionFailure("overriding required")
  }

  /** Returns __local layout offset__ from the first child to the child at given index.*/
  func getLayoutOffset(_ index: RohanIndex) -> Int? {
    preconditionFailure("overriding required")
  }

  /** Returns the rohan index that contains the layout offset */
  func getRohanIndex(for layoutOffset: Int) -> RohanIndex? {
    preconditionFailure("overriding required")
  }

  func enumerateTextSegments(
    _ context: LayoutContext,
    _ trace: ArraySlice<TraceElement>,
    _ endTrace: ArraySlice<TraceElement>,
    layoutOffset: Int,
    originCorrection: CGPoint,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) {
    preconditionFailure("overriding required")
  }

  func getTextLocation(interactingAt point: CGPoint, _ context: LayoutContext, _ path: inout [RohanIndex]) {
    preconditionFailure()
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
