// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import _RopeModule

final class TextModeNode: MathNode {
  override class var type: NodeType { .textMode }

  let nucleus: ContentNode

  init(_ nucleus: [Node]) {
    self.nucleus = ContentNode(nucleus)
    super.init()
    _setUp()
  }

  init(_ nucleus: ContentNode) {
    self.nucleus = nucleus
    super.init()
    _setUp()
  }

  init(deepCopyOf node: TextModeNode) {
    self.nucleus = node.nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    try super.init(from: decoder)
    _setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(textMode: self, context)
  }

  private static let uniqueTag = "text"

  var command: String { Self.uniqueTag }

  override class var storageTags: [String] {
    [uniqueTag]
  }

  // MARK: - Storage

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(Self.uniqueTag), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<TextModeNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as _LoadResult<ContentNode>
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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  // MARK: - Content

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)

      let mathContext = MathUtils.resolveMathContext(properties, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFont().size)

      properties[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Layout

  override var isDirty: Bool { nucleus.isDirty }

  typealias _TextModeLayoutFragment = LayoutFragmentWrapper<UniLineLayoutFragment>
  private var _layoutFragment: _TextModeLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _layoutFragment }

  override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment, parent: any LayoutContext
  ) -> any LayoutContext {
    precondition(parent is MathListLayoutContext)
    precondition(fragment is UniLineLayoutFragment)
    let context = parent as! MathListLayoutContext
    let fragment = fragment as! UniLineLayoutFragment
    return TextLineLayoutContext(context.styleSheet, fragment)
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus =
        UniLineLayoutFragment.createTextMode(nucleus, context.styleSheet, .imageBounds)
      let fragment = _TextModeLayoutFragment(nucleus)
      _layoutFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard let fragment = _layoutFragment else {
        assertionFailure("Layout fragment is nil")
        return
      }

      let oldMetrics = fragment.boxMetrics
      var needsFixLayout = false

      if isDirty {
        fragment.nucleus = UniLineLayoutFragment.reconcileTextMode(
          fragment.nucleus, nucleus, context.styleSheet)
        fragment.fixLayout(context.mathContext)

        if fragment.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        context.invalidateBackwards(layoutLength())
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }
  }

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc: return _layoutFragment?.nucleus
    default: return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _layoutFragment != nil else { return nil }
    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _layoutFragment,
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
}
