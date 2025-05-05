// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation

protocol GlyphProtocol {
  /// Bounding width of the glyph
  var boundingWidth: Double { get }
  /// Advance width of the glyph
  var width: Double { get }

  var height: Double { get }
  var ascent: Double { get }
  var descent: Double { get }

  func draw(at point: CGPoint, in context: CGContext)
}

extension GlyphProtocol {
  var boundingWidth: Double {
    width
  }

  var size: CGSize {
    CGSize(width: width, height: height)
  }

  /// Glyph bounds with the baseline position accommodated
  var bounds: CGRect {
    CGRect(x: 0, y: -descent, width: width, height: height)
  }

  var boxMetrics: BoxMetrics {
    BoxMetrics(width: width, ascent: ascent, descent: descent)
  }

  func isNearlyEqual(to other: BoxMetrics) -> Bool {
    boxMetrics.isNearlyEqual(to: other)
  }
}
