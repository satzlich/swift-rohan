// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantNode: MathNode {
  override class var type: NodeType { .mathVariant }

  let mathTextStyle: MathTextStyle
  let nucleus: ContentNode

  init(_ mathTextStyle: MathTextStyle, _ nucleus: [Node]) {
    self.mathTextStyle = mathTextStyle
    self.nucleus = ContentNode(nucleus)
    super.init()
    _setUp()
  }

  init(_ mathTextStyle: MathTextStyle, _ nucleus: ContentNode) {
    self.mathTextStyle = mathTextStyle
    self.nucleus = nucleus
    super.init()
    _setUp()
  }

  internal init(deepCopyOf node: MathVariantNode) {
    self.mathTextStyle = node.mathTextStyle
    self.nucleus = node.nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case textStyle, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathTextStyle = try container.decode(MathTextStyle.self, forKey: .textStyle)
    self.nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathTextStyle, forKey: .textStyle)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathVariant: self, context)
  }

  // MARK: - Storage

  override class var storageTags: [String] {
    MathTextStyle.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(mathTextStyle.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MathVariantNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let textStyle = MathTextStyle.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as _LoadResult<CrampedNode>
    switch nucleus {
    case let .success(nucleus):
      let variant = MathVariantNode(textStyle, nucleus)
      return .success(variant)
    case let .corrupted(nucleus):
      let variant = MathVariantNode(textStyle, nucleus)
      return .corrupted(variant)
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
      let (variant, bold, italic) = mathTextStyle.tuple()
      properties[MathProperty.variant] = .mathVariant(variant)
      if let bold = bold {
        properties[MathProperty.bold] = .bool(bold)
      }
      if let italic = italic {
        properties[MathProperty.italic] = .bool(italic)
      }
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Layout

  override var isDirty: Bool { nucleus.isDirty }

  private typealias _MathVariantLayoutFragment =
    MathLayoutFragmentWrapper<TextLineLayoutFragment>
  private var _layoutFragment: _MathVariantLayoutFragment?
  override var layoutFragment: (any MathLayoutFragment)? { _layoutFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus = TextLineLayoutFragment.createMathMode(
        nucleus, context.styleSheet, context.mathContext, .imageBounds)
      let fragment = _MathVariantLayoutFragment(nucleus)
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
        fragment.nucleus =
          TextLineLayoutFragment.reconcileMathMode(
            fragment.nucleus, nucleus, context.styleSheet, context.mathContext)
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

  override func getFragment(_ index: MathIndex) -> (any LayoutFragment)? {
    switch index {
    case .nuc: return _layoutFragment?.nucleus
    default: return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard let fragment = _layoutFragment else { return nil }
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
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}
