// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import _RopeModule

final class TextModeNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(textMode: self, context)
  }

  final override class var type: NodeType { .textMode }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let mathContext = MathUtils.resolveMathContext(current, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFont().size)
      current[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { nucleus.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockStart: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus =
        CTLineLayoutFragment.createTextMode(nucleus, context.styleSheet, .imageBounds)
      let fragment = _NodeFragment(nucleus)
      _nodeFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard let fragment = _nodeFragment else {
        assertionFailure("Layout fragment is nil")
        return layoutLength()
      }

      let oldMetrics = fragment.boxMetrics
      var needsFixLayout = false

      if isDirty {
        fragment.nucleus =
          CTLineLayoutFragment.reconcileTextMode(
            fragment.nucleus, nucleus, context.styleSheet)
        fragment.fixLayout(context.mathContext)

        if fragment.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        context.invalidateForward(layoutLength())
      }
      else {
        context.skipForward(layoutLength())
      }
    }

    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    try super.init(from: decoder)
    _setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(Self.uniqueTag), nucleus])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: (any MathLayoutFragment)? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc: return _nodeFragment?.nucleus
    default: return nil
    }
  }

  final override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment,
    parent context: any LayoutContext
  ) -> any LayoutContext {
    precondition(fragment is CTLineLayoutFragment)
    let fragment = fragment as! CTLineLayoutFragment
    return TextLineLayoutContext(context.styleSheet, fragment)
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
      assertionFailure("Unexpected Direction")
      return nil
    }
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<TextModeNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as NodeLoaded<ContentNode>
    switch nucleus {
    case .success(let nucleus):
      let textMode = TextModeNode(nucleus)
      return .success(textMode)
    case .corrupted(let nucleus):
      let textMode = TextModeNode(nucleus)
      return .corrupted(textMode)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - TextModeNode

  internal typealias _NodeFragment = LayoutFragmentWrapper<CTLineLayoutFragment>
  private var _nodeFragment: _NodeFragment? = nil

  let nucleus: ContentNode

  init(_ nucleus: ElementStore) {
    self.nucleus = ContentNode(nucleus)
    super.init()
    _setUp()
  }

  init(_ nucleus: ContentNode) {
    self.nucleus = nucleus
    super.init()
    _setUp()
  }

  private init(deepCopyOf node: TextModeNode) {
    self.nucleus = node.nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
  }

  private static let uniqueTag = "text"

  var command: String { Self.uniqueTag }

}
