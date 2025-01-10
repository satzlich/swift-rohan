// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum ImageUtils {
    @discardableResult
    public static func drawTIFF(filePath: String,
                                imageSize: NSSize = PageSize.A6.landscape,
                                backgroundColor: NSColor = .white,
                                drawingHandler: (NSRect) -> Void) -> Bool
    {
        // create image
        let image = NSImage(size: imageSize)
        image.lockFocus()
        do {
            let rect = NSRect(origin: .zero, size: imageSize)
            // draw background
            backgroundColor.setFill()
            rect.fill()
            // draw
            drawingHandler(rect)
        }
        image.unlockFocus()

        // save to file
        let fileURL = URL(fileURLWithPath: filePath)
        let result: ()? = try? image.tiffRepresentation?.write(to: fileURL)

        return result != nil
    }

    @discardableResult
    public static func drawPDF(filePath: String,
                               pageSize: NSSize = PageSize.A6.landscape,
                               drawingHandler: (NSRect) -> Void) -> Bool
    {
        return drawPDF(filePath: filePath,
                       pageSize: pageSize,
                       drawingHandler: { rect, _ in drawingHandler(rect) })
    }

    @discardableResult
    public static func drawPDF(filePath: String,
                               pageSize: NSSize = PageSize.A6.landscape,
                               drawingHandler: (NSRect, CGContext) -> Void) -> Bool
    {
        let filePath = URL(fileURLWithPath: filePath)
        var pageRect = NSRect(origin: .zero, size: pageSize)

        // create PDF context
        guard let pdfContext = CGContext(filePath as CFURL, mediaBox: &pageRect, nil)
        else { return false }

        // switch context
        let previous = NSGraphicsContext.current
        NSGraphicsContext.current = .init(cgContext: pdfContext, flipped: false)
        defer { NSGraphicsContext.current = previous }

        // Begin the PDF page
        pdfContext.beginPDFPage(nil)

        do {
            pdfContext.saveGState()
            pdfContext.textMatrix = .identity
            drawingHandler(pageRect, pdfContext)
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
        let textSize = attributedString.size()
        let textOrigin = NSPoint(
            x: rect.minX + (rect.width - textSize.width) / 2,
            y: rect.minY + (rect.height - textSize.height) / 2
        )

        // draw
        attributedString.draw(in: NSRect(origin: textOrigin, size: textSize))
        return true
    }
}
