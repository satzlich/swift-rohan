// Copyright 2024-2025 Lie Yan

@testable import Rohan
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
            "(12, 7.99×(7.00+1.00), ic: 0.00, ac: 4.00, Vary, never)",
            "(29, 7.68×(6.67+0.67), ic: 0.00, ac: 3.84, Relation, always)",
            "(71, 3.89×(8.46+-0.00), ic: 0.95, ac: 3.14, Alphabetic, never)",
            "(81, 5.92×(5.30+2.33), ic: 0.00, ac: 2.42, Alphabetic, never)",
            "(3049, 6.64×(9.66+3.67), ic: 3.98, ac: 3.32, Large, never)",
            "(3060, 11.32×(9.00+3.00), ic: 0.00, ac: 5.66, Large, display)",
        ]
        for (i, char) in chars.enumerated() {
            let f = GlyphFragment.create(char, font, mathTable)
            #expect(f?.description == expected[i])
        }
    }
}
