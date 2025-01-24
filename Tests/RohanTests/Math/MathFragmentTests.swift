// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import CoreText
import Foundation
import Testing

struct MathFragmentTests {
    @Test
    static func testGlyphFragment() {
        let font = CTFontCreateWithName("Latin Modern Math" as CFString, 12, nil)
        let mathTable = font.copyMathTable()!

        let chars: [UnicodeScalar] = ["+", "<", "f", "p", "∫", "∑"]
        let expected = [
            "(12, 9.34×(7.00+1.00), ic: 0.00, ac: 4.67, Vary, never)",
            "(29, 9.34×(6.67+0.67), ic: 0.00, ac: 4.67, Relation, always)",
            "(71, 3.67×(8.46+-0.00), ic: 0.95, ac: 3.14, Alphabetic, never)",
            "(81, 6.67×(5.30+2.33), ic: 0.00, ac: 2.42, Alphabetic, never)",
            "(3049, 7.98×(9.66+3.67), ic: 3.98, ac: 3.99, Large, never)",
            "(3060, 12.67×(9.00+3.00), ic: 0.00, ac: 6.34, Large, display)",
        ]
        for (i, char) in chars.enumerated() {
            let fragment = GlyphFragment(char, font, mathTable)!
            #expect(fragment.description == expected[i])
        }
    }

    @Test
    static func testVariantFragment() {
        let filePath = TestUtils.filePath(#function.dropLast(2), fileExtension: ".pdf")!
        DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { bounds in
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
            Self.drawSample(bounds, cgContext)
        }
    }

    static func drawSample(_ bounds: CGRect, _ cgContext: CGContext) {
        cgContext.saveGState()
        defer { cgContext.restoreGState() }

        let smallX: UnicodeScalar = MathUtils.styledChar("x", .serif, bold: false,
                                                         italic: nil, autoItalic: true)
        let smallF: UnicodeScalar = MathUtils.styledChar("f", .serif, bold: false,
                                                         italic: nil, autoItalic: true)
        let leftBrace: UnicodeScalar = "{"
        let leftCeil: UnicodeScalar = "⌈"
        let circumflex: UnicodeScalar = "\u{0302}"
        let topBrace: UnicodeScalar = "\u{23de}"

        Self.createAndDrawVariants(leftBrace, smallX, .vertical, CGPoint(x: 20, y: 100),
                                   [10, 30, 50, 70, 90], cgContext)
        Self.createAndDrawVariants(leftCeil, smallX, .vertical, CGPoint(x: 120, y: 100),
                                   [10, 30, 50, 70, 90], cgContext)

        Self.createAndDrawVariants(circumflex, smallF, .horizontal,
                                   CGPoint(x: 350, y: 100),
                                   [10, 15, 20, 25, 30], cgContext)

        Self.createAndDrawVariants(topBrace, smallF, .horizontal,
                                   CGPoint(x: 350, y: 200),
                                   [10, 30, 50, 70, 90], cgContext)
    }

    static func createAndDrawVariants(_ char: UnicodeScalar,
                                      _ referenceChar: UnicodeScalar,
                                      _ orientation: TextOrientation,
                                      _ point: CGPoint,
                                      _ lengths: [CGFloat],
                                      _ cgContext: CGContext)
    {
        let font = CTFontCreateWithName("Latin Modern Math" as CFString, 12, nil)
        let table = font.copyMathTable()!
        let context = MathUtils.MathContext(font)!

        let styledChar = MathUtils.styledChar(referenceChar, .serif,
                                              bold: false, italic: nil, autoItalic: true)
        let referenceChar_ = GlyphFragment(styledChar, font, table)!

        let char_ = GlyphFragment(char, font, table)!
        let variants = lengths.map { length in
            MathUtils.stretchGlyph(char_,
                                   orientation: orientation,
                                   target: .pt(length),
                                   shortfall: .pt(2),
                                   context: context)
        }

        if orientation == .vertical {
            referenceChar_.draw(at: point, in: cgContext)

            for (i, variant) in ([char_] + variants).enumerated() {
                let position = CGPoint(x: point.x + CGFloat(i + 1) * 10.0, y: point.y)
                variant.draw(at: position, in: cgContext)
            }
        }
        else {
            assert(orientation == .horizontal)

            referenceChar_.draw(at: point, in: cgContext)
            let accentHeight = referenceChar_.ascent.ptValue

            func xPos(_ fragment: MathFragment) -> CGFloat {
                point.x - fragment.accentAttachment.ptValue +
                    referenceChar_.accentAttachment.ptValue
            }

            for (i, variant) in ([char_] + variants).enumerated() {
                let position = CGPoint(x: xPos(variant),
                                       y: point.y + accentHeight + CGFloat(i) * 10.0)
                variant.draw(at: position, in: cgContext)
            }
        }
    }
}
