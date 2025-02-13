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

  override final func getSegmentFrame(
    _ context: SegmentContext, _ path: ArraySlice<RohanIndex>, _ layoutOffset: Int
  ) -> SegmentFrame? {
    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }

    // create sub-context
    let subContext: MathListSegmentContext
    switch context {
    case _ as TextSegmentContext:
      // get sub-context
      subContext = MathListSegmentContext(fragment)
    case _ as MathListSegmentContext:
      // get sub-context
      subContext = MathListSegmentContext(fragment)
    default:
      Rohan.logger.error("unsupported layout context: \(type(of: context), privacy: .public)")
      return nil
    }
    // get sub-frame in the component, and also super-frame
    guard let subFrame = component.getSegmentFrame(subContext, path.dropFirst(), 0),
      let superFrame = context.getSegmentFrame(layoutOffset)
    else { return nil }
    // compute frame
    let frame = fragment.glyphFrame
    let subFrame_ = subFrame.frame
    let superFrame_ = superFrame.frame
    let resultFrame =
      // component fragment and subframe share the same baseline position
      subFrame_.offsetBy(dx: frame.origin.x, dy: frame.origin.y)
      // combine with super frame
      .offsetBy(dx: superFrame_.origin.x, dy: superFrame_.origin.y + superFrame.baselinePosition)
    return SegmentFrame(resultFrame, subFrame.baselinePosition)
  }

  /**
   Perform layout
   */
  static func layoutComponent(
    parent context: MathListLayoutContext, _ component: ContentNode,
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
