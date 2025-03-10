// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public protocol LayoutFragment {
  // MARK: - Frame

  /**
   The rectangle the framework uses for tiling the layout fragment inside the target
   layout coordinate system.

   - Note: the origin is at the reference point of the fragment as a glyph.
   */
  var glyphFrame: CGRect { get }

  /** The position of baseline measured from the top of fragment. */
  var baselinePosition: CGFloat { get }

  /** bounds with origin at the baseline */
  var bounds: CGRect { get }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext)
}
