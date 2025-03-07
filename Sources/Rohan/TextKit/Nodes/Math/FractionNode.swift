// Copyright 2024-2025 Lie Yan

import Foundation

/** Generalized fraction */
public final class FractionNode: MathNode {
  override class var nodeType: NodeType { .fraction }

  public init(_ numerator: [Node], _ denominator: [Node], isBinomial: Bool = false) {
    self.isBinomial = isBinomial
    self._numerator = NumeratorNode(numerator)
    self._denominator = DenominatorNode(denominator)
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

  // MARK: - Layout

  override var isBlock: Bool { false }
  override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

  private var _fractionFragment: MathFractionLayoutFragment? = nil
  override var layoutFragment: MathLayoutFragment? { _fractionFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    func layoutComponent(
      _ component: ContentNode, _ fragment: inout MathListLayoutFragment?, fromScratch: Bool
    ) {
      let subContext = Self.createLayoutContextEcon(for: component, &fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: fromScratch)
      subContext.endEditing()
    }
    func layoutComponent(
      _ component: ContentNode, _ fragment: MathListLayoutFragment, fromScratch: Bool
    ) {
      let subContext = Self.createLayoutContextEcon(for: component, fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: fromScratch)
      subContext.endEditing()
    }

    if fromScratch {
      var numFragment: MathListLayoutFragment?
      var denomFragment: MathListLayoutFragment?
      layoutComponent(numerator, &numFragment, fromScratch: true)
      layoutComponent(denominator, &denomFragment, fromScratch: true)
      _fractionFragment = MathFractionLayoutFragment(numFragment!, denomFragment!, isBinomial)
      _fractionFragment!.fixLayout(context.mathContext)
      context.insertFragment(_fractionFragment!, self)
    }
    else {
      var needsFixLayout = false
      if numerator.isDirty {
        let numBounds = _fractionFragment!.numerator.bounds
        layoutComponent(numerator, _fractionFragment!.numerator, fromScratch: false)
        if _fractionFragment!.numerator.bounds.isNearlyEqual(to: numBounds) == false {
          needsFixLayout = true
        }
      }
      if denominator.isDirty {
        let denomBounds = _fractionFragment!.denominator.bounds
        layoutComponent(denominator, _fractionFragment!.denominator, fromScratch: false)
        if _fractionFragment!.denominator.bounds.isNearlyEqual(to: denomBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = _fractionFragment!.bounds
        _fractionFragment!.fixLayout(context.mathContext)
        if !bounds.isNearlyEqual(to: _fractionFragment!.bounds) {
          context.invalidateBackwards(layoutLength)
        }
        else {
          context.skipBackwards(layoutLength)
        }
      }
      else {
        context.skipBackwards(layoutLength)
      }
    }
  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    switch index {
    case .numerator:
      return _fractionFragment?.numerator
    case .denominator:
      return _fractionFragment?.denominator
    default:
      return nil
    }
  }

  override final func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard let fragment = _fractionFragment else { return nil }
    return point.y <= fragment.rulePosition.y ? .numerator : .denominator
  }

  override func rayshoot(
    from point: CGPoint, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _fractionFragment else { return nil }

    switch direction {
    case .up:
      if point.y <= fragment.rulePosition.y {  // numerator
        // move to top of fraction
        let y = fragment.glyphFrame.origin.y - fragment.ascent
        return RayshootResult(point.with(y: y), false)
      }
      else {  // denominator
        // move to bottom of numerator
        let y = fragment.numerator.glyphFrame.origin.y + fragment.numerator.descent
        return RayshootResult(point.with(y: y), true)
      }

    case .down:
      if point.y <= fragment.rulePosition.y {  // numerator
        // move to top of denominator
        let y = fragment.denominator.glyphFrame.origin.y - fragment.denominator.ascent
        return RayshootResult(point.with(y: y), true)
      }
      else {  // denominator
        // move to bottom of fraction
        let y = fragment.glyphFrame.origin.y + fragment.descent
        return RayshootResult(point.with(y: y), false)
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
      (MathIndex.numerator, _numerator),
      (MathIndex.denominator, _denominator),
    ]
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(fraction: self, context)
  }
}

final class NumeratorNode: ContentNode {
  override func deepCopy() -> NumeratorNode { NumeratorNode(deepCopyOf: self) }

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
