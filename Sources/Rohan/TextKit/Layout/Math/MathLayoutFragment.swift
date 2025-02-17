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

  // MARK: Length

  /**
   Length perceived by the layout context.
   - Note: `layoutLength` may differ from the sum over its children.
   */
  var layoutLength: Int { get }

  // MARK: - Debug Facilities

  /** Debug description of the layout fragment */
  func debugPrint() -> Array<String>
  func debugPrint(_ customName: String) -> Array<String>
}

extension MathLayoutFragment {
  /** Baseline position is always equal to ascent */
  var baselinePosition: CGFloat { ascent }

  var bounds: CGRect { CGRect(x: 0, y: -descent, width: width, height: height) }

  /** bounds with origin moved to zero */
  var naiveBounds: CGRect { CGRect(x: 0, y: 0, width: width, height: height) }

  var boxDescription: String {
    let origin = self.glyphFrame.origin.formatted(2)
    let width = self.width.formatted(2)
    let ascent = self.ascent.formatted(2)
    let descent = self.descent.formatted(2)
    return "\(origin) \(width)×(\(ascent)+\(descent))"
  }
}
