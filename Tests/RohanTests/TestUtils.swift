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

  @MainActor
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

  @MainActor
  static func draw(
    _ bounds: CGRect, _ textLayoutManager: NSTextLayoutManager, _ context: CGContext
  ) {
    context.saveGState()
    defer { context.restoreGState() }

    // fill usage bounds
    context.setFillColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
    context.fill(textLayoutManager.usageBoundsForTextContainer)

    // draw fragments
    let startLocation = textLayoutManager.documentRange.location
    textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragment in
      decorateTextLayoutFragment(fragment, context)
      drawTextLayoutFragment(fragment, in: context, withAttachmentViews: true)
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
    _ = node.performLayout(layoutContext, fromScratch: true)
    layoutContext.endEditing()
  }

  @MainActor
  static func drawTextLayoutFragment(
    _ fragment: NSTextLayoutFragment, in context: CGContext, withAttachmentViews: Bool
  ) {
    context.saveGState()
    let fragmentFrame = fragment.layoutFragmentFrame
    context.translateBy(x: fragmentFrame.origin.x, y: fragmentFrame.origin.y)
    fragment.draw(at: .zero, in: context)
    if withAttachmentViews {
      drawAttachmentViews(for: fragment, in: context)
    }
    context.restoreGState()
  }

  @MainActor
  static func drawAttachmentViews(
    for fragment: NSTextLayoutFragment, in context: CGContext
  ) {
    for attachmentViewProvider in fragment.textAttachmentViewProviders {
      guard let attachmentView = attachmentViewProvider.view else { continue }

      let frame = fragment.frameForTextAttachment(at: attachmentViewProvider.location)
      let bounds = attachmentView.bounds

      context.saveGState()
      context.translateBy(
        x: frame.origin.x - bounds.origin.x,
        y: frame.origin.y - bounds.origin.y)
      attachmentView.layer?.render(in: context)
      context.restoreGState()
    }
  }

  @MainActor
  static func decorateTextLayoutFragment(
    _ fragment: NSTextLayoutFragment, _ context: CGContext
  ) {
    let frame = fragment.layoutFragmentFrame
    context.setStrokeColor(NSColor.systemOrange.cgColor)
    context.setLineWidth(0.5)
    context.stroke(frame)
    // draw coordinate
    context.saveGState()
    drawString("\(frame.formatted(2))", at: CGPoint(x: frame.maxX, y: frame.midY))
    context.textMatrix = .identity
    context.restoreGState()
  }
}
