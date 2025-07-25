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

  func getImageBounds(
    _ ascent: UnsafeMutablePointer<CGFloat>?, _ descent: UnsafeMutablePointer<CGFloat>?
  ) -> Double {
    let width = CTLineGetTypographicBounds(self, nil, nil, nil)
    let rect = CTLineGetImageBounds(self, nil)
    if let ascent = ascent {
      ascent.pointee = -rect.origin.y
    }
    if let descent = descent {
      descent.pointee = rect.height + rect.origin.y
    }
    return width
  }
}
