// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class MousePickTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: true)
  }

  @Test
  func testMousePick() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown fox jumps over the lazy dog. ")
        ]),
        HeadingNode(
          level: 1,
          [
            TextNode("H1 "),
            EquationNode(
              isBlock: false,
              nuc: [
                TextNode("c+"),
                FractionNode(
                  num: [TextNode("x+1")], denom: [TextNode("y+1")]),
                TextNode("+"),
                FractionNode(num: [], denom: [TextNode("z+1")]),
                TextNode("-"),
                FractionNode(
                  num: [
                    FractionNode(
                      num: [TextNode("a+b+c")],
                      denom: [TextNode("n+m")])
                  ],
                  denom: [TextNode("x+y+z")]),
              ]
            ),
          ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let documentManager = createDocumentManager()

    let testCases: [(CGPoint, String)] = [
      (CGPoint(x: 27.31, y: 10.28), "[↓0,↓0]:3"),
      (CGPoint(x: 63.99, y: 20.45), "[↓0,↓0]:45"),
      (CGPoint(x: 9.46, y: 51.30), "[↓1,↓0]:0"),
      (CGPoint(x: 29.98, y: 53.39), "[↓1,↓0]:2"),
      (CGPoint(x: 44.24, y: 51.89), "[↓1,↓1,nuc,↓0]:1"),
      (CGPoint(x: 72.52, y: 46.96), "[↓1,↓1,nuc,↓1,num,↓0]:0"),
      (CGPoint(x: 94.85, y: 46.01), "[↓1,↓1,nuc,↓1,num,↓0]:3"),
      (CGPoint(x: 78.38, y: 61.83), "[↓1,↓1,nuc,↓1,denom,↓0]:1"),
      (CGPoint(x: 86.89, y: 61.83), "[↓1,↓1,nuc,↓1,denom,↓0]:2"),
      (CGPoint(x: 134.54, y: 43.72), "[↓1,↓1,nuc,↓3,num]:0"),
      (CGPoint(x: 126.37, y: 63.10), "[↓1,↓1,nuc,↓3,denom,↓0]:0"),
      (CGPoint(x: 140.32, y: 63.10), "[↓1,↓1,nuc,↓3,denom,↓0]:2"),
      (CGPoint(x: 191.44, y: 39.17), "[↓1,↓1,nuc,↓5,num,↓0,num,↓0]:1"),
      (CGPoint(x: 204.78, y: 36.62), "[↓1,↓1,nuc,↓5,num,↓0,num,↓0]:3"),
      (CGPoint(x: 200.85, y: 49.25), "[↓1,↓1,nuc,↓5,num,↓0,denom,↓0]:2"),
      (CGPoint(x: 193.83, y: 63.01), "[↓1,↓1,nuc,↓5,denom,↓0]:2"),
      (CGPoint(x: 215.67, y: 60.59), "[↓1,↓1,nuc,↓5,denom,↓0]:4"),
    ]
    for (i, (point, expected)) in testCases.enumerated() {
      let result = resolveTextLocation(with: point, documentManager)
      #expect(result != nil)
      guard let result else { return }
      #expect(result.value.description == expected, "i=\(i)")
    }
  }

  @Test
  func testMousePick_ApplyNode() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown fox jumps over the lazy dog.")
        ]),
        // #1 paragraph: test apply node
        ParagraphNode([
          TextNode("Newton's second law of motion: "),
          EquationNode(
            isBlock: false,
            nuc: [
              ApplyNode(CompiledSamples.newtonsLaw, [])!,
              TextNode("."),
            ]),
          TextNode(" Here is another sample: "),
          ApplyNode(
            CompiledSamples.philipFox,
            [
              [TextNode("Philip")],
              [TextNode("Fox")],
            ])!,
        ]),
        // #2 paragraph: test nested apply node
        ParagraphNode([
          TextNode("Sample of nested apply nodes: "),
          ApplyNode(
            CompiledSamples.doubleText,
            [
              [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
            ])!,
        ]),
        // #3
        HeadingNode(
          level: 1,
          [
            EquationNode(
              isBlock: false,
              nuc: [
                TextNode("m+"),
                ApplyNode(
                  CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
                TextNode("+n"),
              ])
          ]),
        // #4
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nuc: [
              ApplyNode(
                CompiledSamples.bifun,
                [
                  [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
                ])!
            ])
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let documentManager = createDocumentManager()

    let testCases: [(CGPoint, String)] = [
      (CGPoint(x: 181.41, y: 45.84), "[↓1,↓1,nuc]:0"),
      (CGPoint(x: 201.55, y: 46.38), "[↓1,↓1,nuc,↓1]:0"),
      (CGPoint(x: 123.43, y: 65.34), "[↓1,↓3,⇒0,↓0]:3"),
      (CGPoint(x: 15.18, y: 81.30), "[↓1,↓3,⇒0,↓0]:1"),
      (CGPoint(x: 202.86, y: 62.75), "[↓1,↓3,⇒1,↓0]:2"),
      //
      (CGPoint(x: 186.41, y: 98.04), "[↓2,↓1,⇒0,↓0,⇒0,↓0]:1"),
      (CGPoint(x: 232.60, y: 98.04), "[↓2,↓1,⇒0,↓0,⇒0,↓0]:2"),
      (CGPoint(x: 41.23, y: 114.82), "[↓2,↓1,⇒0,↓0,⇒0,↓0]:2"),
      (CGPoint(x: 80.10, y: 115.30), "[↓2,↓1,⇒0,↓0,⇒0,↓0]:1"),
      (CGPoint(x: 176.02, y: 99.24), "[↓2,↓1,⇒0]:0"),
      (CGPoint(x: 97.14, y: 116.51), "[↓2,↓1,⇒0]:1"),
      //
      (CGPoint(x: 51.90, y: 150.58), "[↓3,↓0,nuc,↓1,⇒0,↓0]:0"),
      (CGPoint(x: 72.02, y: 151.66), "[↓3,↓0,nuc,↓1,⇒1,↓0]:1"),
      (CGPoint(x: 62.93, y: 135.56), "[↓3,↓0,nuc,↓1,⇒0,↓0]:0"),
      (CGPoint(x: 65.55, y: 124.53), "[↓3,↓0,nuc,↓1,⇒1,↓0]:1"),
      //
      (CGPoint(x: 34.42, y: 167.89), "[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1"),
      (CGPoint(x: 77.91, y: 166.53), "[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:2"),
      (CGPoint(x: 118.71, y: 166.48), "[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1"),
      (CGPoint(x: 162.13, y: 166.83), "[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:2"),
    ]
    for (i, (point, expected)) in testCases.enumerated() {
      let result = resolveTextLocation(with: point, documentManager)
      #expect(result != nil)
      guard let result else { return }
      #expect(result.value.description == expected, "i=\(i)")
    }
  }

  @Test
  func regressMousePick_LineSeparator() {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown \u{2028}")
        ]),
        ParagraphNode([
          TextNode("The quick brown ")
        ]),
        ParagraphNode([]),
        ParagraphNode([
          TextNode("The quick brown ")
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let documentManager = createDocumentManager()

    let testCases: [(CGPoint, String)] = [
      (CGPoint(x: 58.90, y: 29.40), "[↓0,↓0]:17"),
      (CGPoint(x: 65.18, y: 55.75), "[↓2]:0"),
    ]

    for (i, (point, expected)) in testCases.enumerated() {
      let result = resolveTextLocation(with: point, documentManager)
      #expect(result != nil)
      guard let result else { return }
      #expect(result.value.description == expected, "i=\(i)")
    }
  }

  @Test
  func testMouseDrag() {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown \u{2028}")
        ]),
        ParagraphNode([
          TextNode("The quick brown ")
        ]),
        ParagraphNode([]),
        ParagraphNode([
          TextNode("The quick brown ")
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let documentManager = createDocumentManager()

    let location0 = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      return TextLocation(path, "The ".length)
    }()
    let location1 = {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      return TextLocation(path, "The ".length)
    }()

    let testCases: [(TextLocation, CGPoint, String)] = [
      (
        location0, CGPoint(x: 58.90, y: 29.40),
        "(anchor: [↓0,↓0]:4, focus: [↓0,↓0]:17, reversed: false, affinity: downstream)"
      ),
      (
        location1, CGPoint(x: 65.18, y: 55.75),
        "(anchor: [↓1,↓0]:4, focus: [↓2]:0, reversed: false, affinity: upstream)"
      ),
    ]

    for (i, (location, point, expected)) in testCases.enumerated() {
      let result = resolveTextRange(with: point, location, documentManager)
      guard let result
      else {
        Issue.record("Failed to resolve text range")
        return
      }
      #expect(result.description == expected, "i=\(i)")
    }
  }

  @Test
  func regressMouseDrag() {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)
    outputPDF(#function, documentManager)

    let point = CGPoint(x: 255, y: 5)
    guard
      let selection = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point, anchors: nil, modifiers: [], selecting: false,
        bounds: .infinite),
      let second = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point, anchors: selection, modifiers: [], selecting: true,
        bounds: .infinite)
    else {
      Issue.record("Failed to resolve text selection")
      return
    }

    #expect(
      second.description == """
        (location: [↓0,↓0]:40, affinity: upstream)
        """)
  }

  private func resolveTextLocation(
    with point: CGPoint, _ documentManager: DocumentManager
  ) -> AffineLocation? {
    if let selection = documentManager.textSelectionNavigation.textSelection(
      interactingAt: point, anchors: nil, modifiers: [], selecting: false,
      bounds: .infinite)
    {
      return AffineLocation(selection.anchor, selection.affinity)
    }
    return nil
  }

  private func resolveTextRange(
    with point: CGPoint, _ anchor: TextLocation, _ documentManager: DocumentManager
  ) -> RhTextSelection? {
    let anchorSelection = RhTextSelection(anchor)
    return documentManager.textSelectionNavigation.textSelection(
      interactingAt: point, anchors: anchorSelection, modifiers: [], selecting: true,
      bounds: .infinite)
  }
}
