// Copyright 2024-2025 Lie Yan

import CoreGraphics

protocol GenMathNode: Node {
  var layoutFragment: (any MathLayoutFragment)? { get }
}

extension MathNode: GenMathNode {}

extension ArrayNode: GenMathNode {}

extension GenMathNode {
  /// Returns the segment frame for the layout offset with given affinity in
  /// the given context.
  /// - Parameters:
  ///   - context: The layout context to query.
  ///   - layoutOffset: The layout offset in the given context.
  ///   - affinity: The selection affinity to use when querying the segment frame.
  /// - Note: The raison d'être of this method is that TextLayoutContext demands
  ///     special handling for the segment frame of GenMathNode.
  func getSegmentFrame(
    _ context: LayoutContext, _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame? {

    switch context {
    case let context as TextLayoutContext:
      guard let layoutFragment = layoutFragment else { return nil }

      let nextOffset = layoutOffset + layoutLength()
      // query with affinity=upstream.
      guard var segmentFrame = context.getSegmentFrame(nextOffset, .upstream)
      else { return nil }
      segmentFrame.frame.origin.x -= layoutFragment.width
      return segmentFrame

    default:
      return context.getSegmentFrame(layoutOffset, affinity)
    }
  }

  /// Convert the point which is relative to the **top-left corner** of given context
  /// to the coordinate system of the fragment of this node.
  /// - Parameters:
  ///     - point: The point relative to the **top-left corner** of the context.
  ///     - context: The layout context that the point is in.
  ///     - layoutOffset: The layout offset of the node in the given context.
  /// - Returns: The point in the coordinate system of the fragment of this node,
  ///     or nil if the conversion fails.
  func convertToLocal(
    _ point: CGPoint, _ context: LayoutContext, _ layoutOffset: Int
  ) -> CGPoint? {
    guard let segmentFrame = getSegmentFrame(context, layoutOffset, .downstream)
    else { return nil }
    let newPoint = point.relative(to: segmentFrame.frame.origin)
      .with(yDelta: -segmentFrame.baselinePosition)

    // We compute the coordinate relative to **glyph origin** by subtracting
    // the baseline position from the frame origin, which works for TextKit,
    // MathListLayoutContext and MathReflowLayoutContext.

    return newPoint
  }

  // True if the rayshoot result should be relayed to the parent context.
  func shouldRelayRayshoot(_ context: LayoutContext) -> Bool {
    context is MathReflowLayoutContext || context is TextLayoutContext
  }
}
