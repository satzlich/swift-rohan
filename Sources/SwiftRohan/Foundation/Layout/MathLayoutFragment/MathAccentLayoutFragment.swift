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

  func fixLayout(_ context: MathContext) {
    let font = context.getFont()
    let accent = getAccentGlyph(font: font, context: context)
    let accentBaseHeight = font.convertToPoints(context.constants.accentBaseHeight)

    if self.accent.subtype.isTop {
      let x = nucleus.accentAttachment - accent.accentAttachment
      let gap = max(nucleus.ascent - accentBaseHeight, 0)
      let accent_pos = CGPoint(x: x, y: -gap)
      let total_ascent = max(nucleus.ascent, accent.ascent + gap)

      let items: [MathComposition.Item] = [
        (accent, accent_pos),
        (nucleus, .zero),
      ]
      nucleus.setGlyphOrigin(.zero)

      _composition = MathComposition(
        width: nucleus.width,
        ascent: total_ascent,
        descent: nucleus.descent,
        items: items)
    }
    else {
      let x = nucleus.width / 2 - accent.accentAttachment
      let gap = max(nucleus.descent, 0)
      let accent_pos = CGPoint(x: x, y: gap)
      let total_descent = max(nucleus.descent, accent.descent + gap)

      let items: [MathComposition.Item] = [
        (accent, accent_pos),
        (nucleus, .zero),
      ]
      nucleus.setGlyphOrigin(.zero)

      _composition = MathComposition(
        width: nucleus.width,
        ascent: nucleus.ascent,
        descent: total_descent,
        items: items)
    }
  }

  @inline(__always)
  private func getAccentGlyph(font: Font, context: MathContext) -> MathFragment {
    let table = context.table
    let char = accent.accent.unicodeScalars.first!

    // Forcing the accent to be at least as large as the base makes it too
    // wide in many cases.
    guard let glyph = GlyphFragment(char, font, table) else {
      let ruler = RuleFragment(width: font.size, height: 1)
      return ColoredFragment(color: .red, wrapped: ruler)
    }

    let accent: MathFragment
    switch self.accent.subtype {
    case .accent, .bottom:
      accent = glyph
    case .wideAccent, .bottomWide:
      let shortfall = font.convertToPoints(ACCENT_SHORTFALL)
      accent = glyph.stretch(
        orientation: .horizontal, target: nucleus.width, shortfall: shortfall, context)
    case .over, .under:
      let shortfall = font.convertToPoints(SPREADER_SHORTFALL)
      accent = glyph.stretch(
        orientation: .horizontal, target: nucleus.width, shortfall: shortfall, context)
    }
    return accent
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

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): MathAccentLayoutFragment"
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [nucleus])
  }
}
