// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

class ContentNode: ElementNode {
  // MARK: - Node

  required init() {
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

  final override class func load(from json: JSONValue) -> _LoadResult<Node> {
    (loadSelfGeneric(from: json) as _LoadResult<Self>).cast()
  }

  final override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    return JSONValue.array(children)
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(content: self, context, withChildren: children)
  }

  // MARK: - ContentNode

  required override init(_ children: [Node]) {
    super.init(Store(children))
  }

  required override init(_ children: ElementNode.Store) {
    super.init(children)
  }

  required init(deepCopyOf node: ContentNode) {
    super.init(deepCopyOf: node)
  }

  final override func cloneEmpty() -> Self { Self() }

  final class func loadSelfGeneric<T: ContentNode>(from json: JSONValue) -> _LoadResult<T>
  {
    guard case let .array(array) = json
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(array)
    let result = T(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

}
