// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct MathLayoutFragmentTests {
    @Test
    static func test_MathListLayoutFragment() {
        let text = "f(n+2)=f(n+1)+f(n)"
        let mathListLayoutFragmnet = MathListLayoutFragment()

        let font = Font.createWithName("Latin Modern Math", 12, isFlipped: true)
        let mathContext = MathContext(font, .display)!

        let fragments = text.unicodeScalars
            .map { char in
                MathUtils.styledChar(char, .serif,
                                     bold: false, italic: nil, autoItalic: true)
            }
            .compactMap { MathGlyphLayoutFragment($0, font, mathContext.table, 1) }
        mathListLayoutFragmnet.insert(contentsOf: fragments, at: 0)
        mathListLayoutFragmnet.fragmentsDidChange(mathContext)

        let filePath = TestUtils.filePath(#function.dropLast(2), fileExtension: ".pdf")!
        DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { bounds in
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
            mathListLayoutFragmnet.draw(at: CGPoint(x: 5, y: 50), in: cgContext)
        }
    }
}
