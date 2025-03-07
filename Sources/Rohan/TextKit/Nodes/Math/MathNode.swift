// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class MathNode: Node {
  // MARK: - Content

  override final func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    // change of layout length is not propagated
    parent?.contentDidChange(delta: delta.with(layoutLength: 0), inStorage: inStorage)
  }

  // MARK: - Content

  @usableFromInline
  typealias Component = (index: MathIndex, content: ContentNode)

  override final func getChild(_ index: RohanIndex) -> ContentNode? {
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

  // MARK: - Location

  final func destinationIndex(
    for index: MathIndex, _ direction: TextSelectionNavigation.Direction
  ) -> MathIndex? {
    let components = enumerateComponents()
    guard let componentIndex = components.firstIndex(where: { $0.index == index })
    else { return nil }
    let target = direction == .forward ? componentIndex + 1 : componentIndex - 1
    guard 0..<components.count ~= target else { return nil }
    return components[target].index
  }

  override final func firstIndex() -> RohanIndex? {
    (enumerateComponents().first?.index).map({ .mathIndex($0) })
  }

  override final func lastIndex() -> RohanIndex? {
    (enumerateComponents().last?.index).map({ .mathIndex($0) })
  }

  // MARK: - Styles

  override final func resetCachedProperties(recursive: Bool) {
    super.resetCachedProperties(recursive: recursive)
    if recursive {
      enumerateComponents().forEach { $0.content.resetCachedProperties(recursive: true) }
    }
  }

  // MARK: - Layout

  override final var layoutLength: Int { 1 }  // always "1" for math nodes

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
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

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard path.count >= 2,
      endPath.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let endIndex: MathIndex = endPath.first?.mathIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset)
    else { return false }
    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .translated(by: fragment.glyphFrame.origin)
      .with(yDelta: -fragment.ascent)  // relative to top-left corner of fragment

    let newContext = Self.createLayoutContext(for: component, fragment, parent: context)
    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), newContext,
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  /**
   - Note: point is relative to the __glyph origin__ of the fragment of this node.
   */
  override final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    // resolve math index for point
    guard let index: MathIndex = self.getMathIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let newContext = Self.createLayoutContext(for: component, fragment, parent: context)
    let relPoint = {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphFrame.origin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      return point.relative(to: frameOrigin)
    }()
    // append to trace
    trace.append(TraceElement(self, .mathIndex(index)))
    // recurse
    let modified = component.resolveTextLocation(interactingAt: relPoint, newContext, &trace)
    // fix accordingly
    if !modified {
      trace.append(TraceElement(component, .index(0)))
    }
    return true
  }

  override final func rayshoot(
    from path: ArraySlice<RohanIndex>,
    _ direction: TextSelectionNavigation.Direction,
    _ context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset) else { return nil }
    // create sub-context
    let newContext = Self.createLayoutContext(for: component, fragment, parent: context)
    // rayshoot in the component with layout offset reset to "0"
    let componentResult = component.rayshoot(
      from: path.dropFirst(), direction, newContext, layoutOffset: 0)
    guard let componentResult else { return nil }

    // if hit, return origin-corrected result
    guard componentResult.isResolved == false else {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)
        // relative to top-left corner of fragment (translate + yDelta)
        .translated(by: fragment.glyphFrame.origin)
        .with(yDelta: -fragment.ascent)

      let corrected = componentResult.position.translated(by: originCorrection)
      return componentResult.with(position: corrected)
    }
    // otherwise, rayshoot in the node

    // convert to position relative to glyph origin of the fragment of the node
    let relPosition =
      componentResult.position
      // relative to glyph origin of the fragment of the component
      .with(yDelta: -fragment.ascent)
      // relative to glyph origin of the fragment of the node
      .translated(by: fragment.glyphFrame.origin)

    guard let nodeResult = self.rayshoot(from: relPosition, direction) else { return nil }

    // if hit or not TextLayoutContext, return origin-corrected result
    if nodeResult.isResolved || !(context is TextLayoutContext) {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)

      let corrected = nodeResult.position.translated(by: originCorrection)
      return nodeResult.with(position: corrected)
    }
    // otherwise (not hit and is TextLayoutContext), return up/bottom end of segment frame
    else {
      let x = nodeResult.position.x + superFrame.frame.origin.x
      let y = direction == .up ? superFrame.frame.minY : superFrame.frame.maxY
      return RayshootResult(CGPoint(x: x, y: y), true)
    }
  }

  /**
   Process rayshooting with regard to the structure of the node.
   - Note: `point` is relative to the __glyph origin__ of the fragment of this node.
   */
  func rayshoot(
    from point: CGPoint, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure("overriding required")
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
    switch context {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
      if fragment == nil {
        fragment = MathListLayoutFragment(mathContext.textColor)
      }
      return MathListLayoutContext(context.styleSheet, mathContext, fragment!)

    case let context as MathListLayoutContext:
      return Self.createLayoutContextEcon(for: component, &fragment, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
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
    switch context {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: component, context.styleSheet)
      return MathListLayoutContext(context.styleSheet, mathContext, fragment)

    case let context as MathListLayoutContext:
      return Self.createLayoutContextEcon(for: component, fragment, parent: context)

    default:
      fatalError("unsupported layout context \(Swift.type(of: context))")
    }
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
