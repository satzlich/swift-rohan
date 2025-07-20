// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftRohan
import UniformTypeIdentifiers

final class Document: NSDocument {
  private(set) var content = DocumentContent()
  private(set) var style: StyleSheets.Record = StyleSheets.defaultRecord
  private(set) var textSize: FontSize = StyleSheets.defaultTextSize

  override init() {
    super.init()
  }

  override class var autosavesInPlace: Bool { true }

  override func makeWindowControllers() {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController =
      storyboard.instantiateController(
        withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")
      ) as! NSWindowController

    // make the window full size
    if let window = windowController.window {
      window.setFrame(NSScreen.main?.visibleFrame ?? window.frame, display: true)
    }

    self.addWindowController(windowController)

    // pass content to view controller
    if let viewController = windowController.contentViewController as? ViewController {
      viewController.representedObject = content
    }
  }

  override func data(ofType typeName: String) throws -> Data {
    let format: DocumentContent.OutputFormat =
      switch typeName {
      case UTType.latexDocument.identifier: .latex
      case UTType.rohanDocument.identifier: .rohan
      case _:
        throw NSError(
          domain: Rohan.domain, code: ErrorCode.unsupportedFormat,
          userInfo: [NSLocalizedDescriptionKey: "Unsupported document type: \(typeName)"])
      }

    if let data = content.writeData(format: format) {
      return data
    }
    else {
      throw NSError(
        domain: Rohan.domain, code: ErrorCode.writeDataFailure,
        userInfo: [
          NSLocalizedDescriptionKey: "Failed to write document content to data."
        ])
    }
  }

  override func read(from data: Data, ofType typeName: String) throws {
    if let content = DocumentContent.readFrom(data) {
      self.content = content
      // This conditional branch is called when the document is restored from previous version.
      if let contentViewController = windowControllers.first?.contentViewController,
        let viewController = contentViewController as? ViewController
      {
        viewController.representedObject = content
      }
    }
    else {
      throw NSError(domain: Rohan.domain, code: 0, userInfo: nil)
    }
  }

  internal func setStyle(_ style: StyleSheets.Record) {
    self.style = style
    self.updateStyleSheet()
  }

  internal func setTextSize(_ size: FontSize) {
    self.textSize = size
    self.updateStyleSheet()
  }

  internal func getStyleSheet() -> StyleSheet {
    self.style.provider(self.textSize)
  }

  internal func updateStyleSheet() {
    guard let contentViewController = windowControllers.first?.contentViewController,
      let viewController = contentViewController as? ViewController
    else { return }
    viewController.setStyleSheet(getStyleSheet())
  }

  // MARK: - Export

  @IBAction func exportDocument(_ sender: Any) {
    // Create a save panel configured for LaTeX export
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.latexDocument]
    savePanel.isExtensionHidden = false
    savePanel.canCreateDirectories = true

    // Set default name and ensure .tex extension
    let baseName = self.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled"
    savePanel.nameFieldStringValue = baseName

    // Ensure .tex extension is added if missing
    savePanel.nameFieldStringValue =
      Self._ensureTexExtension(savePanel.nameFieldStringValue)

    savePanel.begin { response in
      if response == .OK, var url = savePanel.url {
        // Force .tex extension if somehow missing
        if url.pathExtension.lowercased() != "tex" {
          url = url.deletingPathExtension().appendingPathExtension("tex")
        }
        // Export the document
        self._saveContent(to: url, format: .latex)
      }
    }
  }

  private static func _ensureTexExtension(_ filename: String) -> String {
    var result = filename
    if !result.lowercased().hasSuffix(".tex") {
      // Remove any existing extension first
      result = URL(fileURLWithPath: result).deletingPathExtension().lastPathComponent
      result += ".tex"
    }
    return result
  }

  private func _saveContent(to url: URL, format: DocumentContent.OutputFormat) {
    do {
      guard let data = content.writeData(format: format) else {
        throw NSError(
          domain: "ExportError", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to generate export data"])
      }
      try data.write(to: url)
    }
    catch {
      NSAlert(error: error).runModal()
    }
  }
}
