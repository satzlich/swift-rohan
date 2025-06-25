// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class ParagraphNode: ElementNodeImpl {
  // MARK: - Node

  final override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(paragraph: self, context)
  }

  final override class var type: NodeType { .paragraph }

  // MARK: - Node(Storage)

  private static let uniqueTag = "paragraph"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  // MARK: - Node(Tree API)

  /// Returns the value of the first child of the paragraph, if any.
  /// - Note: No companion ``needsTrailingCursorCorrection`` property is provided,
  ///     because paragraphs are not expected to have trailing cursors.
  final override var needsLeadingCursorCorrection: Bool {
    _children.first?.needsLeadingCursorCorrection ?? false
  }

  final override var needsTrailingCursorCorrection: Bool {
    _children.last?.needsTrailingCursorCorrection ?? false
  }

  final override func leadingCursorCorrection() -> Double {
    _children.first?.leadingCursorCorrection() ?? 0
  }

  final override func trailingCursorPosition() -> Double? {
    _children.last?.trailingCursorPosition()
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(paragraph: self, context, withChildren: children)
  }

  final override func createSuccessor() -> ElementNode? { ParagraphNode() }
  final override func cloneEmpty() -> Self { Self() }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<ParagraphNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }
}
