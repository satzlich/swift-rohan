// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

public struct GlyphFragment: MathFragment {
    let glyph: GlyphId
    let char: UnicodeScalar
    let font: Font
    var fontSize: FontSize { FontSize(font.size) }

    // MARK: - Metrics

    let width: Double
    var height: Double { ascent + descent }
    let ascent: Double
    let descent: Double
    let italicsCorrection: Double
    let accentAttachment: Double

    // MARK: - Categories

    let clazz: MathClass
    let limits: Limits

    // MARK: - Flags

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

    public init?(_ char: UnicodeScalar,
                 _ font: Font,
                 _ table: MathTable)
    {
        guard let glyph = font.getGlyph(for: Character(char)) else { return nil }
        self.init(char, glyph, font, table)
    }

    init(_ char: UnicodeScalar,
         _ glyph: GlyphId,
         _ font: Font,
         _ table: MathTable)
    {
        let width = font.getAdvance(for: glyph, .horizontal)
        let rect = font.getBoundingRect(for: glyph)
        let descent = -rect.origin.y
        let ascent = rect.height - descent

        let italicsCorrection = {
            guard let value = table.glyphInfo?.italicsCorrections?.get(glyph)?.value
            else { return 0.0 }
            return font.convertToPoints(value)
        }()

        let accentAttachment = {
            guard let value = table.glyphInfo?.topAccentAttachments?.get(glyph)?.value
            else { return width / 2 }
            return font.convertToPoints(value)
        }()

        let isExtendedShape =
            table.glyphInfo?.extendedShapeCoverage?.contains(glyph) ?? false
        let clazz = char.mathClass ?? .Normal
        let limits = Limits.defaultValue(forChar: char)

        // Init
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
}

extension GlyphFragment: CustomStringConvertible {
    public var description: String {
        func f(_ value: Double) -> String {
            String(format: "%.2f", value)
        }

        return """
        (\(glyph), \
        \(f(width))×(\(f(ascent))+\(f(descent))), \
        ic: \(f(italicsCorrection)), \
        ac: \(f(accentAttachment)), \
        \(clazz), \
        \(limits)\
        )
        """
    }
}
