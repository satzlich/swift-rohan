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

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, layoutOffset: Int)? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  /**
   Resolve the math index for the given point.
   - Note: point is relative to the top-left corner of the fragment of this node.
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
      let fragment = getFragment(index),
      let containerFragment = self.layoutFragment
    else { return }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset) else { return }
    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint = {
      // top-left corner of component fragment relative to container fragment
      let frameOrigin = fragment.glyphFrame.origin
        .with(yDelta: -fragment.ascent + containerFragment.ascent)
      // add to origin correction
      return
        originCorrection
        // add the super frame origin
        .translated(by: superFrame.frame.origin)
        // the baseline possition must be exact, but the super frame origin may not
        // be due to the discrepancy between TextLayoutContext and MathLayoutContext.
        // Therefore, adjust it.
        .with(yDelta: superFrame.baselinePosition - containerFragment.ascent)
        // add the frame origin
        .translated(by: frameOrigin)
    }()

    let subContext: MathListLayoutContext
    switch context {
    case let context as TextLayoutContext:
      subContext = Self.createLayoutContext(for: component, fragment, parent: context)
    case let context as MathListLayoutContext:
      subContext = Self.createLayoutContextEcon(for: component, fragment, parent: context)
    default:
      Rohan.logger.error("unsuporrted layout context \(Swift.type(of: context), privacy: .public)")
      return
    }
    component.enumerateTextSegments(
      subContext, trace.dropFirst(), endTrace.dropFirst(),
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  /**

   - Note: point is relative to the __glyph origin__ of the fragment of this node.
   */
  override final func getTextLocation(
    interactingAt point: CGPoint, _ context: LayoutContext, _ path: inout [RohanIndex]
  ) -> Bool {
    guard let containerFragment = self.layoutFragment else { return false }
    // adjust point to top-left corner of container fragment
    let point = point.with(yDelta: containerFragment.ascent)

    // resolve math index for point
    guard
      let index: MathIndex = self.getMathIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let subContext: MathListLayoutContext
    switch context {
    case let context as TextLayoutContext:
      subContext = Self.createLayoutContext(for: component, fragment, parent: context)
    case let context as MathListLayoutContext:
      subContext = Self.createLayoutContextEcon(for: component, fragment, parent: context)
    default:
      Rohan.logger.error("unsuporrted layout context \(Swift.type(of: context), privacy: .public)")
      return false
    }
    // convert to relative position to top-left corner of component fragment
    let point1 = {
      // top-left corner of component fragment relative to container fragment
      let frameOrigin = fragment.glyphFrame.origin
        .with(yDelta: -fragment.ascent + containerFragment.ascent)
      return point.relative(to: frameOrigin)
    }()
    // append to path
    path.append(.mathIndex(index))
    // recurse
    let pathModified = component.getTextLocation(interactingAt: point1, subContext, &path)
    // fix accordingly
    if !pathModified {
      path.append(.index(0))
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
