// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftRohan
import UniformTypeIdentifiers

extension UTType {
  static let latexDocument = UTType(
    exportedAs: "org.latex-project.tex", conformingTo: .plainText)
}

class Document: NSDocument {

  private(set) var content = DocumentContent()

  override init() {
    super.init()
  }

  override class var autosavesInPlace: Bool {
    return true
  }

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
    if let data = content.data() {
      return data
    }
    else {
      throw NSError(domain: Rohan.domain, code: 0, userInfo: nil)
    }
  }

  override func read(from data: Data, ofType typeName: String) throws {
    if let content = DocumentContent.from(data) {
      self.content = content

      // pass content to view controller
      if let viewController = windowControllers.first?.contentViewController
        as? ViewController
      {
        viewController.representedObject = content
      }
    }
    else {
      throw NSError(domain: Rohan.domain, code: 0, userInfo: nil)
    }
  }

  func setStyle(_ style: StyleSheet) {
    (windowControllers.first?.contentViewController as? ViewController)?.setStyle(style)
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
      Document.ensureTexExtension(savePanel.nameFieldStringValue)

    savePanel.begin { response in
      if response == .OK, var url = savePanel.url {
        // Force .tex extension if somehow missing
        if url.pathExtension.lowercased() != "tex" {
          url = url.deletingPathExtension().appendingPathExtension("tex")
        }

        // Export the document
        self.export(to: url, format: .latexDocument)
      }
    }
  }

  private static func ensureTexExtension(_ filename: String) -> String {
    var result = filename
    if !result.lowercased().hasSuffix(".tex") {
      // Remove any existing extension first
      result = URL(fileURLWithPath: result).deletingPathExtension().lastPathComponent
      result += ".tex"
    }
    return result
  }

  private func export(to url: URL, format: DocumentContent.ExportFormat) {
    do {
      guard let data = content.exportDocument(to: format)
      else {
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
