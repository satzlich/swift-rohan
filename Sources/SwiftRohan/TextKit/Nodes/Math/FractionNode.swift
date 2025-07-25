import Foundation
import _RopeModule

/// Generalized fraction
final class FractionNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(fraction: self, context)
  }

  final override class var type: NodeType { .fraction }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      if let style = genfrac.style {
        current[MathProperty.style] = .mathStyle(style)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let numFragment =
        LayoutUtils.buildMathListLayoutFragment(numerator, parent: context)
      let denomFragment =
        LayoutUtils.buildMathListLayoutFragment(denominator, parent: context)
      let fractionFragment =
        MathFractionLayoutFragment(numFragment, denomFragment, genfrac)
      _nodeFragment = fractionFragment

      let mathContext = _resolveMathContext(context.mathContext)
      fractionFragment.fixLayout(mathContext)
      context.insertFragment(fractionFragment, self)
    }
    else {
      guard let fractionFragment = _nodeFragment
      else {
        assertionFailure("Fraction fragment should not be nil")
        return layoutLength()
      }

      // save old metrics before any layout changes
      let oldBoxMetrics = fractionFragment.boxMetrics
      var needsFixLayout = false

      if numerator.isDirty {
        let boxMetrics = fractionFragment.numerator.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragment(
          numerator, fractionFragment.numerator, parent: context)
        if fractionFragment.numerator.isNearlyEqual(to: boxMetrics) == false {
          needsFixLayout = true
        }
      }
      if denominator.isDirty {
        let boxMetrics = fractionFragment.denominator.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragment(
          denominator, fractionFragment.denominator, parent: context)
        if fractionFragment.denominator.isNearlyEqual(to: boxMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let mathContext = _resolveMathContext(context.mathContext)
        fractionFragment.fixLayout(mathContext)

        if fractionFragment.isNearlyEqual(to: oldBoxMetrics) == false {
          context.invalidateForward(layoutLength())
        }
        else {
          context.skipForward(layoutLength())
        }
      }
      else {
        context.skipForward(layoutLength())
      }
    }

    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command, num, denom }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let genfrac = MathGenFrac.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Unknown genfrac command: \(command)")
    }
    self.genfrac = genfrac
    self._numerator = try container.decode(NumeratorNode.self, forKey: .num)
    self._denominator = try container.decode(DenominatorNode.self, forKey: .denom)
    super.init()
    _setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(genfrac.command, forKey: .command)
    try container.encode(_numerator, forKey: .num)
    try container.encode(_denominator, forKey: .denom)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathGenFrac.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let num = numerator.store()
    let denom = denominator.store()
    let json = JSONValue.array([.string(genfrac.command), num, denom])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [
      (MathIndex.num, _numerator),
      (MathIndex.denom, _denominator),
    ]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: MathLayoutFragment? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .num: return _nodeFragment?.numerator
    case .denom: return _nodeFragment?.denominator
    default: return nil
    }
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nodeFragment?.getMathIndex(interactingAt: point)
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _nodeFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<FractionNode> {
    guard case let .array(array) = json,
      array.count == 3,
      case let .string(command) = array[0],
      let subtype = MathGenFrac.lookup(command)
    else { return .failure(UnknownNode(json)) }

    let num: NumeratorNode
    var corrupted: Bool = false

    switch NumeratorNode.loadSelf(from: array[1]) {
    case .success(let node):
      num = node
    case .corrupted(let node):
      num = node
      corrupted = true
    case .failure:
      return .failure(UnknownNode(json))
    }

    let denom: DenominatorNode
    switch DenominatorNode.loadSelf(from: array[2]) {
    case .success(let node):
      denom = node
    case .corrupted(let node):
      denom = node
      corrupted = true
    case .failure:
      return .failure(UnknownNode(json))
    }

    let node = FractionNode(num: num, denom: denom, genfrac: subtype)
    return corrupted ? .corrupted(node) : .success(node)
  }

  // MARK: - Fraction

  internal let genfrac: MathGenFrac

  private let _numerator: NumeratorNode
  private let _denominator: DenominatorNode
  internal var numerator: ContentNode { _numerator }
  internal var denominator: ContentNode { _denominator }

  private var _nodeFragment: MathFractionLayoutFragment? = nil

  init(num: ElementStore, denom: ElementStore, genfrac: MathGenFrac = .frac) {
    self.genfrac = genfrac
    self._numerator = NumeratorNode(num)
    self._denominator = DenominatorNode(denom)
    super.init()
    self._setUp()
  }

  init(num: NumeratorNode, denom: DenominatorNode, genfrac: MathGenFrac) {
    self.genfrac = genfrac
    self._numerator = num
    self._denominator = denom
    super.init()
    self._setUp()
  }

  private init(deepCopyOf fractionNode: FractionNode) {
    self.genfrac = fractionNode.genfrac
    self._numerator = fractionNode._numerator.deepCopy()
    self._denominator = fractionNode._denominator.deepCopy()
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    _numerator.setParent(self)
    _denominator.setParent(self)
  }

  private func _resolveMathContext(_ context: MathContext) -> MathContext {
    if let style = genfrac.style {
      return context.with(mathStyle: style)
    }
    else {
      return context
    }
  }
}
