// Copyright 2024-2025 Lie Yan

import Foundation

final class CounterNode: SimpleNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(counter: self, context)
  }

  final override class var type: NodeType { .counter }

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { _counterText.length }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    if fromScratch {
      _counterText = "\(countHolder.value())"
      return StringReconciler.insertForward(new: _counterText, context: context, self)
    }
    else {
      let counterText = "\(countHolder.value())"
      defer { _counterText = counterText }
      return StringReconciler.reconcileForward(
        dirty: (_counterText, counterText), context: context, self)
    }
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: String, CodingKey {
    case counterName
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let counterName = try container.decode(CounterName.self, forKey: .counterName)
    self._counterSegment = CounterSegment(CountHolder(counterName))
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(countHolder.counterName, forKey: .counterName)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  private static let uniqueTag = "counter"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let json = JSONValue.array([
      .string(Self.uniqueTag), .string(countHolder.counterName.rawValue),
    ])
    return json
  }

  // MARK: - Node(Counter)

  final override var counterSegment: CounterSegment? { _counterSegment }

  // MARK: - Storage

  class func loadSelf(from json: JSONValue) -> NodeLoaded<CounterNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      case let .string(counterNameStr) = array[1],
      let counterName = CounterName(rawValue: counterNameStr)
    else {
      return .failure(UnknownNode(json))
    }
    let counterNode = CounterNode(counterName)
    return .success(counterNode)
  }

  // MARK: - CounterNode

  private let _counterSegment: CounterSegment
  private final var countHolder: CountHolder { _counterSegment.begin }

  private var _counterText: String = ""

  init(_ counterName: CounterName) {
    self._counterSegment = CounterSegment(CountHolder(counterName))
    super.init()
  }

  private init(deepCopyOf other: CounterNode) {
    let counterName = other.countHolder.counterName
    self._counterSegment = CounterSegment(CountHolder(counterName))
    super.init()
  }
}
