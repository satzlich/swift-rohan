// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class NavigationTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: true)
  }

  @Test
  func testMoveForwardBackward() {
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

    // move forward
    do {
      var locations = [AffineLocation]()
      var location = AffineLocation(documentManager.documentRange.location, .downstream)
      while true {
        locations.append(location)
        guard
          let newLocation = documentManager.destinationLocation(
            for: location, direction: .forward, destination: .character, extending: false),
          location.value != newLocation.value
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
        // print("\"\(location.description)\",")
        #expect(location.value.description == expected[i], "i=\(i)")
        #expect(location.affinity == .downstream)
      }
      print("----")
    }

    // move backward
    do {
      var locations = [AffineLocation]()
      var location =
        AffineLocation(documentManager.documentRange.endLocation, .downstream)
      while true {
        locations.append(location)
        guard
          let newLocation = documentManager.destinationLocation(
            for: location, direction: .backward, destination: .character,
            extending: false),
          location.value != newLocation.value
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
        "[]:0",
      ]

      for (i, location) in locations.enumerated() {
        // print("\"\(location.description)\",")
        #expect(location.value.description == expected[i], "i=\(i)")
        #expect(location.affinity == .downstream)
      }
    }
  }

  @Test
  func testMoveUpDown() {

  }
}
