// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

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
              [
                TextNode("c+"),
                FractionNode([TextNode("x+1")], [TextNode("y+1")]),
                TextNode("+"),
                FractionNode([], [TextNode("z+1")]),
                TextNode("-"),
                FractionNode(
                  [
                    FractionNode(
                      [TextNode("a+b+c")],
                      [TextNode("n+m")])
                  ],
                  [TextNode("x+y+z")]),
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
      (CGPoint(x: 140.328, y: 63.109), "[1↓,1↓,nucleus,3↓,denominator,0↓]:2"),
      (CGPoint(x: 126.379, y: 63.109), "[1↓,1↓,nucleus,3↓,denominator,0↓]:0"),
      (CGPoint(x: 191.441, y: 39.176), "[1↓,1↓,nucleus,5↓,numerator,0↓,numerator,0↓]:1"),
      (CGPoint(x: 204.789, y: 36.629), "[1↓,1↓,nucleus,5↓,numerator,0↓,numerator,0↓]:3"),
      (CGPoint(x: 200.859, y: 49.258), "[1↓,1↓,nucleus,5↓,numerator,0↓,denominator,0↓]:2"),
      (CGPoint(x: 193.832, y: 63.016), "[1↓,1↓,nucleus,5↓,denominator,0↓]:2"),
      (CGPoint(x: 215.676, y: 60.594), "[1↓,1↓,nucleus,5↓,denominator,0↓]:4"),
    ]
    for (point, expected) in testCases {
      let result = documentManager.getTextLocation(interactingAt: point)
      #expect(result != nil)
      #expect(result!.description == expected)
    }
  }
}
