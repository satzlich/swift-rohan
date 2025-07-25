import Foundation

enum NodeStoreUtils {
  /// Returns all classes that export a tag in file storage.
  static let registeredClasses: Array<Node.Type> = [
    CounterNode.self,
    LinebreakNode.self,
    UnknownNode.self,
    // Template
    ApplyNode.self,
    // Element
    ContentNode.self,
    HeadingNode.self,
    ItemListNode.self,
    ParagraphNode.self,
    ParListNode.self,
    RootNode.self,
    TextStylesNode.self,
    // Math
    AccentNode.self,
    AttachNode.self,
    EquationNode.self,
    FractionNode.self,
    LeftRightNode.self,
    MathAttributesNode.self,
    MathExpressionNode.self,
    MathOperatorNode.self,
    NamedSymbolNode.self,
    MathStylesNode.self,
    MatrixNode.self,
    MultilineNode.self,
    RadicalNode.self,
    TextModeNode.self,
    UnderOverNode.self,
  ]

  static let registeredTags: Dictionary<String, Node.Type> = _registeredTags()

  /// Returns the class for a given tag.
  static func lookup(_ tag: String) -> Node.Type? {
    registeredTags[tag]
  }

  private static func _registeredTags() -> Dictionary<String, Node.Type> {
    var result: Dictionary<String, Node.Type> = [:]
    for clazz in registeredClasses {
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

  static func loadNode(_ json: JSONValue) -> LoadResult<Node, UnknownNode> {
    switch json {
    case .string:
      return TextNode.load(from: json)
    case .array(let array):
      guard let tag = array.first,
        case let .string(tag) = tag,
        let clazz = lookup(tag)
      else { return .failure(UnknownNode(json)) }
      let node = clazz.load(from: json)
      return node
    default:
      return .failure(UnknownNode(json))
    }
  }

  /// Very JSON for element for given tag and take child array from JSON.
  /// - Returns: Either a list of nodes or an unknown node.
  static func takeChildrenArray(
    _ json: JSONValue, _ uniqueTag: String
  ) -> Array<JSONValue>? {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      case let .array(children) = array[1]
    else { return nil }
    return children
  }

  /// Load children of element from JSON.
  /// - Returns: nodes and whether the loading is corrupted.
  static func loadChildren(
    _ children: Array<JSONValue>
  ) -> (ElementStore, corrupted: Bool) {
    let result = loadNodes(children) as LoadResult<ElementStore, UnknownNode>
    switch result {
    case .success(let nodes):
      return (nodes, false)
    case .corrupted(let nodes):
      return (nodes, true)
    case .failure(let unknownNode):
      assertionFailure("Failed to load children: \(unknownNode)")
      return (ElementStore([unknownNode]), true)
    }
  }

  /// Load nodes from array of JSON values.
  static func loadNodes<C: RangeReplaceableCollection<Node>>(
    _ values: Array<JSONValue>
  ) -> LoadResult<C, UnknownNode> {
    var result = C()
    result.reserveCapacity(values.count)
    var corrupted = false
    for value in values {
      let node = NodeStoreUtils.loadNode(value)
      result.append(node.unwrap())
      if !node.isSuccess { corrupted = true }
    }
    return corrupted ? .corrupted(result) : .success(result)
  }

  /// Load nodes from JSON which is an array of JSON values.
  /// - Returns: Either a collection of nodes or an unknown node.
  static func loadNodes<C: RangeReplaceableCollection<Node>>(
    _ json: JSONValue
  ) -> LoadResult<C, UnknownNode> {
    guard case let .array(array) = json
    else { return .failure(UnknownNode(json)) }
    return loadNodes(array)
  }

  static func loadOptComponent<T: ContentNode>(_ json: JSONValue) -> LoadResult<T?, Void>
  {
    if case .null = json { return .success(nil) }
    let content = T.loadSelfGeneric(from: json) as LoadResult<T, UnknownNode>
    switch content {
    case .success(let node): return .success(node)
    case .corrupted(let node): return .corrupted(node)
    case .failure: return .failure(())
    }
  }

  static func loadRows(_ rows: Array<JSONValue>) -> LoadResult<Array<ArrayNode.Row>, Void>
  {
    var result = Array<ArrayNode.Row>()
    result.reserveCapacity(rows.count)

    var corrupted = false

    for row in rows {
      guard case let .array(cells) = row else { return .failure(()) }

      var resultCells = Array<ArrayNode.Cell>()
      resultCells.reserveCapacity(cells.count)

      for cell in cells {
        let node = ArrayNode.Cell.loadSelfGeneric(from: cell)
        switch node {
        case .success(let node):
          resultCells.append(node)
        case .corrupted(let node):
          resultCells.append(node)
          corrupted = true
        case .failure:
          return .failure(())
        }
      }
      result.append(ArrayNode.Row(resultCells))
    }
    return corrupted ? .corrupted(result) : .success(result)
  }
}
