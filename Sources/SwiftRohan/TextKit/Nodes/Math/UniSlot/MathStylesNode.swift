// Copyright 2024-2025 Lie Yan

import Foundation

final class MathStylesNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

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

      case .inlineStyle:
        let key = MathProperty.style
        let mathStyle = key.resolveValue(current, styleSheet).mathStyle()!
        current[key] = .mathStyle(mathStyle.inlineParallel())
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  final override var isDirty: Bool { nucleus.isDirty }

  // MARK: - MathStylesNode

  let styles: MathStyles
  let nucleus: ContentNode

  init(_ styles: MathStyles, _ nucleus: [Node]) {
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

  // MARK: - Codable

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

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(styles.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathStyles: self, context)
  }

  // MARK: - Storage

  override class var storageTags: [String] {
    MathStyles.allCommands.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(styles.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MathStylesNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let styles = MathStyles.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as _LoadResult<CrampedNode>
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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  // MARK: - Content

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Layout

  private typealias _MathStylesLayoutFragment =
    LayoutFragmentWrapper<MathListLayoutFragment>
  private var _layoutFragment: _MathStylesLayoutFragment?
  override var layoutFragment: (any MathLayoutFragment)? { _layoutFragment }

  override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment, parent: any LayoutContext
  ) -> any LayoutContext {
    defaultInitLayoutContext(for: component, fragment, parent: parent)
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      let fragment = _MathStylesLayoutFragment(nucleus)
      _layoutFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard let fragment = _layoutFragment else {
        assertionFailure("Layout fragment is nil")
        return
      }

      var needsFixLayout = false

      if isDirty {
        let oldMetrics = fragment.nucleus.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragment(
          nucleus, fragment.nucleus, parent: context)
        if fragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
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
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}
