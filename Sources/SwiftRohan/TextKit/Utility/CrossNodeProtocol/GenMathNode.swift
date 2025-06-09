// Copyright 2024-2025 Lie Yan

import CoreGraphics

protocol GenMathNode: Node {
  var layoutFragment: (any MathLayoutFragment)? { get }
}

extension MathNode: GenMathNode {}

extension ArrayNode: GenMathNode {}

extension GenMathNode {
  func getSegmentFrame(
    _ context: LayoutContext, _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {

    switch context {
    case let context as TextLayoutContext:
      guard let layoutFragment = layoutFragment else { return nil }

      let nextOffset = layoutOffset + layoutLength()
      guard var segmentFrame = context.getSegmentFrame(nextOffset, affinity)
      else { return nil }
      segmentFrame.frame.origin.x -= layoutFragment.width
      return segmentFrame

    default:
      return context.getSegmentFrame(layoutOffset, affinity)
    }
  }
}
