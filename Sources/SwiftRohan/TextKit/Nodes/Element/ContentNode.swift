// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

class ContentNode: ElementNodeImpl {
  // MARK: - Node

  required override init() {
    super.init()
  }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(content: self, context)
  }

  override final class var type: NodeType { .content }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    /* ContentNode emit no tags */
    []
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    (loadSelfGeneric(from: json) as NodeLoaded<Self>).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    return JSONValue.array(children)
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(content: self, context, withChildren: children)
  }

  final override func cloneEmpty() -> Self { Self() }

  // MARK: - Storage

  final class func loadSelfGeneric<T: ContentNode>(from json: JSONValue) -> NodeLoaded<T>
  {
    guard case let .array(array) = json else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(array)
    let result = T(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - ContentNode

  required override init(_ children: ElementStore) {
    super.init(children)
  }

  required init(deepCopyOf node: ContentNode) {
    super.init(deepCopyOf: node)
  }
}
