import CoreGraphics
import TTFParser
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment, MathFragment {
  /// Set the origin of the fragment with respect to the enclosing frame.
  func setGlyphOrigin(_ origin: CGPoint)

  /// Re-establish the layout from the constituent fragments.
  func fixLayout(_ mathContext: MathContext)

  func debugPrint(_ name: String) -> Array<String>

  /// Get the kern value at a specific height. (Optional)
  func kernAtHeight(_ context: MathContext, _ corner: Corner, _ height: Double) -> Double
}

extension MathLayoutFragment {
  @inlinable @inline(__always) var minX: CGFloat { glyphOrigin.x }
  @inlinable @inline(__always) var midX: CGFloat { glyphOrigin.x + width / 2 }
  @inlinable @inline(__always) var maxX: CGFloat { glyphOrigin.x + width }
  @inlinable @inline(__always) var minY: CGFloat { glyphOrigin.y - ascent }

  @inlinable @inline(__always)
  var midY: CGFloat { glyphOrigin.y + (-ascent + descent) / 2 }

  @inlinable @inline(__always) var maxY: CGFloat { glyphOrigin.y + descent }

  var boxDescription: String {
    let origin = self.glyphOrigin.formatted(2)
    return "\(origin) \(boxMetrics)"
  }
}
