// Copyright 2024-2025 Lie Yan

import CoreGraphics
import TTFParser
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment, MathFragment {
  /// Set the origin of the fragment with respect to the enclosing frame.
  func setGlyphOrigin(_ origin: CGPoint)

  /// Re-establish the layout from the constituent fragments.
  func fixLayout(_ mathContext: MathContext)

  // MARK: - Debug

  func debugPrint(_ name: String?) -> Array<String>
}

extension MathLayoutFragment {
  var minX: CGFloat { glyphOrigin.x }
  var midX: CGFloat { glyphOrigin.x + width / 2 }
  var maxX: CGFloat { glyphOrigin.x + width }
  var minY: CGFloat { glyphOrigin.y - ascent }
  var midY: CGFloat { glyphOrigin.y + (-ascent + descent) / 2 }
  var maxY: CGFloat { glyphOrigin.y + descent }

  var boxDescription: String {
    let origin = self.glyphOrigin.formatted(2)
    return "\(origin) \(boxMetrics)"
  }

  func debugPrint() -> Array<String> {
    return debugPrint(nil)
  }
}
