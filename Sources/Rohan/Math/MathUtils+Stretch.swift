// Copyright 2024-2025 Lie Yan

import Foundation
import TTFParser

extension MathUtils {
    struct MathContext {
        let font: Font
        let table: MathTable
        let constants: MathConstantsTable

        init?(_ font: Font) {
            guard let table = font.copyMathTable(),
                  let constants = table.constants
            else { return nil }
            self.font = font
            self.table = table
            self.constants = constants
        }
    }

    /**
     Return whether the glyph is stretchable and if it is, along which axis it
     can be stretched.
     */
    internal static func stretchAxis(for glyph: GlyphId,
                                     _ table: MathTable) -> Optional<TextOrientation>
    {
        let vertical: TextOrientation? = table.variants
            .flatMap { $0.verticalConstructions?.get(glyph) }
            .map { _ in .vertical }
        let horizontal: TextOrientation? = table.variants
            .flatMap { $0.horizontalConstructions?.get(glyph) }
            .map { _ in .horizontal }

        switch (vertical, horizontal) {
        case (.some, .none): return .vertical
        case (.none, .some): return .horizontal
        case _:
            // As far as we know, there aren't any glyphs that have both
            // vertical and horizontal constructions. So for the time being, we
            // will assume that a glyph cannot have both.
            return nil
        }
    }

    /**
     Try to stretch a glyph to a desired width or height.
     The resulting frame may not have the exact desired width or height.

     - Parameters:
         - base: The base glyph.
         - target: The target width or height.
         - shortfall: The amount of shortfall.
         - orientation: The orientation of the glyph.
     */
    static func stretchGlyph(_ base: GlyphFragment,
                             orientation: TextOrientation,
                             target: AbsLength,
                             shortfall: AbsLength,
                             context: MathContext) -> MathFragment
    {
        // the minimum width/height that must be satisfied
        let minAdvance = target - shortfall

        // if the base glyph is good enough, use it.
        do {
            let advance =
                switch orientation {
                case .horizontal: base.width
                case .vertical: base.height
                }
            if advance >= minAdvance { return base }
        }

        // if there are no variants, just return the base
        guard let variants = context.table.variants else { return base }

        // obtain the construction table for the base glyph
        // if there is no construction, just return the base
        let constructions =
            switch orientation {
            case .horizontal: variants.horizontalConstructions
            case .vertical: variants.verticalConstructions
            }
        guard let construction = constructions?.get(base.glyph) else { return base }

        // search for a pre-made variant with a good advance.
        var glyph = base.glyph
        var advance: AbsLength = base.width
        for variant in construction.variants {
            glyph = variant.variantGlyph
            advance = base.font.convertToAbsLength(variant.advanceMeasurement)

            // if the vairant is good enough, use it.
            if advance >= minAdvance {
                return GlyphFragment(base.char, glyph, base.font, context.table)
            }
        }
        // if there is no assembly table, use the last variant
        guard let assembly = construction.assembly else {
            return GlyphFragment(base.char, glyph, base.font, context.table)
        }

        // assemble from parts
        let minOverlap = base.font.convertToAbsLength(variants.minConnectorOverlap)
        return constructAssembly(for: base,
                                 orientation: orientation,
                                 minOverlap: minOverlap,
                                 target: target,
                                 assembly, context)
    }

