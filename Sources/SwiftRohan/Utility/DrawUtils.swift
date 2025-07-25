import AppKit
import Foundation

public enum DrawUtils {

  /// Draw a PDF file with the specified page size.
  ///
  /// - Parameters:
  ///   - filePath: The path of the PDF file.
  ///   - pageSize: The size of the PDF page.
  ///   - isFlipped: Whether a flipped coordinate system should be used.
  ///   - drawingHandler: The drawing handler.
  /// - Returns: true if the drawing is successful; false otherwise.
  @discardableResult
  public static func drawPDF(
    filePath: String, pageSize: NSSize, isFlipped: Bool = false,
    drawingHandler: (NSRect) -> Void
  ) -> Bool {
    // create PDF context
    let filePath = URL(fileURLWithPath: filePath)
    var pageRect = NSRect(origin: .zero, size: pageSize)
    guard let pdfContext = CGContext(filePath as CFURL, mediaBox: &pageRect, nil)
    else { return false }

    // switch context
    let previousContext = NSGraphicsContext.current
    NSGraphicsContext.current = .init(cgContext: pdfContext, flipped: isFlipped)
    // restore context on exit
    defer { NSGraphicsContext.current = previousContext }

    // begin page
    pdfContext.beginPDFPage(nil)
    // perform drawing
    do {
      pdfContext.saveGState()
      if isFlipped {
        pdfContext.translateBy(x: 0, y: pageSize.height)
        pdfContext.scaleBy(x: 1, y: -1)
      }
      drawingHandler(pageRect)
      pdfContext.restoreGState()
    }
    // end page and close PDF
    pdfContext.endPDFPage()
    pdfContext.closePDF()

    return true
  }
}
