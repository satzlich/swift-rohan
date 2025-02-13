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
    _numerator.parent = self
    _denominator.parent = self
  }

  init(deepCopyOf fractionNode: FractionNode) {
    self.isBinomial = fractionNode.isBinomial
    self._numerator = fractionNode._numerator.deepCopy()
    self._denominator = fractionNode._denominator.deepCopy()
    super.init()
    _numerator.parent = self
    _denominator.parent = self
  }

  // MARK: - Layout

  override var isBlock: Bool { false }
  override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

  private var _fractionFragment: MathFractionLayoutFragment? = nil

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let numFragment = MathListLayoutFragment(context.mathContext.textColor)
      let denomFragment = MathListLayoutFragment(context.mathContext.textColor)
      _fractionFragment = MathFractionLayoutFragment(numFragment, denomFragment, isBinomial)
      Self.layoutComponent(
        parent: context, numerator, _fractionFragment!.numerator, fromScratch: true)
      Self.layoutComponent(
        parent: context, denominator, _fractionFragment!.denominator, fromScratch: true)
      _fractionFragment!.fixLayout(context.mathContext)
      context.insertFragment(_fractionFragment!, self)
    }
    else {
      var needsFixLayout = false
      if numerator.isDirty {
        let numBounds = _fractionFragment!.numerator.bounds
        Self.layoutComponent(
          parent: context, numerator, _fractionFragment!.numerator, fromScratch: false)
        if _fractionFragment!.numerator.bounds.isApproximatelyEqual(to: numBounds) == false {
          needsFixLayout = true
        }
      }
      if denominator.isDirty {
        let denomBounds = _fractionFragment!.denominator.bounds
        Self.layoutComponent(
          parent: context, denominator, _fractionFragment!.denominator, fromScratch: false)
        if _fractionFragment!.denominator.bounds.isApproximatelyEqual(to: denomBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = _fractionFragment!.bounds
        _fractionFragment!.fixLayout(context.mathContext)
        if !bounds.isApproximatelyEqual(to: _fractionFragment!.bounds) {
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

  // MARK: - Components

  public let isBinomial: Bool

  fileprivate let _numerator: NumeratorNode
  fileprivate let _denominator: DenominatorNode

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

private final class NumeratorNode: ContentNode {
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

private final class DenominatorNode: ContentNode {
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
