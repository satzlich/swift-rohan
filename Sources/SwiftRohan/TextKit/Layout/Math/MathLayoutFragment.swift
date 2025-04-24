// Copyright 2024-2025 Lie Yan

import CoreGraphics
import TTFParser
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment, MathFragment {
  // MARK: - Frame

  /// Set the origin of the layout fragment frame with respect to the enclosing frame.
  /// - Note: The origin of bounds is at the reference point of the fragment box.
  func setGlyphOrigin(_ origin: CGPoint)

  // MARK: - Debug Facilities

  /// Debug description of the layout fragment
  func debugPrint(_ name: String?) -> Array<String>
}

extension MathLayoutFragment {
  /// baseline position of the fragment box
  var baselinePosition: CGFloat { ascent }

  /// bounds with origin at the baseline
  var bounds: CGRect { CGRect(x: 0, y: -descent, width: width, height: height) }

  var boxDescription: String {
    let origin = self.glyphFrame.origin.formatted(2)
    let width = String(format: "%.2f", self.width)
    let ascent = String(format: "%.2f", self.ascent)
    let descent = String(format: "%.2f", self.descent)
    return "\(origin) \(width)×(\(ascent)+\(descent))"
  }

  /// Returns true if the y-range of frame contains given point.
  func yContains(_ point: CGPoint, tolerance: CGFloat = 1e-6) -> Bool {
    let y = point.y
    let origin = glyphFrame.origin
    let minY = origin.y - ascent
    let maxY = origin.y + descent
    return minY - tolerance <= y && y <= maxY + tolerance
  }

  /// Returns true if the x-range of frame contains the given point.
  func xContains(_ point: CGPoint, tolerance: CGFloat = 1e-6) -> Bool {
    let x = point.x
    let origin = glyphFrame.origin
    let minX = origin.x
    let maxX = origin.x + width
    return minX - tolerance <= x && x <= maxX + tolerance
  }

  /// If no kern table is provided for a corner, a kerning amount of zero is assumed.
  func kernAtHeight(_ context: MathContext, _ corner: Corner, _ height: Double) -> Double
  {
    if let list = self as? MathListLayoutFragment, list.count == 1,
      let glyph = (list.get(0) as? MathGlyphLayoutFragment)?.glyph
    {
      return SwiftRohan.kernAtHeight(context, glyph.glyph, corner, height) ?? 0
    }
    else if let glyph = (self as? MathGlyphLayoutFragment)?.glyph {
      return SwiftRohan.kernAtHeight(context, glyph.glyph, corner, height) ?? 0
    }
    else {
      return 0
    }
  }

  func debugPrint() -> Array<String> {
    return debugPrint(nil)
  }
}

/// Look up a kerning value at given corner and height
private func kernAtHeight(
  _ context: MathContext,
  _ id: GlyphId,
  _ corner: Corner,
  _ height: Double
) -> Double? {
  guard let kerns = context.table.glyphInfo?.kerns?.get(id),
    let kern: MathKernTable =
      switch corner {
      case .topLeft: kerns.topLeft
      case .topRight: kerns.topRight
      case .bottomLeft: kerns.bottomLeft
      case .bottomRight: kerns.bottomRight
      }
  else { return nil }

  let font = context.getFont()
  let heightInUnits = Int16(font.convertToDesignUnits(height))
  let value = kern.get(heightInUnits)
  return font.convertToPoints(value)
}
