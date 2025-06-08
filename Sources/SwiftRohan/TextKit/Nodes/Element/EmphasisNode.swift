// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

public final class EmphasisNode: ElementNode {
  override class var type: NodeType { .emphasis }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    func invertFontStyle(_ fontStyle: FontStyle) -> FontStyle {
      switch fontStyle {
      case .normal: .italic
      case .italic: .normal
      }
    }

    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let key = TextProperty.style
      let value = key.resolveValue(current, styleSheet.defaultProperties).fontStyle()!
      current[key] = .fontStyle(invertFontStyle(value))

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(emphasis: self, context)
  }

  override func accept<R, C, V, T, S>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R where V: NodeVisitor<R, C>, T: GenNode, T == S.Element, S: Collection {
    visitor.visit(emphasis: self, context, withChildren: children)
  }

  private static let uniqueTag = "emph"

  var command: String { Self.uniqueTag }

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<EmphasisNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
