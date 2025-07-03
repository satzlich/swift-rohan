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
      HeadingNode(.sectionAst, [TextNode("A"), TextStylesNode(.emph, [TextNode("b")])]),
      ParagraphNode([
        TextNode("c"),
        EquationNode(
          .display,
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
          .display,
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
      var locations = Array<AffineLocation>()
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

      let expected: Array<String> = [
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
        if [1, 6, 16, 18, 31].contains(i) {  // paragraph beginning.
          #expect(location.affinity == .downstream, "i=\(i)")
        }
        else {
          #expect(location.affinity == .upstream, "i=\(i)")
        }
      }
      print("----")
    }

    // move backward
    do {
      var locations = Array<AffineLocation>()
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

      let expected: Array<String> = [
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
        if [14, 26].contains(i) {
          #expect(location.affinity == .upstream, "i=\(i)")
        }
        else {
          #expect(location.affinity == .downstream, "i=\(i)")
        }
      }
    }
  }

  @Test
  func testMoveUpDown() {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("The quick brown fox jumps")]),
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

    func move(from location: TextLocation) -> Array<RhTextSelection> {
      let selection = RhTextSelection(location, affinity: .downstream)

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
          [([↓1,↓0]:0, downstream), \
          ([↓0,↓0]:24, downstream), \
          ([↓1,↓0]:40, upstream), \
          ([↓0,↓0]:25, downstream), \
          (anchor: [↓0,↓0]:25; focus: [↓1,↓0]:0, downstream; range: []:0..<[↓1,↓0]:0), \
          (focus: [↓0,↓0]:24, downstream; anchor: [↓0,↓0]:25; range: [↓0,↓0]:24..<[↓0,↓0]:25), \
          (anchor: [↓0,↓0]:25; focus: [↓1,↓0]:40, upstream; range: []:0..<[↓1,↓0]:40), \
          (focus: []:0, downstream; anchor: [↓0,↓0]:25; range: []:0..<[]:1)]
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
          [([↓1,↓0]:63, upstream), \
          ([↓1,↓0]:61, downstream), \
          ([↓1,↓0]:89, upstream), \
          ([↓1,↓0]:22, downstream), \
          (anchor: [↓1,↓0]:62; focus: [↓1,↓0]:63, upstream; range: [↓1,↓0]:62..<[↓1,↓0]:63), \
          (focus: [↓1,↓0]:61, downstream; anchor: [↓1,↓0]:62; range: [↓1,↓0]:61..<[↓1,↓0]:62), \
          (anchor: [↓1,↓0]:62; focus: [↓1,↓0]:89, upstream; range: [↓1,↓0]:62..<[↓1,↓0]:89), \
          (focus: [↓1,↓0]:22, downstream; anchor: [↓1,↓0]:62; range: [↓1,↓0]:22..<[↓1,↓0]:62)]
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
          [([↓1,↓0]:87, upstream), ([↓1,↓0]:85, downstream), \
          ([↓2,↓0,nuc,↓1,num,↓0]:2, upstream), \
          ([↓1,↓0]:46, downstream), \
          (anchor: [↓1,↓0]:86; focus: [↓1,↓0]:87, upstream; range: [↓1,↓0]:86..<[↓1,↓0]:87), \
          (focus: [↓1,↓0]:85, downstream; anchor: [↓1,↓0]:86; range: [↓1,↓0]:85..<[↓1,↓0]:86), \
          (anchor: [↓1,↓0]:86; focus: [↓2,↓0,nuc,↓1,num,↓0]:2, upstream; range: [↓1,↓0]:86..<[↓2]:1), \
          (focus: [↓1,↓0]:46, downstream; anchor: [↓1,↓0]:86; range: [↓1,↓0]:46..<[↓1,↓0]:86)]
          """)
    }
    do {
      // paragraph -> equation -> nucleus -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓2]", "+f".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)

      #expect("\(destinations[0])" == "([↓2,↓0,nuc,↓2]:3, upstream)")
      #expect("\(destinations[1])" == "([↓2,↓0,nuc,↓2]:1, downstream)")
      #expect("\(destinations[2])" == "([↓3,↓0,⇒0,↓0,⇒0,↓0]:1, downstream)")
      #expect("\(destinations[3])" == "([↓1,↓0]:89, upstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2; focus: [↓2,↓0,nuc,↓2]:3, upstream; range: [↓2,↓0,nuc,↓2]:2..<[↓2,↓0,nuc,↓2]:3)"
      )
      #expect(
        "\(destinations[5])"
          == "(focus: [↓2,↓0,nuc,↓2]:1, downstream; anchor: [↓2,↓0,nuc,↓2]:2; range: [↓2,↓0,nuc,↓2]:1..<[↓2,↓0,nuc,↓2]:2)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓2,↓0,nuc,↓2]:2; focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:1, downstream; range: [↓2]:0..<[↓3]:1)"
      )
      #expect(
        "\(destinations[7])"
          == "(focus: [↓1,↓0]:89, upstream; anchor: [↓2,↓0,nuc,↓2]:2; range: [↓1,↓0]:89..<[↓2]:1)"
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
          [([↓2,↓0,nuc,↓1,num,↓0]:3, upstream), \
          ([↓2,↓0,nuc,↓1,num,↓0]:1, downstream), \
          ([↓2,↓0,nuc,↓1,denom,↓0]:2, upstream), \
          ([↓1,↓0]:86, downstream), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2; focus: [↓2,↓0,nuc,↓1,num,↓0]:3, upstream; range: [↓2,↓0,nuc,↓1,num,↓0]:2..<[↓2,↓0,nuc,↓1,num,↓0]:3), \
          (focus: [↓2,↓0,nuc,↓1,num,↓0]:1, downstream; anchor: [↓2,↓0,nuc,↓1,num,↓0]:2; range: [↓2,↓0,nuc,↓1,num,↓0]:1..<[↓2,↓0,nuc,↓1,num,↓0]:2), \
          (anchor: [↓2,↓0,nuc,↓1,num,↓0]:2; focus: [↓2,↓0,nuc,↓1,denom,↓0]:2, upstream; range: [↓2,↓0,nuc]:1..<[↓2,↓0,nuc]:2), \
          (focus: [↓1,↓0]:86, downstream; anchor: [↓2,↓0,nuc,↓1,num,↓0]:2; range: [↓1,↓0]:86..<[↓2]:1)]
          """)
    }
    do {
      // paragraph -> equation -> nucleus -> fraction -> denominator -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓1,denom,↓0]", "d+".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓2,↓0,nuc,↓1,denom,↓0]:3, upstream), \
          ([↓2,↓0,nuc,↓1,denom,↓0]:1, downstream), \
          ([↓3,↓0,⇒0]:0, downstream), \
          ([↓2,↓0,nuc,↓1,num,↓0]:2, downstream), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2; focus: [↓2,↓0,nuc,↓1,denom,↓0]:3, upstream; range: [↓2,↓0,nuc,↓1,denom,↓0]:2..<[↓2,↓0,nuc,↓1,denom,↓0]:3), \
          (focus: [↓2,↓0,nuc,↓1,denom,↓0]:1, downstream; anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2; range: [↓2,↓0,nuc,↓1,denom,↓0]:1..<[↓2,↓0,nuc,↓1,denom,↓0]:2), \
          (anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2; focus: [↓3,↓0,⇒0]:0, downstream; range: [↓2]:0..<[↓3]:1), (focus: [↓2,↓0,nuc,↓1,num,↓0]:2, downstream; anchor: [↓2,↓0,nuc,↓1,denom,↓0]:2; range: [↓2,↓0,nuc]:1..<[↓2,↓0,nuc]:2)]
          """)
    }
    do {
      // paragraph -> apply -> #0
      let location = TextLocation.compose("[↓3,↓0,⇒0]", 1)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)

      #expect("\(destinations[0])" == "([↓3,↓1]:0, upstream)")
      #expect("\(destinations[1])" == "([↓3,↓0,⇒0,↓0,⇒0,↓0]:3, downstream)")
      #expect("\(destinations[2])" == "([↓3,↓1]:23, downstream)")
      #expect("\(destinations[3])" == "([↓2,↓0,nuc,↓2]:3, downstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓3,↓0,⇒0]:1; focus: [↓3,↓1]:0, upstream; range: [↓3]:0..<[↓3,↓1]:0)"
      )
      #expect(
        "\(destinations[5])"
          == "(focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, downstream; anchor: [↓3,↓0,⇒0]:1; range: [↓3,↓0,⇒0]:0..<[↓3,↓0,⇒0]:1)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓3,↓0,⇒0]:1; focus: [↓3,↓1]:23, downstream; range: [↓3]:0..<[↓3,↓1]:23)"
      )
      #expect(
        "\(destinations[7])"
          == "(focus: [↓2,↓0,nuc,↓2]:3, downstream; anchor: [↓3,↓0,⇒0]:1; range: [↓2]:0..<[↓3]:1)"
      )
      #expect(destinations.count == 8)
    }
    do {
      // paragraph -> apply -> #0 -> argument -> apply -> #0 -> text
      let location = TextLocation.compose("[↓3,↓0,⇒0,↓0,⇒0,↓0]", "fo".length)!
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect("\(destinations[0])" == "([↓3,↓0,⇒0,↓0,⇒0,↓0]:3, upstream)")
      #expect("\(destinations[1])" == "([↓3,↓0,⇒0,↓0,⇒0,↓0]:1, downstream)")
      #expect("\(destinations[2])" == "([↓3,↓1]:14, downstream)")
      #expect(        "\(destinations[3])"          == "([↓2,↓0,nuc,↓0]:2, downstream)")
      #expect(
        "\(destinations[4])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2; focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, upstream; range: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2..<[↓3,↓0,⇒0,↓0,⇒0,↓0]:3)"
      )
      #expect(
        "\(destinations[5])"
          == "(focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:1, downstream; anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2; range: [↓3,↓0,⇒0,↓0,⇒0,↓0]:1..<[↓3,↓0,⇒0,↓0,⇒0,↓0]:2)"
      )
      #expect(
        "\(destinations[6])"
          == "(anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2; focus: [↓3,↓1]:14, downstream; range: [↓3]:0..<[↓3,↓1]:14)"
      )
      #expect(
        "\(destinations[7])"
          == "(focus: [↓2,↓0,nuc,↓0]:2, downstream; anchor: [↓3,↓0,⇒0,↓0,⇒0,↓0]:2; range: [↓2]:0..<[↓3]:1)"
      )
      #expect(destinations.count == 8)
    }
    do {
      let path: Array<RohanIndex> = [
        .index(3),  // paragraph
        .index(1),  // text
      ]
      let text = "The quick brow"
      let location = TextLocation(path, text.length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓3,↓1]:15, upstream), \
          ([↓3,↓1]:13, downstream), \
          ([↓3,↓1]:44, upstream), \
          ([↓3,↓0,⇒0,↓0,⇒0,↓0]:3, downstream), \
          (anchor: [↓3,↓1]:14; focus: [↓3,↓1]:15, upstream; range: [↓3,↓1]:14..<[↓3,↓1]:15), \
          (focus: [↓3,↓1]:13, downstream; anchor: [↓3,↓1]:14; range: [↓3,↓1]:13..<[↓3,↓1]:14), \
          (anchor: [↓3,↓1]:14; focus: [↓3,↓1]:44, upstream; range: [↓3,↓1]:14..<[↓3,↓1]:44), \
          (focus: [↓3,↓0,⇒0,↓0,⇒0,↓0]:3, downstream; anchor: [↓3,↓1]:14; range: [↓3]:0..<[↓3,↓1]:14)]
          """)
    }
  }

  @Test
  func testMoveFromRange() {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("The quick brown fox jumps")]),
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
      let selection = RhTextSelection(range, affinity: .downstream)
      return documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: direction, destination: .character, extending: false)
    }

    do {
      let path: Array<RohanIndex> = [
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
      #expect("\(forwardDestination)" == "([↓1,↓0]:15, downstream)")
      #expect("\(backwardDestination)" == "([↓1,↓0]:9, downstream)")
      #expect("\(downDestination)" == "([↓1,↓0]:56, downstream)")
      #expect("\(upDestination)" == "([↓0,↓0]:5, downstream)")
    }
  }

  @Test
  func testMoveByWord() {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode("The quick "),
        TextStylesNode(
          .emph,
          [
            TextNode("brown fox jumps over ")
          ]),
        TextNode("the lazy dog."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)
    // outputPDF(#function, documentManager)

    func move(from location: TextLocation) -> Array<RhTextSelection> {
      let selection = RhTextSelection(location, affinity: .downstream)

      let forward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .forward, destination: .word, extending: false)
      let backward = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: .backward, destination: .word, extending: true)
      return [forward, backward].compactMap { $0 }
    }

    let movesCount = 2
    do {
      let path: Array<RohanIndex> = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick ".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓1,↓0]:0, upstream), \
          (focus: [↓1,↓0]:4, downstream; anchor: [↓1,↓0]:10; range: [↓1,↓0]:4..<[↓1,↓0]:10)]
          """)
    }
    do {
      let path: Array<RohanIndex> = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 1)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓1,↓0]:0, upstream), \
          (focus: [↓1,↓0]:10, downstream; anchor: [↓1]:1; range: [↓1,↓0]:10..<[↓1]:1)]
          """)
    }
    do {
      let path: Array<RohanIndex> = [
        .index(1)  // paragraph
      ]
      let location = TextLocation(path, 2)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:0, upstream), \
          (focus: [↓1,↓1,↓0]:21, downstream; anchor: [↓1]:2; range: [↓1]:1..<[↓1]:2)]
          """)
    }
    do {
      let path: Array<RohanIndex> = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:4, downstream), \
          (focus: [↓1,↓1,↓0]:21, downstream; anchor: [↓1,↓2]:0; range: [↓1]:1..<[↓1,↓2]:0)]
          """)
    }
    do {
      let path: Array<RohanIndex> = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "the ".length)
      let destinations = move(from: location)
      #expect(destinations.count == movesCount)
      #expect(
        destinations.description == """
          [([↓1,↓2]:9, downstream), \
          (focus: [↓1,↓2]:0, downstream; anchor: [↓1,↓2]:4; range: [↓1,↓2]:0..<[↓1,↓2]:4)]
          """)
    }
  }

  @Test
  func testDeletionRange() {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("The quick brown fox jumps")]),
      ParagraphNode([
        TextNode("The quick "),
        TextStylesNode(
          .emph,
          [
            TextNode("brown fox jumps over ")
          ]),
        TextNode("the lazy dog."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)
    // outputPDF(#function, documentManager)

    func deletionRange(from selection: RhTextSelection) -> Array<DeletionRange> {
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

    func deletionRange(from location: TextLocation) -> Array<DeletionRange> {
      let selection = RhTextSelection(location, affinity: .downstream)
      return deletionRange(from: selection)
    }

    let movesCount = 4
    do {
      let path: Array<RohanIndex> = [
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
      let path: Array<RohanIndex> = [
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
      let path: Array<RohanIndex> = [
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
      let path: Array<RohanIndex> = [
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
      let path: Array<RohanIndex> = [
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
      let path: Array<RohanIndex> = [
        .index(1),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "the ".length)
      let end = TextLocation(path, "the quick ".length)
      let range = RhTextRange(location, end)!
      let destinations =
        deletionRange(from: RhTextSelection(range, affinity: .downstream))
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

  @Test
  func enclosingTextRange() {
    let documentManager = createDocumentManager(
      RootNode([
        HeadingNode(.sectionAst, [TextNode("The quick brown fox jumps")])
      ]))
    let location = TextLocation.parse("[↓0,↓0]:4")!
    let selection = RhTextSelection(location, affinity: .downstream)

    let enclosingRange =
      documentManager.textSelectionNavigation.enclosingTextRange(for: .word, selection)
    let expected =
      "(anchor: [↓0,↓0]:4; focus: [↓0,↓0]:10, upstream; range: [↓0,↓0]:4..<[↓0,↓0]:10)"

    #expect(enclosingRange != nil)
    #expect("\(enclosingRange!)" == expected)
  }
}
