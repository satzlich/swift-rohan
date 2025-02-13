// Copyright 2024-2025 Lie Yan

import Foundation

/** protocol for enumerating segment frames */
protocol SegmentContext {
  /**
   Get the frame of the layout fragment at the given layout offset
   - Note: If the frame origin is not at the top-left corner, it is transformed
     to the top-left corner.
   */
  func getSegmentFrame(_ layoutOffset: Int) -> SegmentFrame?
}
