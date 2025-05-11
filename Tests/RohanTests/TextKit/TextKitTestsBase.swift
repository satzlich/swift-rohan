// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing
import _RopeModule

@testable import SwiftRohan

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

  func createDocumentManager(
    _ rootNode: RootNode, _ styleSheet: StyleSheet = StyleSheetTests.sampleStyleSheet()
  ) -> DocumentManager {
    let documentManager = DocumentManager(rootNode, styleSheet)
    documentManager.textContainer = textContainer
    documentManager.reconcileLayout(scope: .document)
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
      TextKitTestsBase.copyReplaceContents(in: range, with: content, documentManager)
    #expect("\(range1)" == expectedRange1)
    // check document
    #expect(documentManager.prettyPrint() == expectedDoc1)
    // revert
    let (range2, _) =
      TextKitTestsBase.copyReplaceContents(in: range1, with: deleted1, documentManager)
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
      TextKitTestsBase.copyReplaceCharacters(in: range, with: string, documentManager)
    #expect("\(range1)" == expectedRange1)
    // check document
    #expect(documentManager.prettyPrint() == expectedDoc1)
    // revert
    let (range2, _) =
      TextKitTestsBase.copyReplaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == expectedRange2)
    #expect(documentManager.prettyPrint() == expectedDoc2)
  }

  /// Copy and replace characters
  static func copyReplaceCharacters(
    in range: RhTextRange, with string: BigString, _ documentManager: DocumentManager
  ) -> (RhTextRange, [Node]) {
    let deleted = documentManager.mapContents(in: range, { $0.deepCopy() }) ?? []
    let result = documentManager.replaceCharacters(in: range, with: string)
    return result.map { range in (range, deleted) }.success()!
  }

  /// Copy and replace contents
  static func copyReplaceContents(
    in range: RhTextRange, with nodes: [Node]?, _ documentManager: DocumentManager
  ) -> (RhTextRange, [Node]) {
    let deleted = documentManager.mapContents(in: range, { $0.deepCopy() }) ?? []
    let result = documentManager.replaceContents(in: range, with: nodes)
    return result.map { range in (range, deleted) }.success()!
  }
}
