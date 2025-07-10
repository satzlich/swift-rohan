// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

/// A node that override certain math attributes of generated fragment.
final class MathAttributesNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathAttributes: self, context)
  }

  final override class var type: NodeType { .mathAttributes }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _nucleus.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockStart: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.buildMathListLayoutFragment(_nucleus, parent: context)

      let attrFragment = MathAttributesLayoutFragment(nucleus, attributes: subtype)
      _nodeFragment = attrFragment

      attrFragment.fixLayout(context.mathContext)
      context.insertFragment(attrFragment, self)
    }
    else {
      guard let attrFragment = _nodeFragment
      else {
        assertionFailure("classFragment should not be nil")
        return layoutLength()
      }

      // save metrics before any layout changes
      let oldMetrics = attrFragment.boxMetrics
      var needsFixLayout = false

      if _nucleus.isDirty {
        let oldMetrics = attrFragment.nucleus.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragment(
          _nucleus, attrFragment.nucleus, parent: context)
        if attrFragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        attrFragment.fixLayout(context.mathContext)
        if attrFragment.isNearlyEqual(to: oldMetrics) == false {
          context.invalidateForward(layoutLength())
          return layoutLength()
        }
        // FALL THROUGH
      }
      context.skipForward(layoutLength())
    }
    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let attributes = MathAttributes.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid math attributes command: \(command)")
    }
    self.subtype = attributes
    self._nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathAttributes.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = _nucleus.store()
    let json = JSONValue.array([.string(subtype.command), nucleus])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: (any MathLayoutFragment)? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> (any LayoutFragment)? {
    switch index {
    case .nuc: return _nodeFragment?.nucleus
    default: return nil
    }
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _nodeFragment != nil else { return nil }
    return .nuc
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _nodeFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up: return RayshootResult(point.with(y: fragment.minY), false)
    case .down: return RayshootResult(point.with(y: fragment.maxY), false)
    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MathAttributesNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let attributes = MathAttributes.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as NodeLoaded<ContentNode>
    switch nucleus {
    case let .success(nucleus):
      let node = MathAttributesNode(attributes, nucleus)
      return .success(node)
    case let .corrupted(nucleus):
      let node = MathAttributesNode(attributes, nucleus)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - MathAttributesNode

  let subtype: MathAttributes
  private let _nucleus: ContentNode
  var nucleus: ContentNode { _nucleus }

  private typealias _NodeFragment = MathAttributesLayoutFragment<MathListLayoutFragment>
  private var _nodeFragment: _NodeFragment?

  init(_ mathAttributes: MathAttributes, _ nucleus: ElementStore) {
    self.subtype = mathAttributes
    self._nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  init(_ mathAttributes: MathAttributes, _ nucleus: ContentNode) {
    self.subtype = mathAttributes
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  private init(deepCopyOf node: MathAttributesNode) {
    self.subtype = node.subtype
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._nucleus.setParent(self)
  }

}
