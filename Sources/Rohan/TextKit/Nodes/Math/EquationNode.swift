// Copyright 2024-2025 Lie Yan

import AppKit

public final class EquationNode: MathNode {
  override class var nodeType: NodeType { .equation }

  public init(isBlock: Bool, _ nucleus: [Node] = []) {
    self._isBlock = isBlock
    self.nucleus = ContentNode(nucleus)
    super.init()
    self.nucleus.parent = self
  }

  internal init(deepCopyOf equationNode: EquationNode) {
    self._isBlock = equationNode._isBlock
    self.nucleus = equationNode.nucleus.deepCopy()
    super.init()
    nucleus.parent = self
  }

  // MARK: - Layout

  private let _isBlock: Bool
  override public var isBlock: Bool { _isBlock }

  override var isDirty: Bool { nucleus.isDirty }

  private var _nucleusFragment: MathListLayoutFragment? = nil

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    func layoutComponent(
      _ mathContext: MathContext, _ component: ContentNode,
      _ fragment: MathListLayoutFragment, fromScratch: Bool
    ) {
      let context_ = MathListLayoutContext(context.styleSheet, mathContext, fragment)
      context_.beginEditing()
      component.performLayout(context_, fromScratch: fromScratch)
      context_.endEditing()
    }

    if fromScratch {
      let mathContext = MathUtils.resolveMathContext(for: nucleus, context.styleSheet)
      _nucleusFragment = MathListLayoutFragment(mathContext.textColor)
      // layout for nucleus
      layoutComponent(mathContext, nucleus, _nucleusFragment!, fromScratch: true)
      // insert fragment
      context.insertFragment(_nucleusFragment!, self)
    }
    else {
      assert(_nucleusFragment != nil)
      let mathContext = MathUtils.resolveMathContext(for: nucleus, context.styleSheet)
      // layout for nucleus
      layoutComponent(mathContext, nucleus, _nucleusFragment!, fromScratch: false)
      // invalidate
      context.invalidateBackwards(layoutLength)
    }
  }

  final override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    guard index == .nucleus else { return nil }
    return _nucleusFragment
  }

  // MARK: - Styles

  override public func selector() -> TargetSelector {
    EquationNode.selector(isBlock: _isBlock)
  }

  public static func selector(isBlock: Bool? = nil) -> TargetSelector {
    return isBlock != nil
      ? TargetSelector(.equation, PropertyMatcher(.isBlock, .bool(isBlock!)))
      : TargetSelector(.equation)
  }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // if there is no math style, compute and set
      let key = MathProperty.style
      if properties[key] == nil {
        properties[key] = .mathStyle(isBlock ? .display : .text)
      }
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Components

  public let nucleus: ContentNode

  override final func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nucleus, nucleus)]
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(equation: self, context)
  }
}
