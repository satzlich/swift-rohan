// Copyright 2024-2025 Lie Yan

import CoreGraphics

class SimpleNode: Node {  // default implementation for simple nodes
  // MARK: - Node

  override init() { super.init() }

  override func resetCachedProperties() {
    super.resetCachedProperties()
  }

  // mark as `final` to prevent overriding
  final override func selector() -> TargetSelector { super.selector() }

  internal override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    // by default, return parent's properties
    parent?.getProperties(styleSheet) ?? [:]
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> Node? { nil }

  final override func firstIndex() -> RohanIndex? { nil }
  final override func lastIndex() -> RohanIndex? { nil }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? { nil }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    nil
  }

  override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    // always return nil
    .null
  }

  // MARK: - Node(Layout)

  final override func contentDidChange(delta: Int, inStorage: Bool) { /* no-op */  }

  final override func contentDidChange() { /* no-op */  }

  final override var isDirty: Bool { false }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  internal override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
  }

  // MARK: - Implementation

  override final func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    assertionFailure("Unreachable")
    return false
  }

  override final func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext,
    trace: inout Trace, affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    // do nothing
    return false
  }

  override final func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: any LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    assertionFailure("Unreachable")
    return nil
  }
}
