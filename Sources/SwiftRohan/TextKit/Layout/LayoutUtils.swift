// Copyright 2024-2025 Lie Yan

import Foundation

enum LayoutUtils {
  /// Initialize MathListLayoutContext and MathListLayoutFragment for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  private static func initMathLayoutContextAndFragment(
    for component: ContentNode, parent context: TextLayoutContext
  ) -> (MathListLayoutContext, MathListLayoutFragment) {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    return (context, fragment)
  }

  /// Initialize MathListLayoutContext and MathListLayoutFragment for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - context: The parent layout context.
  private static func initMathLayoutContextAndFragment(
    for component: ContentNode,
    parent context: MathListLayoutContext
  ) -> (MathListLayoutContext, MathListLayoutFragment) {
    let style =
      component.resolveValue(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    return (context, fragment)
  }

  /// Initialize MathListLayoutContext for the given component and fragment.
  static func initMathListLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: TextLayoutContext
  ) -> MathListLayoutContext {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }

  /// Initialize a layout context for the given component.
  /// - Parameters:
  ///   - component: The component to create the layout context for.
  ///   - fragment: The layout fragment for the component.
  ///   - context: The parent layout context.
  static func initMathListLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: MathListLayoutContext
  ) -> MathListLayoutContext {
    let style =
      component.resolveValue(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }

  /// Layout the given component from scratch.
  static func buildMathListLayoutFragment(
    _ component: ContentNode, parent: TextLayoutContext
  ) -> MathListLayoutFragment {
    let (context, fragment) =
      initMathLayoutContextAndFragment(for: component, parent: parent)
    context.beginEditing()
    _ = component.performLayout(context, fromScratch: true)
    context.endEditing()
    assert(fragment.contentLayoutLength == component.layoutLength())
    return fragment
  }

  static func reconcileMathListLayoutFragment(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: TextLayoutContext
  ) {
    let context = initMathListLayoutContext(for: component, fragment, parent: parent)
    context.beginEditing()
    _ = component.performLayout(context, fromScratch: false)
    context.endEditing()
    assert(fragment.contentLayoutLength == component.layoutLength())
  }

  /// Layout the given component from scratch.
  static func buildMathListLayoutFragment(
    _ component: ContentNode, parent: MathListLayoutContext
  ) -> MathListLayoutFragment {
    let (context, fragment) =
      initMathLayoutContextAndFragment(for: component, parent: parent)
    context.beginEditing()
    _ = component.performLayout(context, fromScratch: true)
    context.endEditing()
    assert(fragment.contentLayoutLength == component.layoutLength())
    return fragment
  }

  static func reconcileMathListLayoutFragment(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: MathListLayoutContext
  ) {
    reconcileMathListLayoutFragment(
      component, fragment, parent: parent, fromScratch: false)
  }

  static func reconcileMathListLayoutFragment(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent: MathListLayoutContext, fromScratch: Bool
  ) {
    let context = initMathListLayoutContext(for: component, fragment, parent: parent)
    context.beginEditing()
    _ = component.performLayout(context, fromScratch: fromScratch)
    context.endEditing()
    assert(fragment.contentLayoutLength == component.layoutLength())
  }

  // MARK: - Layout

  static func layoutDelimiters(
    _ delimiters: DelimiterPair,
    _ target: Double, shortfall: Double,
    _ mathContext: MathContext
  ) -> (left: MathFragment?, right: MathFragment?) {
    let font = mathContext.getFont()

    func layout(_ char: Character) -> MathFragment? {
      let unicodeScalar = char.unicodeScalars.first!
      if let fragment = GlyphFragment(unicodeScalar, font, mathContext.table) {
        return fragment.stretch(
          orientation: .vertical, target: target, shortfall: shortfall, mathContext)
      }
      else {
        let fallback = MathUtils.fallbackMathContext(for: mathContext)
        if let fragment = GlyphFragment(unicodeScalar, fallback.getFont(), fallback.table)
        {
          return fragment.stretch(
            orientation: .vertical, target: target, shortfall: shortfall, fallback)
        }
        else {
          let ruler = RuleFragment(width: font.size, height: 2)
          return ColoredFragment(color: .red, wrapped: ruler)
        }
      }
    }

    let left: MathFragment? = delimiters.open.value.flatMap { layout($0) }
    let right: MathFragment? = delimiters.close.value.flatMap { layout($0) }
    return (left, right)
  }

  /// Rayshoot further if the result is not resolved.
  static func rayshootFurther(
    _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity,
    _ direction: TextSelectionNavigation.Direction,
    _ result: RayshootResult, _ context: LayoutContext
  ) -> RayshootResult? {
    guard result.isResolved == false else { return result }

    switch context {
    case let textContext as TextLayoutContext:
      guard
        let lineFrame = textContext.neighbourLineFrame(
          from: layoutOffset, affinity: affinity, direction: direction)
      else { return result }

      let frame = lineFrame.frame
      let y = result.position.y.clamped(frame.minY, frame.maxY)
      let point = result.position.with(y: y)
      return RayshootResult(point, true)

    default:
      return result
    }
  }
}
