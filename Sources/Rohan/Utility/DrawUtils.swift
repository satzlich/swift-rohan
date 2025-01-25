// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum DrawUtils {
    @discardableResult
    public static func drawPDF(
        filePath: String,
        pageSize: NSSize = NSSize(width: 500, height: 250), // A5 landscape
        isFlipped: Bool = false,
        drawingHandler: (NSRect) -> Void
    ) -> Bool {
        let filePath = URL(fileURLWithPath: filePath)
        var pageRect = NSRect(origin: .zero, size: pageSize)

        // create PDF context
        guard let pdfContext = CGContext(filePath as CFURL, mediaBox: &pageRect, nil)
        else { return false }

        // switch context
        let previousContext = NSGraphicsContext.current
        NSGraphicsContext.current = .init(cgContext: pdfContext, flipped: false)
        defer { NSGraphicsContext.current = previousContext }

        // Begin the PDF page
        pdfContext.beginPDFPage(nil)

        do {
            pdfContext.saveGState()
            if isFlipped {
                pdfContext.textMatrix = .identity
                    .translatedBy(x: 0, y: pageSize.height)
                    .scaledBy(x: 1, y: -1)
                pdfContext.translateBy(x: 0, y: pageSize.height)
                pdfContext.scaleBy(x: 1, y: -1)
            }
            drawingHandler(pageRect)
            pdfContext.restoreGState()
        }
        // End the PDF page
        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return true
    }

    @discardableResult
    public static func draw(attributedString: NSAttributedString,
                            in rect: NSRect) -> Bool
    {
        // center the text in the rect
        let size = attributedString.size()
        let centered = CGRect(origin: .zero, size: size).centered(in: rect)
        // draw
        attributedString.draw(in: centered)
        return true
    }
}
