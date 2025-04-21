// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class TextSelectionNavigationTests: TextKitTestsBase {
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
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode(
          """
          The quick brown fox jumps over the lazy dog. \
          The quick brown fox jumps over the lazy dog.
          """)
      ]),
      ParagraphNode([
        EquationNode(
          isBlock: false,
          nucleus: [
            TextNode("a+"),
            FractionNode(numerator: [TextNode("b-c")], denominator: [TextNode("d+e")]),
            TextNode("+f+g+h"),
          ])
      ]),
      ParagraphNode([
        ApplyNode(
          CompiledSamples.doubleText,
          [[ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]])!,
        TextNode("The quick brown fox jumps over the lazy dog."),
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)
    outputPDF(#function, documentManager)

    func moveDown(from location: TextLocation) -> RhTextSelection? {
      let selection = RhTextSelection(location)
      return documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .down, destination: .character, extending: false,
        confined: false)
    }
    func moveUp(from location: TextLocation) -> RhTextSelection? {
      let selection = RhTextSelection(location)
      return documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .up, destination: .character, extending: false,
        confined: false)
    }

    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick brown fox jumps".length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect("\(downDestination)" == "location: [1↓,0↓]:40, affinity: upstream")
      #expect("\(upDestination)" == "location: [0↓,0↓]:25, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let text = """
        The quick brown fox jumps over the lazy dog. \
        The quick        
        """
      let location = TextLocation(path, text.length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect("\(downDestination)" == "location: [1↓,0↓]:89, affinity: upstream")
      #expect("\(upDestination)" == "location: [1↓,0↓]:22, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let text = """
        The quick brown fox jumps over the lazy dog. \
        The quick brown fox jumps over the lazy d
        """
      let location = TextLocation(path, text.length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [2↓,0↓,nucleus,1↓,numerator,0↓]:2, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [1↓,0↓]:46, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(2),  // text
      ]
      let location = TextLocation(path, "+f".length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [3↓,0↓,0⇒,0↓,0⇒,0↓]:1, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [1↓,0↓]:89, affinity: upstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.numerator),  // numerator
        .index(0),  // text
      ]
      let location = TextLocation(path, "b-".length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [2↓,0↓,nucleus,1↓,denominator,0↓]:2, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [1↓,0↓]:86, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.denominator),  // denominator
        .index(0),  // text
      ]
      let location = TextLocation(path, "d+".length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [3↓,0↓,0⇒]:0, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [2↓,0↓,nucleus,1↓,numerator,0↓]:2, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(3),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
      ]
      let location = TextLocation(path, 1)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [3↓,1↓]:23, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [2↓,0↓,nucleus,2↓]:4, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(3),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(0),  // text
      ]
      let location = TextLocation(path, "fo".length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [3↓,1↓]:14, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [2↓,0↓,nucleus,1↓,denominator,0↓]:0, affinity: downstream")
    }
    do {
      let path: [RohanIndex] = [
        .index(3),  // paragraph
        .index(1),  // text
      ]
      let text = "The quick brow"
      let location = TextLocation(path, text.length)
      guard let downDestination = moveDown(from: location),
        let upDestination = moveUp(from: location)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect(
        "\(downDestination)"
          == "location: [3↓,1↓]:14, affinity: downstream")
      #expect(
        "\(upDestination)"
          == "location: [3↓,0↓,0⇒,0↓,0⇒,0↓]:3, affinity: downstream")
    }
  }

  @Test
  func testMoveFromRange() {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode(
          """
          The quick brown fox jumps over the lazy dog. \
          The quick brown fox jumps over the lazy dog.
          """)
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    func move(
      from range: RhTextRange, direction: TextSelectionNavigation.Direction
    ) -> RhTextSelection? {
      let selection = RhTextSelection(range)
      return documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: direction, destination: .character, extending: false,
        confined: false)
    }

    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick".length)
      let end = TextLocation(path, "The quick brown".length)
      let range = RhTextRange(location, end)!

      guard let forwardDestination = move(from: range, direction: .forward),
        let backwardDestination = move(from: range, direction: .backward),
        let downDestination = move(from: range, direction: .down),
        let upDestination = move(from: range, direction: .up)
      else {
        Issue.record("Failed to get destination selection")
        return
      }
      #expect("\(forwardDestination)" == "location: [1↓,0↓]:15, affinity: downstream")
      #expect("\(backwardDestination)" == "location: [1↓,0↓]:9, affinity: downstream")
      #expect("\(downDestination)" == "location: [1↓,0↓]:56, affinity: downstream")
      #expect("\(upDestination)" == "location: [0↓,0↓]:5, affinity: downstream")
    }
  }
}
