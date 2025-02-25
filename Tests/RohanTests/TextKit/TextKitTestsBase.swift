// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@testable import Rohan

class TextKitTestsBase {
  private let folderName: String
  private let textContainer: NSTextContainer
  private let pageSize: CGSize

  init(createFolder: Bool) throws {
    self.folderName = String("\(type(of: self))")
    if createFolder {
      try TestUtils.touchDirectory(folderName)
    }
    self.textContainer = NSTextContainer(size: CGSize(width: 250, height: 0))
    self.pageSize = CGSize(width: 300, height: 300)
  }

  func createDocumentManager(_ rootNode: RootNode) -> DocumentManager {
    let documentManager = DocumentManager(StyleSheetTests.sampleStyleSheet(), rootNode)
    documentManager.textContainer = textContainer
    documentManager.ensureLayout(delayed: false)
    return documentManager
  }

  func outputPDF(_ fileName: String, _ documentManager: DocumentManager) {
    TestUtils.outputPDF(folderName: folderName, fileName, pageSize, documentManager)
  }

  func outputPDF(_ fileName: String, drawHandler: (_ bounds: CGRect) -> ()) {
    TestUtils.outputPDF(folderName: folderName, fileName, pageSize, drawHandler: drawHandler)
  }
}
