// Copyright 2024-2025 Lie Yan
import CoreGraphics

final class MathListSegmentContext: SegmentContext {
  let layoutFragment: MathListLayoutFragment

  init(_ layoutFragment: MathListLayoutFragment) {
    self.layoutFragment = layoutFragment
  }

  // MARK: - Frame

  func getSegmentFrame(_ layoutOffset: Int) -> SegmentFrame? {
    guard let i = layoutFragment.index(0, llOffsetBy: layoutOffset) else { return nil }
    if layoutFragment.isEmpty {
      let frame = layoutFragment.glyphFrame.offsetBy(dx: 0, dy: -layoutFragment.ascent)
      return SegmentFrame(frame, layoutFragment.baselinePosition)
    }
    else if i < layoutFragment.count {
      let fragment = layoutFragment.getFragment(at: i)
      // origin moved to top-left corner
      let frame = fragment.glyphFrame.offsetBy(dx: 0, dy: -fragment.ascent)
      return SegmentFrame(frame, fragment.baselinePosition)
    }
    else if i == layoutFragment.count {
      let fragment = layoutFragment.getFragment(at: i - 1)
      // origin moved to top-left corner
      let frame = fragment.glyphFrame.offsetBy(dx: fragment.width, dy: -fragment.ascent)
      return SegmentFrame(frame, fragment.baselinePosition)
    }
    else {
      return nil
    }
  }
}
