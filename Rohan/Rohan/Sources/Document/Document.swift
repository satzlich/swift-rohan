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
    guard let format = DocumentContent.OutputFormat.fromUTType(typeName) else {
      throw NSError(
        domain: Rohan.domain, code: ErrorCode.unsupportedFormat,
        userInfo: [NSLocalizedDescriptionKey: "Unsupported document type: \(typeName)"])
    }

    guard let data = content.writeData(format: format) else {
      throw NSError(
        domain: Rohan.domain, code: ErrorCode.writeDataFailure,
        userInfo: [
          NSLocalizedDescriptionKey: "Failed to write document content to data."
        ])
    }

    return data
  }

  override func read(from data: Data, ofType typeName: String) throws {
    guard typeName == UTType.rohanDocument.identifier,
      let content = DocumentContent.readFrom(data)
    else {
      throw NSError(
        domain: Rohan.domain, code: 0,
        userInfo: [
          NSLocalizedDescriptionKey: "Unsupported document type: \(typeName)"
        ])
    }

    self.content = content

    // This conditional branch is called when the document is restored from previous version.
    if let contentViewController = windowControllers.first?.contentViewController,
      let viewController = contentViewController as? ViewController
    {
      viewController.representedObject = content
    }
  }

  /// Sets the style and updates the view controller with the new style sheet.
  func setStyle(_ style: StyleSheets.Record) {
    self.style = style
    self._updateStyleSheet()
  }

  /// Sets the text size and updates the view controller with the new style sheet.
  func setTextSize(_ size: FontSize) {
    self.textSize = size
    self._updateStyleSheet()
  }

  /// Returns the current style sheet based on the selected style and text size.
  func getStyleSheet() -> StyleSheet {
    self.style.provider(self.textSize)
  }

  /// Updates the style sheet in the view controller.
  private func _updateStyleSheet() {
    guard let contentViewController = windowControllers.first?.contentViewController,
      let viewController = contentViewController as? ViewController
    else { return }
    viewController.setStyleSheet(getStyleSheet())
  }

  @IBAction func exportDocument(_ sender: Any) {
    showSavePanel(.latex)
  }

  func showSavePanel(_ format: DocumentContent.OutputFormat) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [format.toUTType()]
    savePanel.isExtensionHidden = false
    savePanel.canCreateDirectories = true

    // Set default name
    let baseName = self.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled"
    savePanel.nameFieldStringValue = baseName

    // Ensure the filename has the correct extension
    let fileExtension = format.fileExtension
    savePanel.nameFieldStringValue =
      Self.rectifyFileName(savePanel.nameFieldStringValue, fileExtension: fileExtension)

    savePanel.begin { response in
      if response == .OK, var url = savePanel.url {
        if url.pathExtension.lowercased() != fileExtension {
          url = url.deletingPathExtension().appendingPathExtension(fileExtension)
        }
        self.saveContent(to: url, format: .latex)
      }
    }
  }

  /// Ensures that the filename ends with the specified extension.
  private static func rectifyFileName(
    _ fileName: String, fileExtension: String
  ) -> String {
    precondition(fileExtension.first != ".")
    if fileName.lowercased().hasSuffix(fileExtension) {
      return fileName
    }
    else {
      return URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        + "." + fileExtension
    }
  }

  /// Saves the content to the specified URL in the given format. If the content cannot be
  /// serialized, an error alert is shown.
  private func saveContent(to url: URL, format: DocumentContent.OutputFormat) {
    do {
      guard let data = content.writeData(format: format) else {
        throw NSError(
          domain: Rohan.domain, code: ErrorCode.writeDataFailure,
          userInfo: [
            NSLocalizedDescriptionKey:
              "Unable to serialise document content in \(format) format."
          ])
      }
      try data.write(to: url)
    }
    catch {
      NSAlert(error: error).runModal()
    }
  }
}
