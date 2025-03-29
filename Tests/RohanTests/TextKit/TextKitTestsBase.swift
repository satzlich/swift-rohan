// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing
import _RopeModule

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
    documentManager.reconcileLayout(viewportOnly: false)
    return documentManager
  }

  func outputPDF(_ fileName: String, _ documentManager: DocumentManager) {
    TestUtils.outputPDF(folderName: folderName, fileName, pageSize, documentManager)
  }

  func outputPDF(_ fileName: String, drawHandler: (_ bounds: CGRect) -> ()) {
    TestUtils.outputPDF(
      folderName: folderName, fileName, pageSize, drawHandler: drawHandler)
  }

  func testRoundTrip(
    _ range: RhTextRange,
    _ content: [Node]?,
    _ documentManager: DocumentManager,
    range1 expectedRange1: String,
    doc1 expectedDoc1: String,
    range2 expectedRange2: String
  ) {
    let expectedDoc2 = documentManager.prettyPrint()
    // replace
    let (range1, deleted1) =
      DMUtils.replaceContents(in: range, with: content, documentManager)
    #expect("\(range1)" == expectedRange1)
    // check document
    #expect(documentManager.prettyPrint() == expectedDoc1)
    // revert
    let (range2, _) = DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == expectedRange2)
    #expect(documentManager.prettyPrint() == expectedDoc2)
  }

  func testRoundTrip(
    _ range: RhTextRange,
    _ string: BigString,
    _ documentManager: DocumentManager,
    range1 expectedRange1: String,
    doc1 expectedDoc1: String,
    range2 expectedRange2: String
  ) {
    let expectedDoc2 = documentManager.prettyPrint()
    // replace
    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: string, documentManager)
    #expect("\(range1)" == expectedRange1)
    // check document
    #expect(documentManager.prettyPrint() == expectedDoc1)
    // revert
    let (range2, _) = DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == expectedRange2)
    #expect(documentManager.prettyPrint() == expectedDoc2)
  }
}
