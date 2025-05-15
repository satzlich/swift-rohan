// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeStoreUtils {
  /// Returns all classes that export a tag in file storage.
  private static var allTaggedClasses: [Node.Type] = [
    LinebreakNode.self,
    UnknownNode.self,
    // Element
    ContentNode.self,
    EmphasisNode.self,
    HeadingNode.self,
    ParagraphNode.self,
    RootNode.self,
    StrongNode.self,
    // Math
    AccentNode.self,
    AlignedNode.self,
    AttachNode.self,
    CasesNode.self,
    EquationNode.self,
    FractionNode.self,
    LeftRightNode.self,
    MathOperatorNode.self,
    MathSymbolNode.self,
    MathVariantNode.self,
    MatrixNode.self,
    OverlineNode.self,
    OverspreaderNode.self,
    RadicalNode.self,
    TextModeNode.self,
    UnderlineNode.self,
    UnderspreaderNode.self,
  ]

  static let registeredTags: [String: Node.Type] = _registeredTags()

  /// Returns the class for a given tag.
  static func lookup(_ tag: String) -> Node.Type? {
    registeredTags[tag]
  }

  private static func _registeredTags() -> [String: Node.Type] {
    var result: [String: Node.Type] = [:]
    for clazz in allTaggedClasses {
      for tag in clazz.storageTags {
        if let existing = result[tag] {
          if existing != clazz {
            assertionFailure("\(tag) is registered by both \(existing) and \(clazz)")
          }
          else {
            assertionFailure("\(tag) is registered by \(existing)")
          }
        }
        else {
          result[tag] = clazz
        }
      }
    }
    return result
  }

  static func loadNode(_ json: JSONValue) -> LoadResult<Node, Node> {
    preconditionFailure()
  }

  /// Load children of element from JSON for given tag.
  /// - Returns: Either a list of nodes or an unknown node.
  static func takeChildrenArray(
    _ json: JSONValue, _ uniqueTag: String
  ) -> Array<JSONValue>? {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      case let .array(children) = array[1]
    else { return [] }
    return children
  }

  /// Load children of element from JSON.
  /// - Returns: success for left, corrupted for right.
  static func loadChildren(
    _ children: Array<JSONValue>
  ) -> Either<ElementNode.Store, ElementNode.Store> {
    var nodes = ElementNode.Store()
    nodes.reserveCapacity(children.count)
    var corrupted = false
    for child in children {
      let node = NodeStoreUtils.loadNode(child)
      nodes.append(node.unwrap())
      if !node.isSuccess { corrupted = true }
    }
    return corrupted ? .Right(nodes) : .Left(nodes)
  }
}
