import Foundation

final class MathStylesNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathStyles: self, context)
  }

  final override class var type: NodeType { .mathStyles }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      switch styles {
      case .mathTextStyle(let mathTextStyle):
        let (variant, bold, italic) = mathTextStyle.tuple()
        current[MathProperty.variant] = .mathVariant(variant)
        if let bold = bold { current[MathProperty.bold] = .bool(bold) }
        if let italic = italic { current[MathProperty.italic] = .bool(italic) }

      case .mathStyle(let mathStyle):
        current[MathProperty.style] = .mathStyle(mathStyle)

      case .toInlineStyle:
        let key = MathProperty.style
        let mathStyle = key.resolveValue(current, styleSheet).mathStyle()!
        current[key] = .mathStyle(mathStyle.inlineParallel())
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { nucleus.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      let fragment = _NodeFragment(nucleus)
      _nodeFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard let fragment = _nodeFragment else {
        assertionFailure("Layout fragment is nil")
        return layoutLength()
      }

      var needsFixLayout = false

      if isDirty {
        let oldMetrics = fragment.nucleus.boxMetrics
        LayoutUtils
          .reconcileMathListLayoutFragment(nucleus, fragment.nucleus, parent: context)
        if fragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
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

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let styles = MathStyles.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid styles command: \(command)")
    }
    self.styles = styles
    self.nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    try super.init(from: decoder)
    _setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(styles.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathStyles.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(styles.command), nucleus])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [(MathIndex.nuc, nucleus)]
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
      assertionFailure("Unexpected direction")
      return nil
    }
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MathStylesNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let styles = MathStyles.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as NodeLoaded<CrampedNode>
    switch nucleus {
    case let .success(nucleus):
      let variant = MathStylesNode(styles, nucleus)
      return .success(variant)
    case let .corrupted(nucleus):
      let variant = MathStylesNode(styles, nucleus)
      return .corrupted(variant)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - MathStylesNode

  private typealias _NodeFragment = LayoutFragmentWrapper<MathListLayoutFragment>
  private var _nodeFragment: _NodeFragment?

  let styles: MathStyles
  let nucleus: ContentNode

  init(_ styles: MathStyles, _ nucleus: ElementStore) {
    self.styles = styles
    self.nucleus = ContentNode(nucleus)
    super.init()
    _setUp()
  }

  init(_ styles: MathStyles, _ nucleus: ContentNode) {
    self.styles = styles
    self.nucleus = nucleus
    super.init()
    _setUp()
  }

  private init(deepCopyOf node: MathStylesNode) {
    self.styles = node.styles
    self.nucleus = node.nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
  }

}