    static func constructAssembly(
        for base: GlyphFragment,
        orientation: TextOrientation,
        minOverlap: AbsLength,
        target: AbsLength,
        _ assembly: GlyphAssemblyTable,
        _ context: MathContext
    ) -> MathFragment {
        func computeTotal(_ parts: [GlyphPartRecord]) -> (advance: AbsLength,
                                                          stretch: AbsLength)
        {
            // total (natural) advance
            var totalAdvance: AbsLength = .zero
            // total stretchability between parts
            var totalStretch: AbsLength = .zero

            for (i, part) in parts.enumerated() {
                var advance = base.font.convertToAbsLength(part.fullAdvance)

                if i + 1 < parts.count { // there is a next
                    let next = parts[i + 1]
                    var maxOverlap =
                        base.font.convertToAbsLength(min(part.endConnectorLength,
                                                         next.startConnectorLength))
                    if maxOverlap < minOverlap {
                        assertionFailure("maxOverlap < minOverlap is indicative " +
                            "of a bug in the font")
                        maxOverlap = minOverlap
                    }
                    advance -= maxOverlap
                    totalStretch += maxOverlap - minOverlap
                }

                totalAdvance += advance
            }
            return (totalAdvance, totalStretch)
        }

        /* Determine the number of times the extenders need to be repeated as well
         as a ratio specifying how much to spread the parts apart
         (0 = maximal overlap, 1 = minimal overlap). */
        var repeats = 0
        var ratio = 0.0
        var totalAdvance: AbsLength = .zero
        var parts: [GlyphPartRecord] = []

        for k in 0 ..< 1024 { // 1024 is an arbitrary number
            repeats = k
            ratio = 0.0
            parts = MathUtils.parts(of: assembly, repeats: repeats)
            let (advance, stretch) = computeTotal(parts)

            totalAdvance = advance
            if totalAdvance >= target { break }
            else if totalAdvance + stretch >= target {
                // assert(advance < target && stretch > 0)
                let delta = target - advance
                ratio = min(delta / stretch, 1.0)
                totalAdvance = target
                break
            }
        }

        // compose fragments
        let fragments = parts.enumerated().map {
            (i, part) -> (fragment: GlyphFragment, advance: AbsLength) in

            var advance = base.font.convertToAbsLength(part.fullAdvance)
            if i + 1 < parts.count { // there is a next
                let next = parts[i + 1]
                let maxOverlap =
                    base.font.convertToAbsLength(min(part.endConnectorLength,
                                                     next.startConnectorLength))
                advance -= maxOverlap
                advance += ratio * (maxOverlap - minOverlap)
            }
            return (GlyphFragment(base.char, part.glyphID, base.font, context.table),
                    advance)
        }

        let width: AbsLength
        let ascent: AbsLength
        let descent: AbsLength
        switch orientation {
        case .horizontal:
            width = totalAdvance
            ascent = base.ascent
            descent = base.descent
        case .vertical:
            let axisHeight =
                base.font.convertToAbsLength(context.constants.axisHeight.value)
            width = fragments.lazy.map(\.fragment.width).max() ?? .zero
            ascent = totalAdvance / 2 + axisHeight
            descent = totalAdvance - ascent
        }

        var offset: AbsLength = .zero
        let items = fragments.map { fragment, advance in
            let position =
                switch orientation {
                case .horizontal:
                    CGPoint(x: offset.ptValue, y: 0)
                case .vertical:
                    CGPoint(x: 0, y: (-descent + offset + fragment.descent).ptValue)
                }
            offset += advance
            return (position, fragment)
        }

        let accentAttachent: AbsLength =
            switch orientation {
            case .horizontal: width / 2
            case .vertical: base.accentAttachment
            }

        let composition = MathComposition(width: width,
                                          ascent: ascent,
                                          descent: descent,
                                          items: items)

        return VariantFragment(char: base.char,
                               fontSize: base.fontSize,
                               composition: composition,
                               italicsCorrection: .zero,
                               accentAttachment: accentAttachent,
                               clazz: base.clazz,
                               limits: base.limits,
                               isExtendedShape: true,
                               isMiddleStretched: nil)
    }

    /**
     Return an iterator over the assembly's parts with extenders repeated the
     specified number of times.
     */
    static func parts(of assembly: GlyphAssemblyTable,
                      repeats: Int) -> [GlyphPartRecord]
    {
        assembly.parts.flatMap { part in
            let count = if part.isExtender() { repeats } else { 1 }
            return repeatElement(part, count: count)
        }
    }
}
