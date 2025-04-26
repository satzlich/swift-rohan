// Copyright 2024-2025 Lie Yan

import Foundation

enum LayoutUtils {

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  /// - Returns: A tuple containing the created layout context and the layout fragment.
  private static func createContext(
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
      return createContextEcon(for: component, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
  }

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - fragment: The layout fragment for the component.
  ///   - context: The parent layout context.
  static func createContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    switch context {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
      return MathListLayoutContext(context.styleSheet, mathContext, fragment)

    case let context as MathListLayoutContext:
      return createContextEcon(for: component, fragment, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
  }

  /// Creates a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  /// - Returns: A tuple containing the created layout context and the layout fragment.
  private static func createContextEcon(
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
  private static func createContextEcon(
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
  static func createFragment(
    _ component: ContentNode, parent: LayoutContext
  ) -> MathListLayoutFragment {
    let (subContext, fragment) = createContext(for: component, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: true)
    subContext.endEditing()
    return fragment
  }

  static func reconcileFragment(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: LayoutContext
  ) {
    let subContext = createContext(for: component, fragment, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: false)
    subContext.endEditing()
  }

  static func createFragmentEcon(
    _ component: ContentNode, parent: MathListLayoutContext
  ) -> MathListLayoutFragment {
    let (subContext, fragment) = createContextEcon(for: component, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: true)
    subContext.endEditing()
    return fragment
  }

  static func reconcileFragmentEcon(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: MathListLayoutContext, fromScratch: Bool = false
  ) {
    let subContext = createContextEcon(for: component, fragment, parent: parent)
    subContext.beginEditing()
    component.performLayout(subContext, fromScratch: fromScratch)
    subContext.endEditing()
  }
}
