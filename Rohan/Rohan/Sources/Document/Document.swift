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

  final override class var autosavesInPlace: Bool { true }

  final override func makeWindowControllers() {
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

    // If the document is new (fileURL is nil), immediately show the save dialog.
    if self.fileURL == nil {
      _showSavePanel(format: .rohan, for: .saveOperation)
    }
  }

  final override func data(ofType typeName: String) throws -> Data {
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

  final override func read(from data: Data, ofType typeName: String) throws {
    guard typeName == UTType.rohanDocument.identifier,
      let content = DocumentContent.readFrom(data)
    else {
      throw NSError(
        domain: Rohan.domain, code: ErrorCode.unsupportedFormat,
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

  @IBAction
  final func exportDocument(_ sender: Any) {
    _showSavePanel(format: .latex, for: .saveAsOperation)
  }

  /// Shows a save panel to save the document in the specified format.
  /// - Parameters:
  ///   - format: The format to save the document in.
  ///   - saveOperationType: The type of save operation (e.g., save, save as).
  private final func _showSavePanel(
    format: DocumentContent.OutputFormat,
    for saveOperationType: NSDocument.SaveOperationType
  ) {
    let contentType = format.toUTType()
    let fileExtension = format.fileExtension

    // Create a save panel with the specified content type.
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [contentType]
    savePanel.isExtensionHidden = false
    savePanel.canCreateDirectories = true

    // Set default name with extension.
    let baseName = self.fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled"
    savePanel.nameFieldStringValue =
      URL(fileURLWithPath: baseName)
      .deletingPathExtension()
      .lastPathComponent + "." + fileExtension

    savePanel.begin { response in
      if response == .OK, var url = savePanel.url {
        // Ensure the file has the correct extension
        if url.pathExtension.lowercased() != fileExtension {
          url = url.deletingPathExtension().appendingPathExtension(fileExtension)
        }
        self.save(to: url, ofType: contentType.identifier, for: saveOperationType) {
          error in
          if let error = error {
            NSLog("Failed to save document: \(error)")
            NSAlert(error: error).runModal()
          }
        }
      }
    }
  }

  // MARK: - Style Management

  /// Sets the style and updates the view controller with the new style sheet.
  final func setStyle(_ style: StyleSheets.Record) {
    self.style = style
    self._updateStyleSheet()
  }

  /// Sets the text size and updates the view controller with the new style sheet.
  final func setTextSize(_ size: FontSize) {
    self.textSize = size
    self._updateStyleSheet()
  }

  /// Returns the current style sheet based on the selected style and text size.
  final func getStyleSheet() -> StyleSheet {
    self.style.provider(self.textSize)
  }

  /// Updates the style sheet in the view controller.
  private final func _updateStyleSheet() {
    guard let contentViewController = windowControllers.first?.contentViewController,
      let viewController = contentViewController as? ViewController
    else { return }
    viewController.setStyleSheet(getStyleSheet())
  }
}
