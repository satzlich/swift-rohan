// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

final class MultilineNode: ArrayNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(multiline: self, context)
  }

  final override class var type: NodeType { .multiline }

  final override func selector() -> TargetSelector {
    MultilineNode.selector(isMultline: _isMultline())
  }

  // MARK: - Node(Layout)

  final override var isBlock: Bool { true }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is TextLayoutContext)
    return super.performLayout(context, fromScratch: fromScratch)
  }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathArray.blockMathCommands.map(\.command)
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
    _nodeFragment?.getGridIndex(interactingAt: point, shouldClamp: true)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MultilineNode> {
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

  // MARK: - MultilineNode

  override init(_ subtype: MathArray, _ rows: Array<Row>) {
    super.init(subtype, rows)
  }

  init(_ subtype: MathArray, _ rows: Array<Array<Cell>>) {
    let rows = rows.map { Row($0) }
    super.init(subtype, rows)
  }

  private init(deepCopyOf multilineNode: MultilineNode) {
    super.init(deepCopyOf: multilineNode)
  }

  internal static func selector(isMultline: Bool) -> TargetSelector {
    TargetSelector(.multiline, PropertyMatcher(.isMultline, .bool(isMultline)))
  }

  /// Returns true if this node corresponds to a `{multline}` environment.
  private func _isMultline() -> Bool {
    switch subtype.subtype {
    case .multline: return true
    default: return false
    }
  }

  /// Get the width of the content container for this array node.
  private static func _getContainerWidth(_ styleSheet: StyleSheet) -> Double {
    let pageWidth = styleSheet.resolveDefault(PageProperty.width).absLength()!
    let leftMargin = styleSheet.resolveDefault(PageProperty.leftMargin).absLength()!
    let rightMargin = styleSheet.resolveDefault(PageProperty.rightMargin).absLength()!
    let fontSize = styleSheet.resolveDefault(TextProperty.size).fontSize()!
    let containerWidth = pageWidth - leftMargin - rightMargin
    // 10pt for text container inset, 1em for leading padding.
    return containerWidth.ptValue - 10 - fontSize.floatValue
  }

  final override func _reconcileMathListLayoutFragment(
    _ element: ContentNode, _ fragment: MathListLayoutFragment,
    parent context: any LayoutContext, fromScratch: Bool, previousClass: MathClass? = nil
  ) {
    let context = context as! TextLayoutContext
    return LayoutUtils.reconcileMathListLayoutFragment(
      element, fragment, parent: context,
      fromScratch: fromScratch, previousClass: previousClass)
  }

  final override func _createMathArrayLayoutFragment(
    _ context: LayoutContext, _ mathContext: MathContext
  ) -> MathArrayLayoutFragment {
    let containerWidth = _isMultline() ? Self._getContainerWidth(context.styleSheet) : 0
    return MathArrayLayoutFragment(
      rowCount: rowCount, columnCount: columnCount, subtype: subtype,
      mathContext, containerWidth)
  }

  final override func _previousClass(_ rowIndex: Int, _ columnIndex: Int) -> MathClass? {
    _isMultline()
      ? (rowIndex > 0 ? MathClass.Normal : nil)
      : nil
  }
}
