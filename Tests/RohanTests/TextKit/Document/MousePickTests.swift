// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

final class MousePickTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
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
              nucleus: [
                TextNode("c+"),
                FractionNode(numerator: [TextNode("x+1")], denominator: [TextNode("y+1")]),
                TextNode("+"),
                FractionNode(numerator: [], denominator: [TextNode("z+1")]),
                TextNode("-"),
                FractionNode(
                  numerator: [
                    FractionNode(
                      numerator: [TextNode("a+b+c")],
                      denominator: [TextNode("n+m")])
                  ],
                  denominator: [TextNode("x+y+z")]),
              ]
            ),
          ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let documentManager = createDocumentManager()

    let testCases: [(CGPoint, String)] = [
      (CGPoint(x: 27.316, y: 10.281), "[0↓,0↓]:3"),
      (CGPoint(x: 63.992, y: 20.457), "[0↓,0↓]:45"),
      (CGPoint(x: 9.465, y: 51.301), "[1↓,0↓]:0"),
      (CGPoint(x: 29.984, y: 53.391), "[1↓,0↓]:2"),
      (CGPoint(x: 44.242, y: 51.891), "[1↓,1↓,nucleus,0↓]:1"),
      (CGPoint(x: 72.520, y: 46.965), "[1↓,1↓,nucleus,1↓,numerator,0↓]:0"),
      (CGPoint(x: 94.852, y: 46.016), "[1↓,1↓,nucleus,1↓,numerator,0↓]:3"),
      (CGPoint(x: 78.383, y: 61.832), "[1↓,1↓,nucleus,1↓,denominator,0↓]:1"),
      (CGPoint(x: 86.891, y: 61.832), "[1↓,1↓,nucleus,1↓,denominator,0↓]:2"),
      (CGPoint(x: 134.547, y: 43.723), "[1↓,1↓,nucleus,3↓,numerator]:0"),
      (CGPoint(x: 126.379, y: 63.109), "[1↓,1↓,nucleus,3↓,denominator,0↓]:0"),
      (CGPoint(x: 140.328, y: 63.109), "[1↓,1↓,nucleus,3↓,denominator,0↓]:2"),
      (CGPoint(x: 191.441, y: 39.176), "[1↓,1↓,nucleus,5↓,numerator,0↓,numerator,0↓]:1"),
      (CGPoint(x: 204.789, y: 36.629), "[1↓,1↓,nucleus,5↓,numerator,0↓,numerator,0↓]:3"),
      (CGPoint(x: 200.859, y: 49.258), "[1↓,1↓,nucleus,5↓,numerator,0↓,denominator,0↓]:2"),
      (CGPoint(x: 193.832, y: 63.016), "[1↓,1↓,nucleus,5↓,denominator,0↓]:2"),
      (CGPoint(x: 215.676, y: 60.594), "[1↓,1↓,nucleus,5↓,denominator,0↓]:4"),
    ]
    for (i, (point, expected)) in testCases.enumerated() {
      let result = documentManager.resolveTextLocation(interactingAt: point)
      #expect(result != nil)
      #expect(result!.description == expected, "i=\(i)")
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
            nucleus: [
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
              nucleus: [
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
            nucleus: [
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
      (CGPoint(x: 181.41796875, y: 45.83984375), "[1↓,1↓,nucleus]:0"),
      (CGPoint(x: 201.55078125, y: 46.3828125), "[1↓,1↓,nucleus,1↓]:0"),
      (CGPoint(x: 123.4375, y: 65.34765625), "[1↓,3↓,0⇒,0↓]:3"),
      (CGPoint(x: 15.1875, y: 81.30078125), "[1↓,3↓,0⇒,0↓]:1"),
      (CGPoint(x: 202.86328125, y: 62.7578125), "[1↓,3↓,1⇒,0↓]:2"),
      //
      (CGPoint(x: 186.4140625, y: 98.046875), "[2↓,1↓,0⇒,0↓,0⇒,0↓]:1"),
      (CGPoint(x: 232.609375, y: 98.046875), "[2↓,1↓,0⇒,0↓,0⇒,0↓]:2"),
      (CGPoint(x: 41.234375, y: 114.82421875), "[2↓,1↓,0⇒,0↓,0⇒,0↓]:2"),
      (CGPoint(x: 80.1015625, y: 115.30859375), "[2↓,1↓,0⇒,0↓,0⇒,0↓]:1"),
      (CGPoint(x: 176.0234375, y: 99.2421875), "[2↓,1↓,0⇒]:0"),
      (CGPoint(x: 97.140625, y: 116.515625), "[2↓,1↓,0⇒]:1"),
      //
      (CGPoint(x: 51.90234375, y: 150.5859375), "[3↓,0↓,nucleus,1↓,0⇒,0↓]:0"),
      (CGPoint(x: 72.02734375, y: 151.66796875), "[3↓,0↓,nucleus,1↓,1⇒,0↓]:1"),
      (CGPoint(x: 62.9375, y: 135.56640625), "[3↓,0↓,nucleus,1↓,0⇒,0↓]:0"),
      (CGPoint(x: 65.5546875, y: 124.5390625), "[3↓,0↓,nucleus,1↓,1⇒,0↓]:1"),
      //
      (CGPoint(x: 34.4296875, y: 167.890625), "[4↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1"),
      (CGPoint(x: 77.91015625, y: 166.53125), "[4↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:2"),
      (CGPoint(x: 118.7109375, y: 166.48046875), "[4↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1"),
      (CGPoint(x: 162.1328125, y: 166.8359375), "[4↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:2"),
    ]
    for (i, (point, expected)) in testCases.enumerated() {
      let result = documentManager.resolveTextLocation(interactingAt: point)
      #expect(result != nil)
      #expect(result!.description == expected, "i=\(i)")
    }
  }
}
