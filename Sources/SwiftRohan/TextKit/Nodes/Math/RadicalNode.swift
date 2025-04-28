// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class RadicalNode: MathNode {
  override class var type: NodeType { .radical }

  private let _radicand: CrampedNode
  var radicand: ContentNode { _radicand }

  private var _index: SuperscriptNode?
  var index: ContentNode? { _index }

  init(_ radicand: CrampedNode, _ index: SuperscriptNode?) {
    self._radicand = radicand
    self._index = index
    super.init()
    self._setUp()
  }

  init(_ radicand: [Node], _ index: [Node]?) {
    self._radicand = CrampedNode(radicand)
    self._index = index.map { SuperscriptNode($0) }
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._radicand.setParent(self)
    self._index?.setParent(self)
  }

  init(deepCopyOf node: RadicalNode) {
    self._radicand = node._radicand.deepCopy()
    self._index = node._index?.deepCopy()
    super.init()
    self._setUp()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case radicand, index }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self._radicand = try container.decode(CrampedNode.self, forKey: .radicand)
    self._index = try container.decodeIfPresent(SuperscriptNode.self, forKey: .index)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_radicand, forKey: .radicand)
    try container.encodeIfPresent(_index, forKey: .index)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func contentDidChange(delta: Node.LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    super.contentDidChange(delta: delta, inStorage: inStorage)
  }

  override func stringify() -> BigString {
    "radical"
  }

  // MARK: - Layout

  override var isBlock: Bool { false }
  private var _isDirty: Bool = false
  override var isDirty: Bool { _isDirty }

  override var layoutFragment: (any MathLayoutFragment)? { preconditionFailure() }

  private var _snapshot: ComponentSet? = nil

  private func makeSnapshotOnce() {
    if _snapshot == nil {
      _snapshot = ComponentSet()
      if _index != nil { _snapshot!.insert(.index) }
    }
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    preconditionFailure()
  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    preconditionFailure()
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure()
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure()
  }

  // MARK: - Component

  override func enumerateComponents() -> [MathNode.Component] {
    if _index != nil {
      return [(.radicand, _radicand), (.index, _index!)]
    }
    else {
      return [(.radicand, _radicand)]
    }
  }

  func addComponent(_ mathIndex: MathIndex, _ content: [Node], inStorage: Bool) {
    precondition(mathIndex == .index)

    if inStorage { makeSnapshotOnce() }

    switch mathIndex {
    case .index:
      assert(_index == nil)
      _index = SuperscriptNode(content)
      _index!.setParent(self)

    default:
      assertionFailure("Unsupported index")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeComponent(_ mathIndex: MathIndex, inStorage: Bool) {
    precondition(mathIndex == .index)

    if inStorage { makeSnapshotOnce() }

    switch mathIndex {
    case .index:
      assert(_index != nil)
      _index = nil

    default:
      assertionFailure("Unsupported index")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

}
