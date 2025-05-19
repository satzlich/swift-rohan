// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

/// How much the accent can be shorter than the base.
private let ACCENT_SHORTFALL = Em(0.5)
private let SPREADER_SHORTFALL = Em(0.25)

final class MathAccentLayoutFragment: MathLayoutFragment {

  let accent: MathAccent
  let nucleus: MathListLayoutFragment

  private var _composition: MathComposition

  init(_ accent: MathAccent, nucleus: MathListLayoutFragment) {
    self.accent = accent
    self.nucleus = nucleus
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Metrics

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  var italicsCorrection: Double { nucleus.italicsCorrection }
  var accentAttachment: Double { nucleus.accentAttachment }

  var clazz: MathClass { nucleus.clazz }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { nucleus.isTextLike }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()
    let table = mathContext.table
    let constants = mathContext.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    let base = nucleus  // alias
    let char = accent.accent.unicodeScalars.first!

    // Forcing the accent to be at least as large as the base makes it too
    // wide in many cases.
    let glyph =  // U+FFFD is the replacement character.
      GlyphFragment(char, font, table) ?? GlyphFragment("\u{FFFD}", font, table)!
    let accent: MathFragment
    switch self.accent.subtype {
    case .accent, .bottom:
      let short_fall = font.convertToPoints(ACCENT_SHORTFALL)
      accent = glyph
    case .wideAccent, .bottomWide:
      let shortfall = font.convertToPoints(ACCENT_SHORTFALL)
      accent = glyph.stretchHorizontal(base.width, shortfall: shortfall, mathContext)
    case .over, .under:
      let shortfall = font.convertToPoints(SPREADER_SHORTFALL)
      accent = glyph.stretchHorizontal(base.width, shortfall: shortfall, mathContext)
    }

    // Descent is negative because the accent's ink bottom is above the
    // baseline. Therefore, the default gap is the accent's negated descent
    // minus the accent base height. Only if the base is very small, we need
    // a larger gap so that the accent doesn't move too low.
    let accent_base_height = metric(from: constants.accentBaseHeight)
    let gap = base.ascent - accent_base_height
    let accent_y = gap > 0 ? -gap : 0
    let accent_pos: CGPoint
    if self.accent.subtype.isTop {
      let x = base.accentAttachment - accent.accentAttachment
      accent_pos = CGPoint(x: x, y: accent_y)
    }
    else {
      let x = base.accentAttachment - accent.accentAttachment
      accent_pos = CGPoint(x: x, y: accent_y)
    }

    // compose
    let items: [MathComposition.Item] = [
      (accent, accent_pos),
      (base, .zero),
    ]
    base.setGlyphOrigin(.zero)

    _composition = MathComposition(
      width: base.width,
      ascent: base.ascent + gap + accent.height,
      descent: base.descent,
      items: items)
  }

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    .nuc
  }

  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(component == .nuc)

    switch direction {
    case .up:
      return RayshootResult(point.with(y: self.minY), false)
    case .down:
      return RayshootResult(point.with(y: self.maxY), false)
    default:
      assertionFailure("Unexpected Direction")
      return nil
    }
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "accent \(boxDescription)"
    let nucleus = nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [nucleus])
  }
}
