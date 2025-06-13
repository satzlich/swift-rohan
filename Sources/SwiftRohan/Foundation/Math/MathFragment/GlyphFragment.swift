// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

public struct GlyphFragment: MathFragment {
  let glyph: GlyphId
  let char: UnicodeScalar
  let font: Font

  let width: Double
  var height: Double { ascent + descent }
  let ascent: Double
  let descent: Double
  let italicsCorrection: Double
  let accentAttachment: Double

  let clazz: MathClass
  let limits: Limits

  var isSpaced: Bool {
    // Only fences should be surrounded by spaces.
    clazz == .Fence
  }

  var isTextLike: Bool {
    // A glyph is considered text-like if its class is not `Large`.
    clazz != .Large
  }

  let isExtendedShape: Bool

  // MARK: - Draw

  public func draw(at point: CGPoint, in context: CGContext) {
    font.drawGlyph(glyph, point, context)
  }

  // MARK: - Initializers

  init?(char: Character, _ font: Font, _ table: MathTable) {
    guard char.unicodeScalars.count == 1,
      let scalar = char.unicodeScalars.first
    else { return nil }
    self.init(scalar, font, table)
  }

  public init?(_ scalar: UnicodeScalar, _ font: Font, _ table: MathTable) {
    guard let glyph = font.getGlyph(for: scalar)
    else { return nil }
    self.init(scalar, glyph, font, table)
  }

  init(_ char: UnicodeScalar, _ glyph: GlyphId, _ font: Font, _ table: MathTable) {
    let advance = font.getAdvance(for: glyph, .horizontal)
    let (ascent, descent) = font.getAscentDescent(for: glyph)

    let italicsCorrection: Double
    if let value = table.glyphInfo?.italicsCorrections?.get(glyph)?.value {
      italicsCorrection = font.convertToPoints(value)
    }
    else {
      italicsCorrection = 0.0
    }

    let accentAttachment: Double
    if let value = table.glyphInfo?.topAccentAttachments?.get(glyph)?.value {
      accentAttachment = font.convertToPoints(value)
    }
    else {
      accentAttachment = (advance + italicsCorrection) / 2
    }

    let isExtendedShape = table.glyphInfo?.extendedShapeCoverage?.contains(glyph) ?? false
    let clazz = MathUtils.MCLS[char] ?? (char.mathClass ?? .Normal)
    let limits = Limits.defaultValue(forChar: char)

    // Init
    self.glyph = glyph
    self.char = char
    self.font = font
    self.width = advance + (isExtendedShape ? 0 : italicsCorrection)
    self.ascent = ascent
    self.descent = descent
    self.italicsCorrection = italicsCorrection
    self.accentAttachment = accentAttachment
    self.clazz = clazz
    self.limits = limits
    self.isExtendedShape = isExtendedShape
  }
}

extension GlyphFragment: CustomStringConvertible {
  public var description: String {
    func format(_ value: Double) -> String { String(format: "%.2f", value) }

    let width = format(width)
    let ascent = format(ascent)
    let descent = format(descent)
    let italicsCorrection = format(italicsCorrection)
    let accentAttachment = format(accentAttachment)

    return """
      (\(glyph), \
      \(width)×(\(ascent)+\(descent)), \
      ic: \(italicsCorrection), \
      ac: \(accentAttachment), \
      \(clazz), \
      \(limits)\
      )
      """
  }
}

extension GlyphFragment {
  /// Stretch the glyph to the target extent in the specified orientation.
  /// - Parameters:
  ///   - orientation: The orientation of the stretch.
  ///   - target: The target extent.
  ///   - shortfall: The shortfall for result extent.
  ///   - context: The math context.
  func stretch(
    orientation: TextOrientation, target: CGFloat, shortfall: CGFloat,
    _ context: MathContext
  ) -> MathFragment {
    MathUtils.stretchGlyph(
      self, orientation: orientation, target: target, shortfall: shortfall,
      context: context)
  }
}

