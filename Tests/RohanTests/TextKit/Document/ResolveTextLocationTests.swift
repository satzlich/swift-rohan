import CoreGraphics
import Testing

@testable import SwiftRohan

final class ResolveTextLocationTests: TextKitTestsBase {

  init() throws {
    try super.init(createFolder: true)
  }

  @Test
  func resolveTextLocation_SimpleNode() throws {
    let documentManager = self.createDocumentManager(
      RootNode([
        EquationNode(
          .inline,
          [
            TextNode("a"),
            NamedSymbolNode(NamedSymbol.lookup("beta")!),
            TextNode("c"),
            ApplyNode(MathTemplate.operatorname, [[]])!,
          ])
      ]))

    guard let location0 = documentManager.resolveTextLocation(with: CGPoint(x: 13, y: 5)),
      let location1 = documentManager.resolveTextLocation(with: CGPoint(x: 15, y: 5)),
      let location2 = documentManager.resolveTextLocation(with: CGPoint(x: 37.55, y: 5))
    else {
      Issue.record("Failed to resolve text location")
      return
    }

    #expect("\(location0.value)" == "[↓0,nuc,↓0]:1")
    #expect("\(location1.value)" == "[↓0,nuc,↓2]:0")
    #expect("\(location2.value)" == "[↓0,nuc,↓3,⇒0]:0")
  }

  @Test @MainActor
  func resolveTextLocation_MultilineNode_EquationNode() {
    let rootNode = RootNode([
      ParagraphNode([
        EquationNode(.equation, [TextNode("a+b")])
      ]),
      ParagraphNode([
        MultilineNode(
          .multline,
          [
            [ContentNode([TextNode("a")])],
            [ContentNode()],
            [ContentNode([TextNode("c")])],
          ])
      ]),

    ])
    let documentManager = self.createDocumentManager(rootNode, usingPageProperty: true)
    let navigation = documentManager.textSelectionNavigation
    outputPDF(String(#function.dropLast(2)), documentManager)

    do {
      let point = CGPoint(x: 5, y: 5)
      let result = navigation.textSelection(
        interactingAt: point, anchors: nil, modifiers: [], selecting: false,
        bounds: .infinite)
      guard let result = result else {
        Issue.record("No result found")
        return
      }
      let expected = "([↓0,↓0,nuc,↓0]:0, downstream)"
      #expect("\(result)" == expected)
    }

    do {
      let point = CGPoint(x: 10000, y: 5)  // use very large x to avoid hitting any node.
      let result = navigation.textSelection(
        interactingAt: point, anchors: nil, modifiers: [], selecting: false,
        bounds: .infinite)
      guard let result = result else {
        Issue.record("No result found")
        return
      }
      let expected = "([↓0]:1, upstream)"
      #expect("\(result)" == expected)
    }

    // trigger trialing cursor correction.
    do {
      let location = TextLocation.parse("[↓0]:1")!
      let rect = documentManager.primaryInsertionIndicatorFrame(at: location, .upstream)
      guard let rect = rect else {
        Issue.record("No rect found")
        return
      }
      #expect(rect.formatted(2) == "(448.54, 0.00, 0.00, 17.00)")
    }

    do {
      let point = CGPoint(x: 5, y: 20)
      let result = navigation.textSelection(
        interactingAt: point, anchors: nil, modifiers: [], selecting: false,
        bounds: .infinite)
      guard let result = result else {
        Issue.record("No result found")
        return
      }
      let expected = "([↓1,↓0,(0,0),↓0]:0, downstream)"
      #expect("\(result)" == expected)
    }

    do {
      let point = CGPoint(x: 10000, y: 20)  // use very large x to avoid hitting any node.
      let result = navigation.textSelection(
        interactingAt: point, anchors: nil, modifiers: [], selecting: false,
        bounds: .infinite)
      guard let result = result else {
        Issue.record("No result found")
        return
      }
      let expected = "([↓1]:1, upstream)"
      #expect("\(result)" == expected)
    }

    do {
      let location = TextLocation.parse("[↓1]:1")!
      let rect = documentManager.primaryInsertionIndicatorFrame(at: location, .upstream)
      guard let rect = rect else {
        Issue.record("No rect found")
        return
      }
      #expect(rect.formatted(2) == "(448.54, 17.00, 0.00, 47.88)")
    }
  }
}
