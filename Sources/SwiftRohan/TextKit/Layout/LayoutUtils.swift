// Copyright 2024-2025 Lie Yan

import Foundation

enum LayoutUtils {

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  /// - Returns: A tuple containing the created layout context and the layout fragment.
  private static func createMathListLayoutContext(
    for component: ContentNode,
    parent context: LayoutContext
  ) -> (MathListLayoutContext, MathListLayoutFragment) {
    switch context {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
      let fragment = MathListLayoutFragment(mathContext)
      let context = MathListLayoutContext(context.styleSheet, mathContext, fragment)
      return (context, fragment)

    case let context as MathListLayoutContext:
      return createMathListLayoutContextEcon(for: component, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
  }

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - fragment: The layout fragment for the component.
  ///   - context: The parent layout context.
  static func createMathListLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    switch context {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
      return MathListLayoutContext(context.styleSheet, mathContext, fragment)

    case let context as MathListLayoutContext:
      return createMathListLayoutContextEcon(for: component, fragment, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
  }

  static func createContext(
    for component: ContentNode,
    _ fragment: MathLayoutFragment,
    parent context: LayoutContext
  ) -> LayoutContext {
    switch fragment {
    case let fragment as MathListLayoutFragment:
      return createMathListLayoutContext(for: component, fragment, parent: context)

    case let fragment as TextModeLayoutFragment:
      return TextLineLayoutContext(context.styleSheet, fragment)

    default:
      fatalError("unsupported layout fragment \(Swift.type(of: fragment))")
    }
  }

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  /// - Returns: A tuple containing the created layout context and the layout fragment.
  private static func createMathListLayoutContextEcon(
    for component: ContentNode,
    parent context: MathListLayoutContext
  ) -> (MathListLayoutContext, MathListLayoutFragment) {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet)
      .mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    return (context, fragment)
  }

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - fragment: The layout fragment for the component.
  ///   - context: The parent layout context.
  private static func createMathListLayoutContextEcon(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: MathListLayoutContext
  ) -> MathListLayoutContext {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet)
      .mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }

  // MARK: - Layout

  /// Layout the given component from scratch.
  static func createMathListLayoutFragment(
    _ component: ContentNode, parent: LayoutContext
  ) -> MathListLayoutFragment {
    let (subContext, fragment) = createMathListLayoutContext(
      for: component, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: true)
    subContext.endEditing()
    return fragment
  }

  static func reconcileMathListLayoutFragment(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: LayoutContext
  ) {
    let subContext = createMathListLayoutContext(for: component, fragment, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: false)
    subContext.endEditing()
  }

  static func createMathListLayoutFragmentEcon(
    _ component: ContentNode, parent: MathListLayoutContext
  ) -> MathListLayoutFragment {
    let (subContext, fragment) = createMathListLayoutContextEcon(
      for: component, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: true)
    subContext.endEditing()
    return fragment
  }

  static func reconcileMathListLayoutFragmentEcon(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: MathListLayoutContext, fromScratch: Bool = false
  ) {
    let subContext = createMathListLayoutContextEcon(
      for: component, fragment, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: fromScratch)
    subContext.endEditing()
  }

  static func layoutDelimiters(
    _ delimiters: DelimiterPair,
    _ target: Double, shortfall: Double,
    _ mathContext: MathContext
  ) -> (left: MathFragment?, right: MathFragment?) {
    let font = mathContext.getFont()

    func layout(_ char: Character) -> MathFragment? {
      let unicodeScalar = char.unicodeScalars.first!
      guard let fragment = GlyphFragment(unicodeScalar, font, mathContext.table)
      else { return nil }
      return fragment.stretchVertical(target, shortfall: shortfall, mathContext)
    }

    let left: MathFragment? = delimiters.open.value.flatMap { layout($0) }
    let right: MathFragment? = delimiters.close.value.flatMap { layout($0) }
    return (left, right)
  }

}
