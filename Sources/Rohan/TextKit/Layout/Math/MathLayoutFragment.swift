// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment, MathFragment {
  // MARK: - Frame

  /**
   Set the origin of the layout fragment frame with respect to the enclosing frame.
   - Note: The origin of bounds is at the reference point of the fragment box.
   */
  func setGlyphOrigin(_ origin: CGPoint)

  // MARK: - Debug Facilities

  /** Debug description of the layout fragment */
  func debugPrint(_ name: String?) -> Array<String>
}

extension MathLayoutFragment {
  /** Baseline position is always equal to ascent */
  var baselinePosition: CGFloat { ascent }

  /** bounds with origin at the baseline */
  var bounds: CGRect { CGRect(x: 0, y: -descent, width: width, height: height) }

  var boxDescription: String {
    let origin = self.glyphFrame.origin.formatted(2)
    let width = String(format: "%.2f", self.width)
    let ascent = String(format: "%.2f", self.ascent)
    let descent = String(format: "%.2f", self.descent)
    return "\(origin) \(width)×(\(ascent)+\(descent))"
  }

  func debugPrint() -> Array<String> {
    return debugPrint(nil)
  }
}
