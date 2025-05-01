// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class MathNode: Node {
  // MARK: - Content

  override func contentDidChange(delta: LengthSummary, inStorage: Bool) {
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

  /// Returns the component for the index. If not found, return nil.
  final func getComponent(_ index: MathIndex) -> ContentNode? {
    enumerateComponents().first { $0.index == index }?.content
  }

  /// Returns an __ordered list__ of the node's components.
  @inline(__always)
  internal func enumerateComponents() -> [Component] {
    preconditionFailure("overriding required")
  }

  // MARK: - Location

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

  override final func layoutLength() -> Int { 1 }  // always "1" for math nodes

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    // layout offset for math component is not well-defined and is unused
    return nil
  }

  /// Returns the math index for the given point.
  /// - Parameter point: The point relative to the __glyph origin__ of the
  ///     fragment of this node.
  internal func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure("overriding required")
  }

  /// Returns the component associated with the given index.
  func getFragment(_ index: MathIndex) -> MathLayoutFragment? {
    preconditionFailure("overriding required")
  }

  /// Layout fragment associated with this node
  var layoutFragment: MathLayoutFragment? { preconditionFailure("overriding required") }

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    let affinity: RhTextSelection.Affinity =
      options.contains(.upstreamAffinity) ? .upstream : .downstream

    guard path.count >= 2,
      endPath.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let endIndex: MathIndex = endPath.first?.mathIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index),
      let wholeFragment = self.layoutFragment
    else { return false }

    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset, affinity)
    else { return false }

    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .translated(by: fragment.glyphOrigin)
      .with(yDelta: -fragment.ascent)  // relative to top-left corner of fragment

    let newContext = LayoutUtils.createContext(for: component, fragment, parent: context)
    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), newContext,
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  /// - Parameters:
  ///   - point: The point relative to the __glyph origin__ of the fragment of this node.
  override final func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext,
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    // resolve math index for point
    guard let index: MathIndex = self.getMathIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let newContext = LayoutUtils.createContext(for: component, fragment, parent: context)
    let relPoint = {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphOrigin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      return point.relative(to: frameOrigin)
    }()
    // append to trace
    trace.emplaceBack(self, .mathIndex(index))
    // recurse
    let modified =
      component.resolveTextLocation(with: relPoint, newContext, &trace, &affinity)
    // fix accordingly
    if !modified {
      trace.emplaceBack(component, .index(0))
    }
    return true
  }

  override final func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset, affinity)
    else { return nil }

    // create sub-context
    let newContext = LayoutUtils.createContext(for: component, fragment, parent: context)
    // rayshoot in the component with layout offset reset to "0"
    guard
      let componentResult = component.rayshoot(
        from: path.dropFirst(), affinity: affinity, direction: direction,
        context: newContext, layoutOffset: 0)
    else { return nil }

    // if resolved, return origin-corrected result
    guard componentResult.isResolved == false
    else {
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

    // convert to position relative to glyph origin of the fragment of the node
    let relPosition =
      componentResult.position
      // relative to glyph origin of the fragment of the component
      .with(yDelta: -fragment.ascent)
      // relative to glyph origin of the fragment of the node
      .translated(by: fragment.glyphOrigin)

    guard let nodeResult = self.rayshoot(from: relPosition, index, in: direction)
    else { return nil }

    // if resolved or not TextLayoutContext, return origin-corrected result
    if nodeResult.isResolved || !(context is TextLayoutContext) {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)

      let corrected = nodeResult.position.translated(by: originCorrection)
      return nodeResult.with(position: corrected)
    }
    // otherwise (not resolved and is TextLayoutContext), return up/bottom end
    // of segment frame
    else {
      let x = nodeResult.position.x + superFrame.frame.origin.x
      let y = direction == .up ? superFrame.frame.minY : superFrame.frame.maxY
      return RayshootResult(CGPoint(x: x, y: y), true)
    }
  }

  /// Process rayshooting with regard to the structure of the node.
  /// - Parameters:
  ///   - point: The point relative to the __glyph origin__ of the fragment of this node.
  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure("overriding required")
  }
}
