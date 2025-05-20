// Copyright 2024-2025 Lie Yan

import Foundation
import OSLog
import TTFParser

extension MathUtils {
  /// Return whether the glyph is stretchable and if it is, along which axis it
  /// can be stretched.
  internal static func stretchAxis(
    for glyph: GlyphId, _ table: MathTable
  ) -> Optional<TextOrientation> {
    /* As far as we know, there aren't any glyphs that have both vertical
       and horizontal constructions. So for the time being, we will assume
       that a glyph cannot have both. */

    let vertical: TextOrientation? = table.variants
      .flatMap { $0.verticalConstructions?.get(glyph) }
      .map { _ in .vertical }
    if vertical != nil { return vertical }

    let horizontal: TextOrientation? = table.variants
      .flatMap { $0.horizontalConstructions?.get(glyph) }
      .map { _ in .horizontal }
    return horizontal
  }
}
