// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class MathNode: Node {
  // MARK: - Content

  override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    // change of layout length is not propagated
    parent?.contentDidChange(delta: delta.with(layoutLength: 0), inContentStorage: inContentStorage)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.mathIndex() else { return nil }
    return getComponent(index)
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

  override final func enumerateTextSegments(
    _ context: LayoutContext,
    _ trace: ArraySlice<TraceElement>,
    _ endTrace: ArraySlice<TraceElement>,
    layoutOffset: Int,
    originCorrection: CGPoint,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) {
    guard trace.count >= 2,
      endTrace.count >= 2,
      trace.first!.node === endTrace.first!.node,
      let index: MathIndex = trace.first!.index.mathIndex(),
      let endIndex: MathIndex = endTrace.first!.index.mathIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(layoutOffset) else { return }
    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint = {
      let frame = fragment.glyphFrame
      let superFrame_ = superFrame.frame
      return CGPoint(
        x: originCorrection.x + frame.origin.x + superFrame_.origin.x,
        y: originCorrection.y + frame.origin.y + superFrame_.origin.y + superFrame.baselinePosition)
    }()

    let subContext: MathListLayoutContext
    switch context {
    case let context as TextLayoutContext:
      subContext = Self.createLayoutContext(for: component, fragment, parent: context)
    case let context as MathListLayoutContext:
      subContext = Self.createLayoutContext(for: component, fragment, parent: context)
    default:
      Rohan.logger.error("unsuporrted layout context \(Swift.type(of: context), privacy: .public)")
      return
    }

    component.enumerateTextSegments(
      subContext, trace.dropFirst(), endTrace.dropFirst(),
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block
    )
  }

  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: inout MathListLayoutFragment?,
    parent context: MathListLayoutContext
  ) -> MathListLayoutContext {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    if fragment == nil {
      fragment = MathListLayoutFragment(mathContext.textColor)
    }
    return MathListLayoutContext(context.styleSheet, mathContext, fragment!)
  }

  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: MathListLayoutContext
  ) -> MathListLayoutContext {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }

  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: inout MathListLayoutFragment?,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    if fragment == nil {
      fragment = MathListLayoutFragment(mathContext.textColor)
    }
    let subContext = MathListLayoutContext(context.styleSheet, mathContext, fragment!)
    return subContext
  }

  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    let subContext = MathListLayoutContext(context.styleSheet, mathContext, fragment)
    return subContext
  }
}
