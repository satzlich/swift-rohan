// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class MathNode: Node {
  // MARK: - Content

  override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    // change of extrinsic and layout lengths is not propagated
    parent?.contentDidChange(delta: delta.with(layoutLength: 0), inContentStorage: inContentStorage)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.mathIndex() else { return nil }
    return enumerateComponents().first { $0.index == index }?.content
  }

  final func getComponent(_ index: MathIndex) -> ContentNode? {
    enumerateComponents().first { $0.index == index }?.content
  }

  @usableFromInline
  typealias Component = (index: MathIndex, content: ContentNode)

  /** Returns an __ordered list__ of the node's components. */
  @inlinable
  internal func enumerateComponents() -> [Component] {
    preconditionFailure("overriding required")
  }

  // MARK: - Layout

  override final var layoutLength: Int { 1 }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    preconditionFailure("overriding required")
  }

  override final func getLayoutFrame(
    _ context: LayoutContext, _ path: ArraySlice<RohanIndex>, _ layoutOffset: Int
  ) -> CGRect? {
    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }

    // get sub-context
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    let subContext = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    // get sub-frame in the component
    guard
      let superFrame = context.getLayoutFrame(layoutOffset),
      let subFrame = component.getLayoutFrame(subContext, path.dropFirst(), 0)
    else { return nil }

    // compose
    let frame = fragment.layoutFragmentFrame
    return subFrame.offsetBy(dx: frame.origin.x, dy: frame.origin.y)
      .offsetBy(dx: superFrame.origin.x, dy: superFrame.origin.y)
  }

  static func layoutComponent(
    _ context: MathListLayoutContext, _ component: ContentNode,
    _ fragment: MathListLayoutFragment, fromScratch: Bool
  ) {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    let subcontext = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    subcontext.beginEditing()
    component.performLayout(subcontext, fromScratch: fromScratch)
    subcontext.endEditing()
  }
}
