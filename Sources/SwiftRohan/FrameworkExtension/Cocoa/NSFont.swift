import AppKit
import Foundation

extension NSFont {
  /// Initialize an instance with isFlipped property
  convenience init?(name: String, size: CGFloat, isFlipped: Bool) {
    guard isFlipped else { self.init(name: name, size: size); return }
    let descriptor = NSFontDescriptor(name: name, size: size)
    let textTransform = AffineTransform(scaleByX: size, byY: -size)
    self.init(descriptor: descriptor, textTransform: textTransform)
  }

  /// Initialize an instance with isFlipped property
  convenience init?(descriptor: NSFontDescriptor, size: CGFloat, isFlipped: Bool) {
    if !isFlipped {
      self.init(descriptor: descriptor, size: size)
    }
    else {
      let textTransform = AffineTransform(scaleByX: size, byY: -size)
      self.init(descriptor: descriptor, textTransform: textTransform)
    }
  }
}
