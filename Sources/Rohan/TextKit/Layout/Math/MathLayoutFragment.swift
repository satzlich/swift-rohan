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
}

extension MathLayoutFragment {
  /** Baseline position is always equal to ascent */
  var baselinePosition: CGFloat { ascent }

  var bounds: CGRect { CGRect(x: 0, y: -descent, width: width, height: height) }
  var naiveBounds: CGRect { CGRect(x: 0, y: 0, width: width, height: height) }
}
