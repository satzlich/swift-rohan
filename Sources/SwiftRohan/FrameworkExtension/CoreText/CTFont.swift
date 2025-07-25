import CoreText
import Foundation

extension CTFont {
  static func createWithName(
    _ name: String, _ size: CGFloat, isFlipped: Bool = false
  ) -> CTFont {
    if !isFlipped {
      return CTFontCreateWithName(name as CFString, size, nil)
    }
    else {
      var invY = CGAffineTransform(scaleX: 1, y: -1)
      return CTFontCreateWithName(name as CFString, size, &invY)
    }
  }
}
