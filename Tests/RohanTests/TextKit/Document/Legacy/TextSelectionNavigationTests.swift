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
          .block,
          [
            TextNode("d+"),
            FractionNode(num: [TextNode("e")], denom: [TextNode("f")]),
          ]),
        TextNode("g"),
      ]),
      ParagraphNode([
        ApplyNode(
          MathTemplateSamples.doubleText,
          [
            [ApplyNode(MathTemplateSamples.doubleText, [[TextNode("h")]])!]
          ])!,
        EquationNode(
          .block,
          [
            TextNode("i"),
            ApplyNode(
              MathTemplateSamples.bifun,
              [
                [ApplyNode(MathTemplateSamples.bifun, [[TextNode("j")]])!]
              ])!,
          ]),
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    // move forward
    do {
      var locations = [AffineLocation]()
      var location = AffineLocation(documentManager.documentRange.location, .upstream)
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
        "[↓0,↓0]:0",
        "[↓0,↓0]:1",
        "[↓0,↓1,↓0]:0",
        "[↓0,↓1,↓0]:1",
        "[↓0]:2",
        "[↓1,↓0]:0",
        "[↓1,↓0]:1",
        "[↓1,↓1,nuc,↓0]:0",
        "[↓1,↓1,nuc,↓0]:1",
        "[↓1,↓1,nuc,↓0]:2",
        "[↓1,↓1,nuc,↓1,num,↓0]:0",
        "[↓1,↓1,nuc,↓1,num,↓0]:1",
        "[↓1,↓1,nuc,↓1,denom,↓0]:0",
        "[↓1,↓1,nuc,↓1,denom,↓0]:1",
        "[↓1,↓1,nuc]:2",
        "[↓1,↓2]:0",
        "[↓1,↓2]:1",
        "[↓2]:0",
        "[↓2,↓0,⇒0]:0",
        "[↓2,↓0,⇒0,↓0,⇒0,↓0]:0",
        "[↓2,↓0,⇒0,↓0,⇒0,↓0]:1",
        "[↓2,↓0,⇒0]:1",
        "[↓2]:1",
        "[↓2,↓1,nuc,↓0]:0",
        "[↓2,↓1,nuc,↓0]:1",
        "[↓2,↓1,nuc,↓1,⇒0]:0",
        "[↓2,↓1,nuc,↓1,⇒0,↓0,⇒0,↓0]:0",
        "[↓2,↓1,nuc,↓1,⇒0,↓0,⇒0,↓0]:1",
        "[↓2,↓1,nuc,↓1,⇒0]:1",
        "[↓2,↓1,nuc]:2",
        "[↓2]:2",
      ]

      for (i, location) in locations.enumerated() {
        // print("\"\(location.description)\",")
        #expect(location.value.description == expected[i], "i=\(i)")
        #expect(location.affinity == .upstream, "i=\(i)")
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
        "[↓2]:2",
        "[↓2,↓1,nuc]:2",
        "[↓2,↓1,nuc,↓1,⇒0]:1",
        "[↓2,↓1,nuc,↓1,⇒0,↓0,⇒0,↓0]:1",
        "[↓2,↓1,nuc,↓1,⇒0,↓0,⇒0,↓0]:0",
        "[↓2,↓1,nuc,↓1,⇒0]:0",
        "[↓2,↓1,nuc,↓0]:1",
        "[↓2,↓1,nuc,↓0]:0",
        "[↓2]:1",
        "[↓2,↓0,⇒0]:1",
        "[↓2,↓0,⇒0,↓0,⇒0,↓0]:1",
        "[↓2,↓0,⇒0,↓0,⇒0,↓0]:0",
        "[↓2,↓0,⇒0]:0",
        "[↓2]:0",
        "[↓1,↓2]:1",
        "[↓1,↓2]:0",
        "[↓1,↓1,nuc]:2",
        "[↓1,↓1,nuc,↓1,denom,↓0]:1",
        "[↓1,↓1,nuc,↓1,denom,↓0]:0",
        "[↓1,↓1,nuc,↓1,num,↓0]:1",
        "[↓1,↓1,nuc,↓1,num,↓0]:0",
        "[↓1,↓1,nuc,↓0]:2",
        "[↓1,↓1,nuc,↓0]:1",
        "[↓1,↓1,nuc,↓0]:0",
        "[↓1,↓0]:1",
        "[↓1,↓0]:0",
        "[↓0]:2",
        "[↓0,↓1,↓0]:1",
        "[↓0,↓1,↓0]:0",
        "[↓0,↓0]:1",
        "[↓0,↓0]:0",
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
          .inline,
          [
            TextNode("a+"),
            FractionNode(num: [TextNode("b-c")], denom: [TextNode("d+e")]),
            TextNode("+f+g+h"),
          ])
      ]),
      ParagraphNode([
        ApplyNode(
          MathTemplateSamples.doubleText,
          [[ApplyNode(MathTemplateSamples.doubleText, [[TextNode("fox")]])!]])!,
        TextNode("The quick brown fox jumps over the lazy dog."),
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)
    outputPDF(#function, documentManager)

    func move(from location: TextLocation) -> [RhTextSelection] {
      let selection = RhTextSelection(location)

      let forward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .forward, destination: .character, extending: false)
      let backward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .backward, destination: .character, extending: false)
      let down = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .down, destination: .character, extending: false)
      let up = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .up, destination: .character, extending: false)
      let forwardExtended = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .forward, destination: .character, extending: true)
      let backwardExtended = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .backward, destination: .character, extending: true)
      let downExtended = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .down, destination: .character, extending: true)
      let upExtended = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .up, destination: .character, extending: true)
      return [
        forward, backward, down, up,
        forwardExtended, backwardExtended, downExtended, upExtended,
      ].compactMap { $0 }
    }

    let movesCount = 8

    do {
      // heading -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓0]", "The quick brown fox jumps".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓0]:0, affinity: upstream), \
          (location: [↓0,↓0]:24, affinity: downstream), \
          (location: [↓1,↓0]:40, affinity: upstream), \
          (location: [↓0,↓0]:25, affinity: downstream), \
          (anchor: [↓0,↓0]:25, focus: [↓1,↓0]:0, reversed: false, affinity: upstream), \
          (anchor: [↓0,↓0]:25, focus: [↓0,↓0]:24, reversed: true, affinity: downstream), \
          (anchor: [↓0,↓0]:25, focus: [↓1,↓0]:40, reversed: false, affinity: upstream), \
          (anchor: [↓0,↓0]:25, focus: []:0, reversed: true, affinity: downstream)]
          """)
    }
    do {
      // paragraph -> text -> <offset>
      let text = """
        The quick brown fox jumps over the lazy dog. \
        The quick        
        """
      let location = TextLocation.compose("[↓1,↓0]", text.length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓0]:63, affinity: upstream), \
          (location: [↓1,↓0]:61, affinity: downstream), \
          (location: [↓1,↓0]:89, affinity: upstream), \
          (location: [↓1,↓0]:22, affinity: downstream), \
          (anchor: [↓1,↓0]:62, focus: [↓1,↓0]:63, reversed: false, affinity: upstream), \
          (anchor: [↓1,↓0]:62, focus: [↓1,↓0]:61, reversed: true, affinity: downstream), \
          (anchor: [↓1,↓0]:62, focus: [↓1,↓0]:89, reversed: false, affinity: upstream), \
          (anchor: [↓1,↓0]:62, focus: [↓1,↓0]:22, reversed: true, affinity: downstream)]
          """)
    }
    do {
      let text = """
        The quick brown fox jumps over the lazy dog. \
        The quick brown fox jumps over the lazy d
        """
      let location = TextLocation.compose("[↓1,↓0]", text.length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓0]:87, affinity: upstream), \
          (location: [↓1,↓0]:85, affinity: downstream), \
          (location: [↓2,↓0,nuc,↓1,num,↓0]:2, affinity: upstream), \
          (location: [↓1,↓0]:46, affinity: downstream), \
          (anchor: [↓1,↓0]:86, focus: [↓1,↓0]:87, reversed: false, affinity: upstream), \
          (anchor: [↓1,↓0]:86, focus: [↓1,↓0]:85, reversed: true, affinity: downstream), \
          (anchor: [↓1,↓0]:86, focus: [↓2,↓0,nuc,↓1,num,↓0]:2, reversed: false, affinity: upstream), \
          (anchor: [↓1,↓0]:86, focus: [↓1,↓0]:46, reversed: true, affinity: downstream)]
          """)
    }
    do {
      // paragraph -> equation -> nucleus -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓2]", "+f".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)

      #expect(
        "\(destinations[0])" == "(location: [↓2,↓0,nuc,↓2]:3, affinity: upstream)")
      #expect(
        "\(destinations[1])" == "(location: [↓2,↓0,nuc,↓2]:1, affinity: downstream)")
      #expect(
        "\(destinations[2])" == "(location: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, affinity: downstream)")
      #expect(
        "\(destinations[3])" == "(location: [↓1,↓0]:89, affinity: upstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2, focus: [↓2,↓0,nuc,↓2]:3, reversed: false, affinity: upstream)"
      )
      #expect(
        "\(destinations[5])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2, focus: [↓2,↓0,nuc,↓2]:1, reversed: true, affinity: downstream)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2, focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, reversed: false, affinity: downstream)"
      )
      #expect(
        "\(destinations[7])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2, focus: [↓1,↓0]:89, reversed: true, affinity: upstream)"
      )
      #expect(destinations.count == 8)
    }
    do {
      // paragraph -> equation -> nucleus -> fraction -> numerator -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓1,num,↓0]", "b-".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓2,↓0,nuc,↓1,num,↓0]:3, affinity: downstream), \
          (location: [↓2,↓0,nuc,↓1,num,↓0]:1, affinity: downstream), \
          (location: [↓2,↓0,nuc,↓1,denom,↓0]:2, affinity: downstream), \
          (location: [↓1,↓0]:86, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2, focus: [↓2,↓0,nuc,↓1,num,↓0]:3, reversed: false, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2, focus: [↓2,↓0,nuc,↓1,num,↓0]:1, reversed: true, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2, focus: [↓2,↓0,nuc,↓1,denom,↓0]:2, reversed: false, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2, focus: [↓1,↓0]:86, reversed: true, affinity: downstream)]
          """)
    }
    do {
      // paragraph -> equation -> nucleus -> fraction -> denominator -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓1,denom,↓0]", "d+".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓2,↓0,nuc,↓1,denom,↓0]:3, affinity: downstream), \
          (location: [↓2,↓0,nuc,↓1,denom,↓0]:1, affinity: downstream), \
          (location: [↓3,↓0,⇒0]:0, affinity: downstream), \
          (location: [↓2,↓0,nuc,↓1,num,↓0]:2, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2, focus: [↓2,↓0,nuc,↓1,denom,↓0]:3, reversed: false, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2, focus: [↓2,↓0,nuc,↓1,denom,↓0]:1, reversed: true, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2, focus: [↓3,↓0,⇒0]:0, reversed: false, affinity: downstream), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2, focus: [↓2,↓0,nuc,↓1,num,↓0]:2, reversed: true, affinity: downstream)]
          """)
    }
    do {
      // paragraph -> apply -> #0
      let location = TextLocation.compose("[↓3,↓0,⇒0]", 1)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)

      #expect("\(destinations[0])" == "(location: [↓3,↓1]:0, affinity: downstream)")
      #expect(
        "\(destinations[1])" == "(location: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, affinity: downstream)")
      #expect("\(destinations[2])" == "(location: [↓3,↓1]:23, affinity: downstream)")
      #expect(
        "\(destinations[3])" == "(location: [↓2,↓0,nuc,↓2]:3, affinity: downstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓3,↓0,⇒0]:1, focus: [↓3,↓1]:0, reversed: false, affinity: downstream)"
      )
      #expect(
        "\(destinations[5])"
          == "(anchor: [↓3,↓0,⇒0]:1, focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, reversed: true, affinity: downstream)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓3,↓0,⇒0]:1, focus: [↓3,↓1]:23, reversed: false, affinity: downstream)"
      )
      #expect(
        "\(destinations[7])"
          == "(anchor: [↓3,↓0,⇒0]:1, focus: [↓2,↓0,nuc,↓2]:3, reversed: true, affinity: downstream)"
      )
      #expect(destinations.count == 8)
    }
    do {
      // paragraph -> apply -> #0 -> argument -> apply -> #0 -> text
      let location = TextLocation.compose("[↓3,↓0,⇒0,↓0,⇒0,↓0]", "fo".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        "\(destinations[0])" == "(location: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, affinity: downstream)")
      #expect(
        "\(destinations[1])" == "(location: [↓3,↓0,⇒0,↓0,⇒0,↓0]:1, affinity: downstream)")
      #expect("\(destinations[2])" == "(location: [↓3,↓1]:14, affinity: downstream)")
      #expect(
        "\(destinations[3])"
          == "(location: [↓2,↓0,nuc,↓0]:2, affinity: downstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, reversed: false, affinity: downstream)"
      )
      #expect(
        "\(destinations[5])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:1, reversed: true, affinity: downstream)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, focus: [↓3,↓1]:14, reversed: false, affinity: downstream)"
      )
      #expect(
        "\(destinations[7])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2, focus: [↓2,↓0,nuc,↓0]:2, reversed: true, affinity: downstream)"
      )
      #expect(destinations.count == 8)
    }
    do {
      let path: [RohanIndex] = [
        .index(3),  // paragraph
        .index(1),  // text
      ]
      let text = "The quick brow"
      let location = TextLocation(path, text.length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓3,↓1]:15, affinity: downstream), \
          (location: [↓3,↓1]:13, affinity: downstream), \
          (location: [↓3,↓1]:44, affinity: downstream), \
          (location: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, affinity: downstream), \
          (anchor: [↓3,↓1]:14, focus: [↓3,↓1]:15, reversed: false, affinity: downstream), \
          (anchor: [↓3,↓1]:14, focus: [↓3,↓1]:13, reversed: true, affinity: downstream), \
          (anchor: [↓3,↓1]:14, focus: [↓3,↓1]:44, reversed: false, affinity: downstream), \
          (anchor: [↓3,↓1]:14, focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, reversed: true, affinity: downstream)]
          """)
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
        for: selection, direction: direction, destination: .character, extending: false)
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
      #expect("\(forwardDestination)" == "(location: [↓1,↓0]:15, affinity: downstream)")
      #expect("\(backwardDestination)" == "(location: [↓1,↓0]:9, affinity: downstream)")
      #expect("\(downDestination)" == "(location: [↓1,↓0]:56, affinity: downstream)")
      #expect("\(upDestination)" == "(location: [↓0,↓0]:5, affinity: downstream)")
    }
  }

  @Test
  func testMoveByWord() {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode("The quick "),
        EmphasisNode([
          TextNode("brown fox jumps over ")
        ]),
        TextNode("the lazy dog."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)
    // outputPDF(#function, documentManager)

    func move(from location: TextLocation) -> [RhTextSelection] {
      let selection = RhTextSelection(location)

      let forward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .forward, destination: .word, extending: false)
      let backward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .backward, destination: .word, extending: true)
      return [forward, backward].compactMap { $0 }
    }

    let movesCount = 2
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick ".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓1,↓0]:0, affinity: downstream), \
          (anchor: [↓1,↓0]:10, focus: [↓1,↓0]:4, reversed: true, affinity: downstream)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 1)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓1,↓0]:0, affinity: downstream), \
          (anchor: [↓1]:1, focus: [↓1,↓0]:10, reversed: true, affinity: downstream)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 2)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓2]:0, affinity: downstream), \
          (anchor: [↓1]:2, focus: [↓1,↓1,↓0]:21, reversed: true, affinity: downstream)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓2]:4, affinity: downstream), \
          (anchor: [↓1,↓2]:0, focus: [↓1,↓1,↓0]:21, reversed: true, affinity: downstream)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "the ".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [(location: [↓1,↓2]:9, affinity: downstream), \
          (anchor: [↓1,↓2]:4, focus: [↓1,↓2]:0, reversed: true, affinity: downstream)]
          """)
    }
  }

  @Test
  func testDeletionRange() {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode("The quick "),
        EmphasisNode([
          TextNode("brown fox jumps over ")
        ]),
        TextNode("the lazy dog."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)
    // outputPDF(#function, documentManager)

    func deletionRange(from selection: RhTextSelection) -> [DeletionRange] {
      let forward = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: .forward, destination: .character)
      let backward = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: .backward, destination: .character)

      let forwardWord = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: .forward, destination: .word)
      let backwardWord = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: .backward, destination: .word)

      return [forward, backward, forwardWord, backwardWord].compactMap { $0 }
    }

    func deletionRange(from location: TextLocation) -> [DeletionRange] {
      let selection = RhTextSelection(location)
      return deletionRange(from: selection)
    }

    let movesCount = 4
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick ".length)
      let destinations = deletionRange(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓0]:10..<[↓1]:2, delayed), \
          ([↓1,↓0]:9..<[↓1,↓0]:10, immediate), \
          ([↓1,↓0]:10..<[↓1]:2, delayed), \
          ([↓1,↓0]:4..<[↓1,↓0]:10, immediate)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 1)
      let destinations = deletionRange(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1]:1..<[↓1]:2, delayed), \
          ([↓1,↓0]:10..<[↓1]:1, immediate), \
          ([↓1]:1..<[↓1]:2, delayed), \
          ([↓1,↓0]:10..<[↓1]:1, immediate)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 2)
      let destinations = deletionRange(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1]:2..<[↓1,↓2]:0, immediate), \
          ([↓1]:1..<[↓1]:2, delayed), \
          ([↓1]:2..<[↓1,↓2]:0, immediate), \
          ([↓1]:1..<[↓1]:2, delayed)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "".length)
      let destinations = deletionRange(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:0..<[↓1,↓2]:1, immediate), \
          ([↓1]:1..<[↓1,↓2]:0, delayed), \
          ([↓1,↓2]:0..<[↓1,↓2]:4, immediate), \
          ([↓1]:1..<[↓1,↓2]:0, delayed)]
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "the ".length)
      let destinations = deletionRange(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:4..<[↓1,↓2]:5, immediate), \
          ([↓1,↓2]:3..<[↓1,↓2]:4, immediate), \
          ([↓1,↓2]:4..<[↓1,↓2]:9, immediate), \
          ([↓1,↓2]:0..<[↓1,↓2]:4, immediate)]
          """)
    }

    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "the ".length)
      let end = TextLocation(path, "the quick ".length)
      let range = RhTextRange(location, end)!
      let destinations = deletionRange(from: RhTextSelection(range))
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:4..<[↓1,↓2]:10, immediate), \
          ([↓1,↓2]:4..<[↓1,↓2]:10, immediate), \
          ([↓1,↓2]:4..<[↓1,↓2]:10, immediate), \
          ([↓1,↓2]:4..<[↓1,↓2]:10, immediate)]
          """)
    }
  }

}
