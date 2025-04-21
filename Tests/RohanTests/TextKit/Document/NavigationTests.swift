// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class NavigationTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func testMove() {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("A"), EmphasisNode([TextNode("b")])]),
      ParagraphNode([
        TextNode("c"),
        EquationNode(
          isBlock: true,
          nucleus: [
            TextNode("d+"),
            FractionNode(numerator: [TextNode("e")], denominator: [TextNode("f")]),
          ]),
        TextNode("g"),
      ]),
      ParagraphNode([
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [ApplyNode(CompiledSamples.doubleText, [[TextNode("h")]])!]
          ])!,
        EquationNode(
          isBlock: true,
          nucleus: [
            TextNode("i"),
            ApplyNode(
              CompiledSamples.bifun,
              [
                [ApplyNode(CompiledSamples.bifun, [[TextNode("j")]])!]
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
        guard
          let newLocation = documentManager.destinationLocation(
            for: location, affinity: .downstream,
            direction: .forward, destination: .character, extending: false),
          location != newLocation.value
        else { break }
        location = newLocation.value
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
        // print("\"\(location.description)\",")
        #expect(location.description == expected[i], "i=\(i)")
      }
      print("----")
    }

    do {
      var locations = [TextLocation]()
      var location = documentManager.documentRange.endLocation
      while true {
        locations.append(location)
        guard
          let newLocation = documentManager.destinationLocation(
            for: location, affinity: .downstream, direction: .backward,
            destination: .character, extending: false),
          location != newLocation.value
        else { break }
        location = newLocation.value
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
        "[]:0",
      ]

      for (i, location) in locations.enumerated() {
        // print("\"\(location.description)\",")
        #expect(location.description == expected[i], "i=\(i)")
      }
    }
  }
}
