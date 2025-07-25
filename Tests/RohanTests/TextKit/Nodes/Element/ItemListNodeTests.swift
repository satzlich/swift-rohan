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

  @MainActor
  @Test
  func layout() {
    let documentManager = _testingExample()
    outputPDF(#function, documentManager)
  }

  @MainActor
  @Test("performLayout", arguments: [0, 1])
  func performLayout(_ k: Int) {  // Simple and Full variant.
    let documentManager = _testingExample()

    let prefix = #function.prefix(while: { $0.isLetter })
    func fileName(_ n: Int) -> String {
      "\(prefix)_\(k)_\(n)"
    }

    // make an item dirty
    do {
      let location = TextLocation.parse("[↓\(k),↓1,↓0]:2")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "2")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(fileName(1), documentManager)
    }
    // delete portion of item list
    do {
      let location = TextLocation.parse("[↓\(k),↓0,↓0]:3")!
      let end = TextLocation.parse("[↓\(k),↓1,↓0]:3")!
      let range = RhTextRange(location, end)!
      let result = documentManager.replaceCharacters(in: range, with: "3")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(fileName(2), documentManager)
    }
    // add paragraph
    do {
      let location = TextLocation.parse("[↓\(k)]:1")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "4")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(fileName(3), documentManager)
    }
    // remove all items
    do {
      let location = TextLocation.parse("[↓\(k)]:0")!
      let end = TextLocation.parse("[↓\(k)]:2")!
      let range = RhTextRange(location, end)!
      let result = documentManager.replaceCharacters(in: range, with: "")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(fileName(4), documentManager)
    }
    // insert into an empty item list
    do {
      let location = TextLocation.parse("[↓\(k)]:0")!
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "5")
      #expect(result.isSuccess)
      documentManager.reconcileLayout(scope: .document)
      outputPDF(fileName(5), documentManager)
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

    do {
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

    // trigger leading cursor correction
    do {
      let location = TextLocation.parse("[]:0")!
      let end = TextLocation.parse("[]:1")!
      let range = RhTextRange(location, end)!

      var rect = CGRect.zero
      documentManager.enumerateTextSegments(in: range, type: .standard) {
        (_, frame, baseline) in
        rect = frame
        return false
      }
      #expect(rect.formatted(2) == "(5.00, 0.00, 48.34, 17.00)")
    }
  }

  @Test
  func rayshoot() {
    let documentManager = _testingExample()

    // trigger leading cursor correction
    do {
      let location = TextLocation.parse("[]:0")!
      let selection = RhTextSelection(location, affinity: .downstream)
      let result = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .down, destination: .character, extending: false)
      #expect(result != nil)
    }
  }
}
