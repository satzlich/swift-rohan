// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

struct GlyphFragment: MathFragment {
    let glyph: GlyphId
    let char: UnicodeScalar
    let font: Font
    var fontSize: FontSize { FontSize(font.size) }

    let width: AbsLength
    var height: AbsLength { ascent + descent }
    let ascent: AbsLength
    let descent: AbsLength
    let italicsCorrection: AbsLength
    let accentAttachment: AbsLength

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

    init(glyph: GlyphId,
         char: UnicodeScalar,
         font: Font,
         width: AbsLength,
         ascent: AbsLength,
         descent: AbsLength,
         italicsCorrection: AbsLength,
         accentAttachment: AbsLength,
         clazz: MathClass,
         limits: Limits,
         isExtendedShape: Bool)
    {
        self.glyph = glyph
        self.char = char
        self.font = font
        self.width = width
        self.ascent = ascent
        self.descent = descent
        self.italicsCorrection = italicsCorrection
        self.accentAttachment = accentAttachment
        self.clazz = clazz
        self.limits = limits
        self.isExtendedShape = isExtendedShape
    }

    static func create(_ char: UnicodeScalar,
                       _ font: Font,
                       _ mathTable: MathTable) -> GlyphFragment?
    {
        guard let glyph = font.getGlyph(for: Character(char)) else { return nil }
        let rect = font.getBoundingRect(for: glyph)

        let width = rect.width
        let descent = -rect.origin.y
        let ascent = rect.height - descent

        let italicsCorrection = {
            guard let value = mathTable.glyphInfo?.italicsCorrections?.get(glyph)?.value
            else { return 0.0 }
            return font.convertToPoints(numericCast(value))
        }()

        let accentAttachment = {
            guard let value = mathTable.glyphInfo?.topAccentAttachments?.get(glyph)?.value
            else { return width / 2 }
            return font.convertToPoints(numericCast(value))
        }()

        let isExtendedShape =
            mathTable.glyphInfo?.extendedShapeCoverage?.contains(glyph) ?? false

        let clazz = char.mathClass ?? .Normal
        let limits = Limits.defaultValue(forChar: char)

        return GlyphFragment(glyph: glyph,
                             char: char,
                             font: font,
                             width: AbsLength.pt(width),
                             ascent: AbsLength.pt(ascent),
                             descent: AbsLength.pt(descent),
                             italicsCorrection: AbsLength.pt(italicsCorrection),
                             accentAttachment: AbsLength.pt(accentAttachment),
                             clazz: clazz,
                             limits: limits,
                             isExtendedShape: isExtendedShape)
    }
}

extension GlyphFragment: CustomStringConvertible {
    public var description: String {
        """
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
