// Copyright 2024-2025 Lie Yan

import CoreGraphics

public class SimpleNode: Node {  // default implementation for simple nodes
  override init() { super.init() }

  override func resetCachedProperties() {
    super.resetCachedProperties()
  }

  // mark as `final` to prevent overriding
  override final func selector() -> TargetSelector { super.selector() }

  // MARK: - Styles

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    // by default, return parent's properties
    parent?.getProperties(styleSheet) ?? [:]
  }

  // MARK: - Codable

  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  public override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? { nil }

  override final func contentDidChange(delta: Node.LengthSummary, inStorage: Bool) {
    // do nothing
  }

  // MARK: - Location

  override final func firstIndex() -> RohanIndex? { nil }
  override final func lastIndex() -> RohanIndex? { nil }

  // MARK: - Layout

  override final var isBlock: Bool { false }
  override final var isDirty: Bool { false }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? { nil }
  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    nil
  }

  override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    // always return nil
    .null
  }

  override final func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    assertionFailure("Unreachable")
    return false
  }

  override final func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext,
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity
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
