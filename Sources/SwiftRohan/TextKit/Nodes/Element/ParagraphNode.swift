// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

public final class ParagraphNode: ElementNode {
  override class var type: NodeType { .paragraph }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(paragraph: self, context)
  }

  override func accept<R, C, V, T, S>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R where V: NodeVisitor<R, C>, T: GenNode, T == S.Element, S: Collection {
    visitor.visit(paragraph: self, context, withChildren: children)
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }
  override func createSuccessor() -> ElementNode? { ParagraphNode() }

  private static let uniqueTag = "paragraph"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<ParagraphNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
