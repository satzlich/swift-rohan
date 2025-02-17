// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class MathNode: Node {
  // MARK: - Content

  override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    // change of layout length is not propagated
    parent?.contentDidChange(delta: delta.with(layoutLength: 0), inContentStorage: inContentStorage)
  }

  // MARK: - Content
  @usableFromInline
  typealias Component = (index: MathIndex, content: ContentNode)

  override final func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.mathIndex() else { return nil }
    return getComponent(index)
  }

  /** Returns the component for the index. If not found, return nil. */
  final func getComponent(_ index: MathIndex) -> ContentNode? {
    enumerateComponents().first { $0.index == index }?.content
  }

  /** Returns an __ordered list__ of the node's components. */
  @inlinable @inline(__always)
  internal func enumerateComponents() -> [Component] {
    preconditionFailure("overriding required")
  }

  // MARK: - Layout

  override final var layoutLength: Int { 1 }  // always "1" for math nodes

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, layoutOffset: Int)? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  /**
   Resolve the math index for the given point.
   - Note: point is relative to the __glyph origin__ of the fragment of this node.
   */
  internal func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure("overriding required")
  }

  /** Returns the component associated with the given index. */
  func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    preconditionFailure("overriding required")
  }

  /** Layout fragment associated with this node */
  var layoutFragment: MathLayoutFragment? { preconditionFailure("overriding required") }

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
      let element = trace.first,
      let endElement = endTrace.first,
      // must be identical
      element.node === endElement.node,
      let index: MathIndex = element.index.mathIndex(),
      let endIndex: MathIndex = endElement.index.mathIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset) else { return }
    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .translated(by: fragment.glyphFrame.origin)
      .with(yDelta: -fragment.ascent)  // relative to top-left corner of fragment

    let newContext: MathListLayoutContext
    switch context {
    case let context as TextLayoutContext:
      newContext = Self.createLayoutContext(for: component, fragment, parent: context)
    case let context as MathListLayoutContext:
      newContext = Self.createLayoutContextEcon(for: component, fragment, parent: context)
    default:
      Rohan.logger.error("unsuporrted layout context \(Swift.type(of: context))")
      return
    }
    component.enumerateTextSegments(
      newContext, trace.dropFirst(), endTrace.dropFirst(),
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  /**
   - Note: point is relative to the __glyph origin__ of the fragment of this node.
   */
  override final func getTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    // resolve math index for point
    guard let index: MathIndex = self.getMathIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let newContext: MathListLayoutContext
    switch context {
    case let context as TextLayoutContext:
      newContext = Self.createLayoutContext(for: component, fragment, parent: context)
    case let context as MathListLayoutContext:
      newContext = Self.createLayoutContextEcon(for: component, fragment, parent: context)
    default:
      Rohan.logger.error("unsuporrted layout context \(Swift.type(of: context))")
      return false
    }
    let point_ = {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphFrame.origin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      return point.relative(to: frameOrigin)
    }()
    // append to trace
    trace.append(TraceElement(self, .mathIndex(index)))
    // recurse
    let modified = component.getTextLocation(interactingAt: point_, newContext, &trace)
    // fix accordingly
    if !modified {
      trace.append(TraceElement(component, .index(0)))
    }
    return true
  }

  // MARK: - Helper

  /**
   Create layout context for component and fragment. If fragment doesn't exist, create it.
   - Note: It has a more __cost-effective__ specialization for `MathListLayoutContext`.
   */
  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: inout MathListLayoutFragment?,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    if fragment == nil {
      fragment = MathListLayoutFragment(mathContext.textColor)
    }
    return MathListLayoutContext(context.styleSheet, mathContext, fragment!)
  }

  /**
   Create layout context for component and fragment.
   - Note: It has a more __cost-effective__ specialization for `MathListLayoutContext`.
   */
  static func createLayoutContext(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: LayoutContext
  ) -> MathListLayoutContext {
    let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }

  /** Create layout context for component and fragment. If fragment doesn't exist,
   create it.
   - Note: It is more __econimcal__ than its generic counterpart. */
  static func createLayoutContextEcon(
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

  /**
   Create layout context for component and fragment.
   - Note: It is more __econimcal__ than its generic counterpart.
   */
  static func createLayoutContextEcon(
    for component: ContentNode,
    _ fragment: MathListLayoutFragment,
    parent context: MathListLayoutContext
  ) -> MathListLayoutContext {
    let style = component.resolveProperty(MathProperty.style, context.styleSheet).mathStyle()!
    let mathContext = context.mathContext.with(mathStyle: style)
    return MathListLayoutContext(context.styleSheet, mathContext, fragment)
  }
}
