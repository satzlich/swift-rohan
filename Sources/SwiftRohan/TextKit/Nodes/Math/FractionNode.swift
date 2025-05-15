// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

/// Generalized fraction
final class FractionNode: MathNode {
  override class var type: NodeType { .fraction }

  public typealias Subtype = FractionExpr.Subtype

  public let subtype: Subtype

  public init(num: [Node], denom: [Node], subtype: Subtype = .frac) {
    self.subtype = subtype
    self._numerator = NumeratorNode(num)
    self._denominator = DenominatorNode(denom)
    super.init()
    self._setUp()
  }

  init(deepCopyOf fractionNode: FractionNode) {
    self.subtype = fractionNode.subtype
    self._numerator = fractionNode._numerator.deepCopy()
    self._denominator = fractionNode._denominator.deepCopy()
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    _numerator.setParent(self)
    _denominator.setParent(self)
  }

  // MARK: - Codable

  // sync with FractionExpr
  private enum CodingKeys: CodingKey { case subtype, num, denom }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subtype = try container.decode(Subtype.self, forKey: .subtype)
    _numerator = try container.decode(NumeratorNode.self, forKey: .num)
    _denominator = try container.decode(DenominatorNode.self, forKey: .denom)
    super.init()
    _setUp()
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try container.encode(_numerator, forKey: .num)
    try container.encode(_denominator, forKey: .denom)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

  private var _fractionFragment: MathFractionLayoutFragment? = nil
  override var layoutFragment: MathLayoutFragment? { _fractionFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let numFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(numerator, parent: context)
      let denomFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(denominator, parent: context)
      let fractionFragment =
        MathFractionLayoutFragment(numFragment, denomFragment, subtype)
      _fractionFragment = fractionFragment

      let mathContext = resolveMathContext(context.mathContext)
      fractionFragment.fixLayout(mathContext)
      context.insertFragment(fractionFragment, self)
    }
    else {
      guard let fractionFragment = _fractionFragment
      else {
        assertionFailure("Fraction fragment should not be nil")
        return
      }

      var needsFixLayout = false
      if numerator.isDirty {
        let boxMetrics = fractionFragment.numerator.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          numerator, fractionFragment.numerator, parent: context)
        if fractionFragment.numerator.isNearlyEqual(to: boxMetrics) == false {
          needsFixLayout = true
        }
      }
      if denominator.isDirty {
        let boxMetrics = fractionFragment.denominator.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          denominator, fractionFragment.denominator, parent: context)
        if fractionFragment.denominator.isNearlyEqual(to: boxMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let boxMetrics = fractionFragment.boxMetrics

        let mathContext = resolveMathContext(context.mathContext)
        fractionFragment.fixLayout(mathContext)

        if fractionFragment.isNearlyEqual(to: boxMetrics) == false {
          context.invalidateBackwards(layoutLength())
        }
        else {
          context.skipBackwards(layoutLength())
        }
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }
  }

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .num:
      return _fractionFragment?.numerator
    case .denom:
      return _fractionFragment?.denominator
    default:
      return nil
    }
  }

  override final func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _fractionFragment?.getMathIndex(interactingAt: point)
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _fractionFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Components

  private let _numerator: NumeratorNode
  private let _denominator: DenominatorNode

  public var numerator: ContentNode { @inline(__always) get { _numerator } }
  public var denominator: ContentNode { @inline(__always) get { _denominator } }

  override func enumerateComponents() -> [MathNode.Component] {
    [
      (MathIndex.num, _numerator),
      (MathIndex.denom, _denominator),
    ]
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      if let enforcedStyle = subtype.style {
        properties[MathProperty.style] = .mathStyle(enforcedStyle)
      }
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  private func resolveMathContext(_ context: MathContext) -> MathContext {
    if let enforceStyle = subtype.style {
      return context.with(mathStyle: enforceStyle)
    }
    else {
      return context
    }
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(fraction: self, context)
  }

  override class var storageTags: [String] {
    MathGenFrac.predefinedCases.map { $0.command }
  }
}
