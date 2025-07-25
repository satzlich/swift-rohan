import CoreGraphics
import Foundation
import UnicodeMathClass

protocol MathFragment: GlyphProtocol {
  var italicsCorrection: Double { get }
  var accentAttachment: Double { get }
  var clazz: MathClass { get }
  var limits: Limits { get }

  /// Returns true if the fragment should be surrounded by spaces.
  var isSpaced: Bool { get }

  /// Returns true if the fragment has text-like behavior.
  var isTextLike: Bool { get }
}
