// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

final class MatrixNode: ArrayNode {
  // MARK: - Node
  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }

  final override class var type: NodeType { .matrix }

  // MARK: - Node(Layout)

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockStart: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    return super.performLayout(
      context, fromScratch: fromScratch, atBlockStart: atBlockStart)
  }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathArray.inlineMathCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let rows: Array<JSONValue> = _rows.map { row in
      let children: Array<JSONValue> = row.map { $0.store() }
      return JSONValue.array(children)
    }
    let json = JSONValue.array([.string(subtype.command), .array(rows)])
    return json
  }

  // MARK: - ArrayNode

  final override func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    _nodeFragment?.getGridIndex(interactingAt: point)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MatrixNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = MathArray.lookup(tag),
      case let .array(rows) = array[1]
    else { return .failure(UnknownNode(json)) }

    let resultRows = NodeStoreUtils.loadRows(rows)
    switch resultRows {
    case .success(let rows):
      let node = Self(subtype, rows)
      return .success(node)
    case .corrupted(let rows):
      let node = Self(subtype, rows)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - MatrixNode

  override init(_ subtype: MathArray, _ rows: Array<Row>) {
    super.init(subtype, rows)
  }

  init(_ subtype: MathArray, _ rows: Array<Array<Cell>>) {
    let rows = rows.map { Row($0) }
    super.init(subtype, rows)
  }

  private init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
  }

  final override func _reconcileMathListLayoutFragment(
    _ element: ContentNode, _ fragment: MathListLayoutFragment,
    parent context: LayoutContext,
    fromScratch: Bool, previousClass: MathClass? = nil
  ) {
    let context = context as! MathListLayoutContext
    return LayoutUtils.reconcileMathListLayoutFragment(
      element, fragment, parent: context,
      fromScratch: fromScratch, previousClass: previousClass)
  }
}
