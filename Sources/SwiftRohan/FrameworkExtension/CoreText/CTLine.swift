// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

extension CTLine {
  func getTypographicBounds(
    _ ascent: UnsafeMutablePointer<CGFloat>?,
    _ descent: UnsafeMutablePointer<CGFloat>?,
    _ leading: UnsafeMutablePointer<CGFloat>?
  ) -> Double {
    CTLineGetTypographicBounds(self, ascent, descent, leading)
  }

  func getStringIndex(for position: CGPoint) -> CFIndex {
    CTLineGetStringIndexForPosition(self, position)
  }

  func getOffset(
    for charIndex: CFIndex, _ secondaryOffset: UnsafeMutablePointer<CGFloat>?
  ) -> Double {
    CTLineGetOffsetForStringIndex(self, charIndex, secondaryOffset)
  }
}