private extension MathUtils {
  /**
   Try to stretch a glyph to a desired width or height.
   The resulting frame may not have the exact desired width or height.
  
   - Parameters:
      - base: the base glyph
      - orientation: the axis along which the glyph is to be stretched
      - target: the desired width or height
      - shortfall: the amount by which the desired width or height is short
    */
  static func stretchGlyph(
    _ base: GlyphFragment,
    orientation: TextOrientation,
    target: Double,
    shortfall: Double,
    context: MathContext
  ) -> MathFragment {
    // the minimum width/height that must be satisfied
    let minAdvance = target - shortfall

    // if the base glyph is good enough, use it
    let baseAdvance =
      switch orientation {
      case .horizontal: base.width
      case .vertical: base.height
      }
    if baseAdvance >= minAdvance { return base }

    // if there are no variants, return the base
    guard let variants = context.table.variants else { return base }

    // if there is no construction, return the base
    let constructions =
      switch orientation {
      case .horizontal: variants.horizontalConstructions
      case .vertical: variants.verticalConstructions
      }
    guard let construction = constructions?.get(base.glyph) else { return base }

    // search for a pre-made variant with a good advance
    var variantGlyph = base.glyph
    for variant in construction.variants {
      variantGlyph = variant.variantGlyph
      let advance = base.font.convertToPoints(variant.advanceMeasurement)

      // if the vairant is good enough, use it
      if advance >= minAdvance {
        return GlyphFragment(base.char, variantGlyph, base.font, context.table)
      }
    }
    // if there is no assembly table, use the last variant
    guard let assembly = construction.assembly else {
      return GlyphFragment(base.char, variantGlyph, base.font, context.table)
    }

    // assemble from parts
    let minOverlap: UInt16 = variants.minConnectorOverlap
    return constructAssembly(
      for: base, orientation: orientation,
      minOverlap: minOverlap, target: target,
      assembly, context)
  }

  /// - Parameters:
  ///   - minOverlap: the minimum connector overlap __in design units__
  private static func constructAssembly(
    for base: GlyphFragment,
    orientation: TextOrientation,
    minOverlap: UInt16,
    target: Double,
    _ assembly: GlyphAssemblyTable,
    _ context: MathContext
  ) -> MathFragment {
    // min allowed overlap
    let minOverlap: Int = numericCast(minOverlap)

    // compute total (natural) advance and total stretch
    func computeTotal(_ parts: Array<GlyphPartRecord>) -> (advance: Double, stretch: Double) {
      // total advance MINUS connector lengths
      var totalAdvance = 0
      // total stretchability between parts
      var totalStretch = 0

      for (i, part) in parts.enumerated() {
        var advance: Int = numericCast(part.fullAdvance)
        if i + 1 < parts.count {  // there is a next
          let next = parts[i + 1]
          // max possible overlap
          let maxOverlap: Int = numericCast(
            min(
              part.endConnectorLength,
              next.startConnectorLength))
          // shave off connector length
          advance -= maxOverlap

          // add to total
          totalStretch += maxOverlap - minOverlap

          // sanity check
          if maxOverlap < minOverlap {
            Rohan.logger.warning(
              """
              maxOverlap < minOverlap indicates a bug in the font \
              "\(base.font.copyFamilyName(), privacy: .public)"
              """)
          }
        }
        // add to total
        totalAdvance += advance
      }

      return (
        base.font.convertToPoints(totalAdvance),
        base.font.convertToPoints(totalStretch)
      )
    }

    /* Determine the number of times the extenders need to be repeated as well
       as a ratio specifying how much to spread the parts apart
       (0 for maximal overlap, 1 for minimal overlap). */
    func search(_ n: Int) -> (Array<GlyphPartRecord>, ratio: Double, advance: Double) {
      var parts: Array<GlyphPartRecord> = []
      var ratio = 0.0
      var totalAdvance = 0.0
      for k in 0..<n {
        // generate parts
        parts = MathUtils.generateParts(of: assembly, repeats: k)

        let (advance, stretch) = computeTotal(parts)
        // update ratio and total advance
        ratio = 0.0
        totalAdvance = advance

        if totalAdvance >= target {
          break
        }
        else if totalAdvance + stretch >= target {
          assert(advance < target && stretch > 0)
          let delta = target - advance
          // update ratio and total advance
          ratio = min(delta / stretch, 1.0)
          totalAdvance = target
          break
        }
      }
      return (parts, ratio, totalAdvance)
    }

    // search for a good number of repetitions
    let (parts, ratio, totalAdvance) = search(1024)  // 1024 is an arbitrary number

    let orientation_: VariantFragment.Orientation
    switch orientation {
    case .horizontal:
      orientation_ = .horizontal
    case .vertical:
      let axisHeight = base.font.convertToPoints(context.constants.axisHeight.value)
      orientation_ = .vertical(axisHeight: axisHeight)
    }

    return VariantFragment.from(
      parts: parts, ratio: ratio, totalAdvance: totalAdvance, base: base,
      orientation: orientation_, minOverlap: minOverlap)
  }

  /// Returns an array of parts with extenders repeated the specified number
  /// of times.
  private static func generateParts(
    of assembly: GlyphAssemblyTable, repeats: Int
  ) -> Array<GlyphPartRecord> {
    assembly.parts.flatMap { part in
      let count = part.isExtender() ? repeats : 1
      return repeatElement(part, count: count)
    }
  }
}
