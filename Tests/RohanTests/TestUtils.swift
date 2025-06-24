// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@testable import SwiftRohan

enum TestUtils {
  static func filePath<S>(_ baseName: S) -> String?
  where S: StringProtocol {
    // get output directory from environment
    guard let baseDir = ProcessInfo().environment["RH_OUTPUT_DIR"]
    else { return nil }
    return "\(baseDir)/\(baseName)"
  }

  /// Create directory if not exists; otherwise, update its timestamp.
  static func touchDirectory(_ folderName: String) throws {
    guard !folderName.isEmpty,
      let folderPath = filePath(folderName)
    else {
      throw SatzError(.GenericInternalError, message: "invalid folder name")
    }
    let fileManager = FileManager.default
    // check if directory exists
    var isDirectory: ObjCBool = false
    if fileManager.fileExists(atPath: folderPath, isDirectory: &isDirectory) {
      if isDirectory.boolValue {
        // Update the directory's modification date by changing its attributes
        let attributes = [FileAttributeKey.modificationDate: Date()]
        try fileManager.setAttributes(attributes, ofItemAtPath: folderPath)
      }
      else {
        let message = "\(folderPath) is not a directory"
        throw SatzError(.GenericInternalError, message: message)
      }
    }
    // otherwise, create new
    else {
      let directoryURL = URL(fileURLWithPath: folderPath)
      do {
        try fileManager.createDirectory(
          at: directoryURL, withIntermediateDirectories: true, attributes: nil)
      }
      catch let error as NSError where error.code == NSFileWriteFileExistsError {
        // Ignore error if the directory already exists
      }
    }
  }

  static func outputPDF(
    folderName: String? = nil,
    _ fileName: String,
    _ pageSize: CGSize,
    _ documentManager: DocumentManager
  ) {
    // ensure layout is ready
    documentManager.reconcileLayout(scope: .document)
    func drawHandler(_ bounds: CGRect) {
      guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
      TestUtils.draw(bounds, documentManager.textLayoutManager, cgContext)
    }
    outputPDF(folderName: folderName, fileName, pageSize, drawHandler: drawHandler)
  }

  static func outputPDF(
    folderName: String? = nil,
    _ fileName: String,
    _ pageSize: CGSize,
    drawHandler: (_ bounds: CGRect) -> ()
  ) {
    // compose path
    let path = folderName != nil ? "\(folderName!)/\(fileName).pdf" : "\(fileName).pdf"
    guard let filePath = TestUtils.filePath(path) else { return }
    // draw
    DrawUtils.drawPDF(filePath: filePath, pageSize: pageSize, isFlipped: true) { bounds in
      drawHandler(bounds)
    }
  }

  static func draw(
    _ bounds: CGRect, _ textLayoutManager: NSTextLayoutManager, _ cgContext: CGContext
  ) {
    cgContext.saveGState()
    defer { cgContext.restoreGState() }

    // fill usage bounds
    cgContext.setFillColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
    cgContext.fill(textLayoutManager.usageBoundsForTextContainer)

    // draw fragments
    let startLocation = textLayoutManager.documentRange.location
    textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragment in
      // draw fragment
      fragment.draw(at: fragment.layoutFragmentFrame.origin, in: cgContext)
      #if DEBUG && DECORATE_LAYOUT_FRAGMENT
      let frame = fragment.layoutFragmentFrame
      cgContext.setStrokeColor(NSColor.systemOrange.cgColor)
      cgContext.setLineWidth(0.5)
      cgContext.stroke(frame)
      // draw coordinate
      cgContext.saveGState()
      drawString("\(frame.formatted(2))", at: CGPoint(x: frame.maxX, y: frame.midY))
      cgContext.restoreGState()
      cgContext.textMatrix = .identity
      #endif

      // draw text attachments
      for attachmentViewProvider in fragment.textAttachmentViewProviders {
        guard let attachmentView = attachmentViewProvider.view else { continue }
        let attachmentFrame = fragment.frameForTextAttachment(
          at: attachmentViewProvider.location)
        attachmentView.setFrameOrigin(attachmentFrame.origin)

        cgContext.saveGState()
        cgContext.translateBy(
          x: fragment.layoutFragmentFrame.origin.x,
          y: fragment.layoutFragmentFrame.origin.y)
        cgContext.translateBy(x: attachmentFrame.origin.x, y: attachmentFrame.origin.y)
        // NOTE: important to negate
        cgContext.translateBy(
          x: -attachmentView.bounds.origin.x, y: -attachmentView.bounds.origin.y)
        attachmentView.draw(.infinite)
        cgContext.restoreGState()
      }
      return true  // continue
    }
  }

  static func drawString(_ string: String, at point: CGPoint) {
    let font = NSFont.systemFont(ofSize: 3)
    let attributes: Dictionary<NSAttributedString.Key, Any> = [
      .font: font,
      .foregroundColor: NSColor.red,
    ]
    let attrString = NSAttributedString(string: string, attributes: attributes)
    attrString.draw(at: point)
  }

  static func updateLayoutLength(_ node: Node) {
    let styleSheet = StyleSheets.testingRecord.provider(12)
    let layoutContext = TextLayoutContext(styleSheet)
    layoutContext.beginEditing()
    _ = node.performLayoutForward(layoutContext, fromScratch: true)
    layoutContext.endEditing()
  }
}
