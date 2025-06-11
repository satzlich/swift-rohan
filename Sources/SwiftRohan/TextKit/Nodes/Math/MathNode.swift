// Copyright 2024-2025 Lie Yan

import CoreGraphics

class MathNode: Node {
  // MARK: - Node

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    for (_, content) in enumerateComponents() {
      content.resetCachedProperties()
    }
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> ContentNode? {
    guard let index = index.mathIndex() else { return nil }
    return getComponent(index)
  }

  final override func firstIndex() -> RohanIndex? {
    (enumerateComponents().first?.index).map { .mathIndex($0) }
  }

  final override func lastIndex() -> RohanIndex? {
    (enumerateComponents().last?.index).map { .mathIndex($0) }
  }

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    // layout offset for math component is not well-defined and is unused
    return .null
  }

  // MARK: - Node(Layout)

  internal override func contentDidChange() { parent?.contentDidChange() }

  internal override func layoutLength() -> Int { 1 }  // "1" except for reflowed math.

  // MARK: - MathNode(Component)

  @usableFromInline
  typealias Component = (index: MathIndex, content: ContentNode)

  /// Returns an __ordered list__ of the node's components.
  internal func enumerateComponents() -> Array<Component> {
    preconditionFailure("overriding required")
  }

  /// Returns true if the node allows the component specified by the given index.
  internal func isComponentAllowed(_ index: MathIndex) -> Bool { false }

  /// Add the component specified by the given index and content to the node.
  internal func addComponent(_ index: MathIndex, _ content: ElementStore, inStorage: Bool)
  {
    assertionFailure("inapplicable unless overridden")
  }

  /// Remove the component specified by the given index.
  internal func removeComponent(_ index: MathIndex, inStorage: Bool) {
    assertionFailure("inapplicable unless overridden")
  }

  // MARK: - MathNode(Layout)

  /// Layout fragment associated with this node
  internal var layoutFragment: MathLayoutFragment? {
    preconditionFailure("overriding required")
  }

  /// Returns the component associated with the given index.
  internal func getFragment(_ index: MathIndex) -> LayoutFragment? {
    preconditionFailure("overriding required")
  }

  /// Initialize a layout context for the component with the given fragment.
  internal func initLayoutContext(
    for component: ContentNode, _ fragment: LayoutFragment, parent context: LayoutContext
  ) -> LayoutContext {
    precondition(fragment is MathListLayoutFragment)
    let fragment = fragment as! MathListLayoutFragment
    return
      LayoutUtils.safeInitMathListLayoutContext(for: component, fragment, parent: context)
  }

  /// Returns the math index for the given point.
  /// - Parameter point: The point relative to the __glyph origin__ of the
  ///     fragment of this node.
  internal func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure("overriding required")
  }

  /// Process rayshooting with regard to the structure of the node.
  /// - Parameters:
  ///   - point: The point relative to the __glyph origin__ of the fragment of this node.
  internal func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure("overriding required")
  }

  // MARK: - Implementation

  /// Returns the component for the index. If not found, return nil.
  final func getComponent(_ index: MathIndex) -> ContentNode? {
    enumerateComponents().first { $0.index == index }?.content
  }

  final func destinationIndex(
    for index: MathIndex, _ direction: TextSelectionNavigation.Direction
  ) -> MathIndex? {
    precondition(direction == .forward || direction == .backward)

    let components = enumerateComponents()
    guard let componentIndex = components.firstIndex(where: { $0.index == index })
    else { return nil }
    let target = direction == .forward ? componentIndex + 1 : componentIndex - 1
    guard 0..<components.count ~= target else { return nil }
    return components[target].index
  }

  /// Default implementation of `initLayoutContext(for:fragment:parent:)`.
  static func defaultInitLayoutContext(
    for component: ContentNode, _ fragment: LayoutFragment, parent context: LayoutContext
  ) -> LayoutContext {
    precondition(fragment is MathListLayoutFragment)
    let fragment = fragment as! MathListLayoutFragment
    return
      LayoutUtils.safeInitMathListLayoutContext(for: component, fragment, parent: context)
  }

  internal override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
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

    // query with affinity=downstream.
    guard let superFrame = self.getSegmentFrame(context, layoutOffset, .downstream)
    else { return false }
    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .translated(by: fragment.glyphOrigin)
      .with(yDelta: -fragment.ascent)  // relative to top-left corner of fragment

    let newContext = self.initLayoutContext(for: component, fragment, parent: context)
    // reset layout offset to "0" in the new context
    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), context: newContext,
      layoutOffset: 0, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  internal override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    // resolve math index for point
    guard let point = convertToLocal(point, context, layoutOffset),
      let index: MathIndex = self.getMathIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // append to trace
    trace.emplaceBack(self, .mathIndex(index))

    let newPoint: CGPoint
    do {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphOrigin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      newPoint = point.relative(to: frameOrigin)
    }
    let newContext = self.initLayoutContext(for: component, fragment, parent: context)
    // recurse
    let modified =
      component.resolveTextLocation(
        with: newPoint, context: newContext, layoutOffset: 0,
        trace: &trace, affinity: &affinity)
    // fix accordingly
    if !modified { trace.emplaceBack(component, .index(0)) }
    return true
  }

  internal override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }

    // create sub-context
    let newContext = self.initLayoutContext(for: component, fragment, parent: context)
    // rayshoot in the component with layout offset reset to "0"
    guard
      let componentResult = component.rayshoot(
        from: path.dropFirst(), affinity: affinity, direction: direction,
        context: newContext, layoutOffset: 0)
    else { return nil }

    // query with affinity=downstream.
    guard let superFrame = self.getSegmentFrame(context, layoutOffset, .downstream)
    else { return nil }

    // if resolved, return origin-corrected result
    if componentResult.isResolved {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)
        // relative to top-left corner of fragment (translate + yDelta)
        .translated(by: fragment.glyphOrigin)
        .with(yDelta: -fragment.ascent)

      let corrected = componentResult.position.translated(by: originCorrection)
      return componentResult.with(position: corrected)
    }
    // otherwise, rayshoot in the node
    assert(componentResult.isResolved == false)

    // convert to position relative to glyph origin of the fragment of the node
    let relPosition =
      componentResult.position
      // relative to glyph origin of the fragment of the component
      .with(yDelta: -fragment.ascent)
      // relative to glyph origin of the fragment of the node
      .translated(by: fragment.glyphOrigin)

    guard let nodeResult = self.rayshoot(from: relPosition, index, in: direction)
    else { return nil }

    // if resolved or not equation node, return corrected result.
    if nodeResult.isResolved || !shouldRelayRayshoot(context) {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)

      let corrected = nodeResult.position.translated(by: originCorrection)
      return nodeResult.with(position: corrected)
    }
    // otherwise, return top/bottom position of the super frame.
    else {
      let x = nodeResult.position.x + superFrame.frame.origin.x
      let y = direction == .up ? superFrame.frame.minY : superFrame.frame.maxY
      // The resolved flag is set to false to ensure that rayshot relay
      // is performed below.
      let result = RayshootResult(CGPoint(x: x, y: y), false)
      return LayoutUtils.relayRayshoot(
        layoutOffset, affinity, direction, result, context)
    }
  }
}

// True if the rayshoot result should be relayed to the parent context.
func shouldRelayRayshoot(_ context: LayoutContext) -> Bool {
  context is MathReflowLayoutContext || context is TextLayoutContext
}
