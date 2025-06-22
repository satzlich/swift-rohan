// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Testing

@testable import SwiftRohan

final class ItemListNodeTests: TextKitTestsBase {

  init() throws {
    try super.init(createFolder: true)
  }

  private func _testingExample() -> DocumentManager {
    let rootNode = RootNode([
      ItemListNode(
        .itemize,
        [
          ParagraphNode([TextNode("abc")]),
          ParagraphNode([TextNode("def")]),
        ]),
      ItemListNode(
        .enumerate,
        [
          ParagraphNode([TextNode("ghi")]),
          ParagraphNode([TextNode("jkl")]),
        ]),
      // empty item list
      ItemListNode(.itemize, []),
    ])
    let documentManager = createDocumentManager(rootNode)

    return documentManager
  }

  @Test
  func layout() {
    let documentManager = _testingExample()
    outputPDF(#function, documentManager)
  }

  @Test
  func performLayout() {  // Simple and Full variant.
    let documentManager = _testingExample()

    // make an item dirty
    do {
      let location = TextLocation.parse("[↓0,↓1,↓0]:2")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "2")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(#function + "_1", documentManager)
    }
    // delete portion of item list
    do {
      let location = TextLocation.parse("[↓0,↓0,↓0]:3")!
      let end = TextLocation.parse("[↓0,↓1,↓0]:3")!
      let range = RhTextRange(location, end)!
      let result = documentManager.replaceCharacters(in: range, with: "3")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(#function + "_2", documentManager)
    }
    // add paragraph
    do {
      let location = TextLocation.parse("[↓0]:1")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "4")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(#function + "_3", documentManager)
    }
    // remove all items
    do {
      let location = TextLocation.parse("[↓0]:0")!
      let end = TextLocation.parse("[↓0]:2")!
      let range = RhTextRange(location, end)!
      let result = documentManager.replaceCharacters(in: range, with: "")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(#function + "_4", documentManager)
    }
    // insert into an empty item list
    do {
      let location = TextLocation.parse("[↓0]:0")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "5")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(#function + "_5", documentManager)
    }
  }

  @Test
  func resolveTextLocation() {  // with point
    let documentManager = _testingExample()
    do {
      let location1 = documentManager.resolveTextLocation(with: CGPoint(x: 10, y: 5))
      #expect("\(location1!.value)" == "[↓0,↓0,↓0]:0")
      let location2 = documentManager.resolveTextLocation(with: CGPoint(x: 43, y: 5))
      #expect("\(location2!.value)" == "[↓0,↓0,↓0]:1")
      let location3 = documentManager.resolveTextLocation(with: CGPoint(x: 65, y: 5))
      #expect("\(location3!.value)" == "[↓0,↓0,↓0]:3")
    }
    do {
      let location1 = documentManager.resolveTextLocation(with: CGPoint(x: 43, y: 20))
      #expect("\(location1!.value)" == "[↓0,↓1,↓0]:1")
    }
    do {
      let location1 = documentManager.resolveTextLocation(with: CGPoint(x: 45, y: 70))
      #expect("\(location1!.value)" == "[↓2]:0")
    }
  }

  @Test
  func enumerateTextSegments() {
    let documentManager = _testingExample()
    let location = TextLocation.parse("[↓0]:0")!
    let end = TextLocation.parse("[↓0]:1")!
    let range = RhTextRange(location, end)!

    var rect = CGRect.zero
    documentManager.enumerateTextSegments(in: range, type: .standard) {
      (_, frame, baseline) in
      rect = frame
      return false
    }

    #expect(rect.formatted(2) == "(35.00, 0.00, 18.34, 17.00)")
  }
}
