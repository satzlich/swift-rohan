// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

/// Generalized fraction
public final class FractionNode: MathNode {
  override class var type: NodeType { .fraction }

  public init(num: [Node], denom: [Node], isBinomial: Bool = false) {
    self.isBinomial = isBinomial
    self._numerator = NumeratorNode(num)
    self._denominator = DenominatorNode(denom)
    super.init()
    self._setUp()
  }

  init(deepCopyOf fractionNode: FractionNode) {
    self.isBinomial = fractionNode.isBinomial
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
  private enum CodingKeys: CodingKey { case isBinom, num, denom }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isBinomial = try container.decode(Bool.self, forKey: .isBinom)
    _numerator = try container.decode(NumeratorNode.self, forKey: .num)
    _denominator = try container.decode(DenominatorNode.self, forKey: .denom)
    super.init()
    _setUp()
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(isBinomial, forKey: .isBinom)
    try container.encode(_numerator, forKey: .num)
    try container.encode(_denominator, forKey: .denom)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override final func stringify() -> BigString {
    "(" + _numerator.stringify() + ")/(" + _denominator.stringify() + ")"
  }

  // MARK: - Layout

  override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

  private var _fractionFragment: MathFractionLayoutFragment? = nil
  override var layoutFragment: MathLayoutFragment? { _fractionFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let numFragment = LayoutUtils.createMathListLayoutFragmentEcon(
        numerator, parent: context)
      let denomFragment = LayoutUtils.createMathListLayoutFragmentEcon(
        denominator, parent: context)
      let fractionFragment =
        MathFractionLayoutFragment(numFragment, denomFragment, isBinomial)
      _fractionFragment = fractionFragment
      fractionFragment.fixLayout(context.mathContext)
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
        fractionFragment.fixLayout(context.mathContext)
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

  override func getFragment(_ index: MathIndex) -> MathLayoutFragment? {
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
    guard let fragment = _fractionFragment else { return nil }
    return point.y <= fragment.rulePosition.y ? .num : .denom
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _fractionFragment,
      [MathIndex.num, .denom].contains(component)
    else { return nil }

    switch direction {
    case .up:
      if component == .num {  // numerator
        // move to top of fraction
        return RayshootResult(point.with(y: fragment.minY), false)
      }
      else {  // denominator
        // move to bottom of numerator
        return RayshootResult(point.with(y: fragment.numerator.maxY), true)
      }

    case .down:
      if component == .num {  // numerator
        // move to top of denominator
        if fragment.denominator.isEmpty {
          // special workaround for empty denominator
          let y = fragment.rulePosition.y + 0.1
          return RayshootResult(point.with(y: y), true)
        }
        else {
          return RayshootResult(point.with(y: fragment.denominator.minY), true)
        }
      }
      else {  // denominator
        // move to bottom of fraction
        return RayshootResult(point.with(y: fragment.maxY), false)
      }
    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  // MARK: - Components

  public let isBinomial: Bool

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

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(fraction: self, context)
  }

  // MARK: - Component

  final class NumeratorNode: ContentNode {
    override func deepCopy() -> NumeratorNode { NumeratorNode(deepCopyOf: self) }
    override func cloneEmpty() -> Self { Self() }

    override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
      if _cachedProperties == nil {
        // inherit properties
        var properties = super.getProperties(styleSheet)
        // set math style ← fraction style
        let key = MathProperty.style
        let value = resolveProperty(key, styleSheet).mathStyle()!
        properties[key] = .mathStyle(MathUtils.fractionStyle(for: value))
        // cache properties
        _cachedProperties = properties
      }
      return _cachedProperties!
    }
  }

  final class DenominatorNode: ContentNode {
    override func deepCopy() -> DenominatorNode { DenominatorNode(deepCopyOf: self) }

    override func cloneEmpty() -> Self { Self() }

    override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
      if _cachedProperties == nil {
        // inherit properties
        var properties = super.getProperties(styleSheet)

        // set math style ← fraction style
        let key = MathProperty.style
        let value = resolveProperty(key, styleSheet).mathStyle()!
        properties[key] = .mathStyle(MathUtils.fractionStyle(for: value))
        // set cramped ← true
        properties[MathProperty.cramped] = .bool(true)

        // cache properties
        _cachedProperties = properties
      }
      return _cachedProperties!
    }
  }
}
