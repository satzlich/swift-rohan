// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

final class MoveTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func testMove() {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("A"),
          EmphasisNode([TextNode("b")]),
        ]),
      ParagraphNode([
        TextNode("c"),
        EquationNode(
          isBlock: true,
          [
            TextNode("d+"),
            FractionNode(
              [
                TextNode("e")
              ],
              [
                TextNode("f")
              ]),
          ]),
        TextNode("g"),
      ]),
      ParagraphNode([
        ApplyNode(
          TemplateSample.doubleText,
          [
            [ApplyNode(TemplateSample.doubleText, [[TextNode("h")]])!]
          ])!,
        EquationNode(
          isBlock: true,
          [
            TextNode("i"),
            ApplyNode(
              TemplateSample.bifun,
              [
                [ApplyNode(TemplateSample.bifun, [[TextNode("j")]])!]
              ])!,
          ]),
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    do {
      var locations = [TextLocation]()
      var location = documentManager.documentRange.location
      while true {
        locations.append(location)
        guard let newLocation = documentManager.destinationLocation(for: location, .forward),
          location != newLocation
        else { break }
        location = newLocation
      }

      let expected: [String] = [
        "[]:0",
        "[0↓,0↓]:0",
        "[0↓,0↓]:1",
        "[0↓,1↓,0↓]:0",
        "[0↓,1↓,0↓]:1",
        "[0↓]:2",
        "[1↓,0↓]:0",
        "[1↓,0↓]:1",
        "[1↓,1↓,nucleus,0↓]:0",
        "[1↓,1↓,nucleus,0↓]:1",
        "[1↓,1↓,nucleus,0↓]:2",
        "[1↓,1↓,nucleus,1↓,numerator,0↓]:0",
        "[1↓,1↓,nucleus,1↓,numerator,0↓]:1",
        "[1↓,1↓,nucleus,1↓,denominator,0↓]:0",
        "[1↓,1↓,nucleus,1↓,denominator,0↓]:1",
        "[1↓,1↓,nucleus]:2",
        "[1↓,2↓]:0",
        "[1↓,2↓]:1",
        "[2↓]:0",
        "[2↓,0↓,0⇒]:0",
        "[2↓,0↓,0⇒,0↓,0⇒,0↓]:0",
        "[2↓,0↓,0⇒,0↓,0⇒,0↓]:1",
        "[2↓,0↓,0⇒]:1",
        "[2↓]:1",
        "[2↓,1↓,nucleus,0↓]:0",
        "[2↓,1↓,nucleus,0↓]:1",
        "[2↓,1↓,nucleus,1↓,0⇒]:0",
        "[2↓,1↓,nucleus,1↓,0⇒,0↓,0⇒,0↓]:0",
        "[2↓,1↓,nucleus,1↓,0⇒,0↓,0⇒,0↓]:1",
        "[2↓,1↓,nucleus,1↓,0⇒]:1",
        "[2↓,1↓,nucleus]:2",
        "[2↓]:2",
      ]

      for (i, location) in locations.enumerated() {
        #expect(location.description == expected[i], "i=\(i)")
      }
    }

    do {
      var locations = [TextLocation]()
      var location = documentManager.documentRange.endLocation
      while true {
        locations.append(location)
        guard let newLocation = documentManager.destinationLocation(for: location, .backward),
          location != newLocation
        else { break }
        location = newLocation
      }

      let expected: [String] = [
        "[]:3",
        "[2↓]:2",
        "[2↓,1↓,nucleus]:2",
        "[2↓,1↓,nucleus,1↓,0⇒]:1",
        "[2↓,1↓,nucleus,1↓,0⇒,0↓,0⇒,0↓]:1",
        "[2↓,1↓,nucleus,1↓,0⇒,0↓,0⇒,0↓]:0",
        "[2↓,1↓,nucleus,1↓,0⇒]:0",
        "[2↓,1↓,nucleus,0↓]:1",
        "[2↓,1↓,nucleus,0↓]:0",
        "[2↓]:1",
        "[2↓,0↓,0⇒]:1",
        "[2↓,0↓,0⇒,0↓,0⇒,0↓]:1",
        "[2↓,0↓,0⇒,0↓,0⇒,0↓]:0",
        "[2↓,0↓,0⇒]:0",
        "[2↓]:0",
        "[1↓,2↓]:1",
        "[1↓,2↓]:0",
        "[1↓,1↓,nucleus]:2",
        "[1↓,1↓,nucleus,1↓,denominator,0↓]:1",
        "[1↓,1↓,nucleus,1↓,denominator,0↓]:0",
        "[1↓,1↓,nucleus,1↓,numerator,0↓]:1",
        "[1↓,1↓,nucleus,1↓,numerator,0↓]:0",
        "[1↓,1↓,nucleus,0↓]:2",
        "[1↓,1↓,nucleus,0↓]:1",
        "[1↓,1↓,nucleus,0↓]:0",
        "[1↓,0↓]:1",
        "[1↓,0↓]:0",
        "[0↓]:2",
        "[0↓,1↓,0↓]:1",
        "[0↓,1↓,0↓]:0",
        "[0↓,0↓]:1",
        "[0↓,0↓]:0",
      ]

      for (i, location) in locations.enumerated() {
        #expect(location.description == expected[i], "i=\(i)")
      }
    }
  }
}

