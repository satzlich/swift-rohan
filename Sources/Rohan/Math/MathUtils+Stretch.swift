// Copyright 2024-2025 Lie Yan

import Foundation
import OSLog
import TTFParser

extension MathUtils {
    /**
     Return whether the glyph is stretchable and if it is, along which axis it
     can be stretched.
     */
    internal static func stretchAxis(for glyph: GlyphId,
                                     _ table: MathTable) -> Optional<TextOrientation>
    {
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

    /**
     Try to stretch a glyph to a desired width or height.
     The resulting frame may not have the exact desired width or height.

     - Parameters:
        - base: the base glyph
        - orientation: the axis along which the glyph is to be stretched
        - target: the desired width or height
        - shortfall: the amount by which the desired width or height is short
     */
    static func stretchGlyph(_ base: GlyphFragment,
                             orientation: TextOrientation,
                             target: Double,
                             shortfall: Double,
                             context: MathContext) -> MathFragment
    {
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
        return constructAssembly(for: base, orientation: orientation,
                                 minOverlap: minOverlap, target: target,
                                 assembly, context)
    }

    /**
     - Parameters:
        - minOverlap: the minimum connector overlap __in design units__
     */
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
        func computeTotal(_ parts: [GlyphPartRecord])
        -> (advance: Double, stretch: Double) {
            // total advance MINUS connector lengths
            var totalAdvance = 0
            // total stretchability between parts
            var totalStretch = 0

            for (i, part) in parts.enumerated() {
                var advance: Int = numericCast(part.fullAdvance)
                if i + 1 < parts.count { // there is a next
                    let next = parts[i + 1]
                    // max possible overlap
                    let maxOverlap: Int = numericCast(min(part.endConnectorLength,
                                                          next.startConnectorLength))
                    // shave off connector length
                    advance -= maxOverlap

                    // add to total
                    totalStretch += maxOverlap - minOverlap

                    // sanity check
                    if maxOverlap < minOverlap {
                        Rohan.logger.warning("""
                        maxOverlap < minOverlap indicates a bug in the font \
                        "\(base.font.copyFamilyName())"
                        """)
                    }
                }
                // add to total
                totalAdvance += advance
            }

            return (base.font.convertToPoints(totalAdvance),
                    base.font.convertToPoints(totalStretch))
        }

        /* Determine the number of times the extenders need to be repeated as well
         as a ratio specifying how much to spread the parts apart
         (0 for maximal overlap, 1 for minimal overlap). */
        func search(_ n: Int) -> ([GlyphPartRecord], ratio: Double, advance: Double) {
            var parts: [GlyphPartRecord] = []
            var ratio = 0.0
            var totalAdvance = 0.0
            for k in 0 ..< n {
                // generate parts
                parts = MathUtils.generateParts(of: assembly, repeats: k)

                let (advance, stretch) = computeTotal(parts)
                // update ratio and total advance
                ratio = 0.0
                totalAdvance = advance

                if totalAdvance >= target { break }
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
        let (parts, ratio, totalAdvance) = search(1024) // 1024 is an arbitrary number

        // compute fragments and advance for each
        typealias _Fragment = (fragment: SuccinctGlyphFragment, advance: Double)
        let fragments: [_Fragment] = parts.enumerated().map { (i, part) in
            var advance = CGFloat(part.fullAdvance)
            if i + 1 < parts.count { // there is a next
                let next = parts[i + 1]
                let maxOverlap = CGFloat(min(part.endConnectorLength,
                                             next.startConnectorLength))
                advance -= maxOverlap
                advance += ratio * (maxOverlap - CGFloat(minOverlap))
            }
            return (SuccinctGlyphFragment(part.glyphID, base.font),
                    base.font.convertToPoints(fromUnits: advance))
        }

        // compute metrics
        let width: Double
        let ascent: Double
        let descent: Double
        let accentAttachment: Double
        switch orientation {
        case .horizontal:
            width = totalAdvance
            ascent = base.ascent
            descent = base.descent
            accentAttachment = width / 2
        case .vertical:
            let axisHeight = base.font.convertToPoints(context.constants.axisHeight.value)
            width = fragments.lazy.map(\.fragment.width).max() ?? .zero
            ascent = totalAdvance / 2 + axisHeight
            descent = totalAdvance - ascent
            accentAttachment = base.accentAttachment
        }

        // compute positions
        var offset = 0.0
        typealias _Item = CompositeGlyph.Item
        let items = fragments.map { fragment, advance in
            let position: CGPoint =
                switch orientation {
                case .horizontal: CGPoint(x: offset, y: 0)
                case .vertical: CGPoint(x: 0, y: descent - offset - fragment.descent)
                }
            offset += advance
            return _Item(fragment, position)
        }

        let compositeGlyph = CompositeGlyph(width: width,
                                            ascent: ascent,
                                            descent: descent,
                                            font: base.font,
                                            items: items)

        return VariantFragment(char: base.char,
                               compositeGlyph: compositeGlyph,
                               italicsCorrection: 0,
                               accentAttachment: accentAttachment,
                               clazz: base.clazz,
                               limits: base.limits,
                               isExtendedShape: true,
                               isMiddleStretched: nil)
    }

    /**
     Return an iterator over the assembly's parts with extenders repeated the
     specified number of times.
     */
    private static func generateParts(of assembly: GlyphAssemblyTable,
                                      repeats: Int) -> [GlyphPartRecord]
    {
        assembly.parts.flatMap { part in
            let count = if part.isExtender() { repeats } else { 1 }
            return repeatElement(part, count: count)
        }
    }
}
