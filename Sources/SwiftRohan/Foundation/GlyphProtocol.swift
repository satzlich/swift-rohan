// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation

protocol GlyphProtocol {
  var width: Double { get }
  var height: Double { get }
  var ascent: Double { get }
  var descent: Double { get }

  func draw(at point: CGPoint, in context: CGContext)
}
