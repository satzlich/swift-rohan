// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import Rohan

final class EnumerateContentsTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  // Helper function to copy contents in a given range

  private func copyContents(
    in range: RhTextRange, _ documentManager: DocumentManager
  ) throws -> ContentNode {
    let nodes = try DMUtils.copyNodes(in: range, documentManager)
    return ContentNode(nodes)
  }

  // Simple selection: both path and endPath are into the same node
  @Test
  func testSimpleSelection() throws {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("Hello, world!")]),
      ParagraphNode([TextNode("This is a paragraph.")]),
      ParagraphNode([
        EquationNode(
          isBlock: false,
          nucleus: [
            TextNode("a="),
            FractionNode(numerator: [TextNode("F")], denominator: [TextNode("m")]),
            TextNode("."),
          ])
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    // selection into text node: empty, partial, and full
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let midLocation = TextLocation(path, 1)
      let endLocation = TextLocation(path, 2)

      // empty
      do {
        let range = RhTextRange(midLocation)
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == "content")
      }
      // partial
      do {
        let range = RhTextRange(midLocation, endLocation)!
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == """
            content
            └ text "="
            """)
      }
      // full
      do {
        let range = RhTextRange(location, endLocation)!
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == """
            content
            └ text "a="
            """)
      }
    }

    // selection into element node: empty and non-empty
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let location = TextLocation(path, 1)
      let endLocation = TextLocation(path, 3)

      do {
        let range = RhTextRange(location, endLocation)!
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == """
            content
            ├ fraction
            │ ├ numerator
            │ │ └ text "F"
            │ └ denominator
            │   └ text "m"
            └ text "."
            """)
      }
      do {
        let range = RhTextRange(location)
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == """
            content
            """)
      }
    }
  }

  @Test
  func testMixedSelection() throws {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("Hello, "),
          EmphasisNode([TextNode("world")]),
          TextNode("!"),
        ])
    ])
    let documentManager = createDocumentManager(rootNode)

    do {  // Text vs Element
      let locations: [TextLocation] = [
        // heading -> text -> 0
        TextLocation([.index(0), .index(0)], 0),
        // heading -> text -> "Hel".llength
        TextLocation([.index(0), .index(0)], "Hel".llength),
        // heading -> text -> "Hello, ".llength
        TextLocation([.index(0), .index(0)], "Hello, ".llength),
      ]
      let endLocations = [
        // heading -> emphasis
        TextLocation([.index(0)], 1),
        // heading -> text
        TextLocation([.index(0)], 3),
      ]
      let expectedContents: [[String]] = [
        [
          """
          content
          └ text "Hello, "
          """,
          """
          content
          ├ text "Hello, "
          ├ emphasis
          │ └ text "world"
          └ text "!"
          """,
        ],
        [
          """
          content
          └ text "lo, "
          """,
          """
          content
          ├ text "lo, "
          ├ emphasis
          │ └ text "world"
          └ text "!"
          """,
        ],
        [
          """
          content
          """,
          """
          content
          ├ emphasis
          │ └ text "world"
          └ text "!"
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Text vs Element")
    }

    do {  // Element vs Text
      let locations = [
        // heading -> text
        TextLocation([.index(0)], 0),
        // heading -> emphasis
        TextLocation([.index(0)], 1),
      ]
      let endLocations: [TextLocation] = [
        // heading -> text -> 0
        TextLocation([.index(0), .index(2)], 0),
        // heading -> text -> "!".llength
        TextLocation([.index(0), .index(2)], "!".llength),
      ]
      let expectedContents: [[String]] = [
        [
          """
          content
          ├ text "Hello, "
          └ emphasis
            └ text "world"
          """,
          """
          content
          ├ text "Hello, "
          ├ emphasis
          │ └ text "world"
          └ text "!"
          """,
        ],
        [
          """
          content
          └ emphasis
            └ text "world"
          """,
          """
          content
          ├ emphasis
          │ └ text "world"
          └ text "!"
          """,
          """
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Element vs Text")
    }

    // Helper
    func testPairs(
      _ locations: [TextLocation], _ endLocations: [TextLocation],
      _ expectedContents: [[String]],
      _ message: String? = nil
    ) throws {
      try self.testPairs(
        locations, endLocations, expectedContents, documentManager, message)
    }
  }

  // Complex selection: path and endPath are in different nodes
  @Test
  func testComplexSelection() throws {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("Hello, "),
          EmphasisNode([TextNode("world")]),
          TextNode("!"),
        ]),
      ParagraphNode([
        EmphasisNode([TextNode("Emphasized text. ")]),
        TextNode("Normal text."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    let textLocations = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      return [
        TextLocation(path, 0),
        TextLocation(path, "Hel".llength),
        TextLocation(path, "Hello, ".llength),
      ]
    }()

    let endTextLocations = {
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // text
      ]
      return [
        TextLocation(endPath, 0),
        TextLocation(endPath, "Normal".llength),
        TextLocation(endPath, "Normal text.".llength),
      ]
    }()

    let elemLocations = {
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      return [
        TextLocation(path, 0),
        TextLocation(path, 1),
        TextLocation(path, 3),
      ]
    }()

    let endElemLocations = {
      let endPath: [RohanIndex] = [
        .index(1)  // paragraph
      ]
      return [
        TextLocation(endPath, 0),
        TextLocation(endPath, 1),
        TextLocation(endPath, 2),
      ]
    }()

    // MARK: - Text vs Text
    do {
      let locations: [TextLocation] = textLocations
      let endLocations: [TextLocation] = endTextLocations
      let expectedContents: [[String]] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Text vs Text")
    }

    // MARK: - Text vs Element
    do {
      let locations: [TextLocation] = textLocations
      let endLocations: [TextLocation] = endElemLocations
      let expectedContents: [[String]] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Text vs Element")
    }

    // MARK: - Element vs Text
    do {
      let locations: [TextLocation] = elemLocations
      let endLocations: [TextLocation] = endTextLocations
      let expectedContents: [[String]] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Element vs Text")
    }

    // MARK: - Element vs Element
    do {
      let locations: [TextLocation] = elemLocations
      let endLocations: [TextLocation] = endElemLocations
      let expectedContents: [[String]] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          └ paragraph
          """,
          """
          content
          ├ heading
          └ paragraph
            └ emphasis
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emphasis
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Element vs Element")
    }

    // Helper
    func testPairs(
      _ locations: [TextLocation], _ endLocations: [TextLocation],
      _ expectedContents: [[String]],
      _ message: String? = nil
    ) throws {
      try self.testPairs(
        locations, endLocations, expectedContents, documentManager, message)
    }
  }

  // Selection pass through ApplyNode
  @Test
  func testSelection_ApplyNode() throws {
    let rootNode = RootNode([
      ParagraphNode([
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [
              TextNode("Good "),
              EmphasisNode([TextNode("job")]),
            ]
          ])!
      ]),
      ParagraphNode([
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [
              ApplyNode(CompiledSamples.doubleText, [[TextNode("Sample")]])!,
              TextNode(" text."),
            ]
          ])!
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    do {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(0),  // text
      ]
      let location = TextLocation(path, "Go".llength)
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
      ]
      let endLocation = TextLocation(endPath, 2)
      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          ├ text "od "
          └ emphasis
            └ text "job"
          """)
    }

    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(0),  // text
      ]
      let location = TextLocation(path, "S".llength)
      let endLocation = TextLocation(path, "Sample".llength)
      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          └ text "ample"
          """)
    }

    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
      ]
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // apply
        .argumentIndex(0),  // argument
        .index(1),  // text
      ]
      let location = TextLocation(path, 0)
      let endLocation = TextLocation(endPath, " t".llength)
      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          ├ template(doubleText)
          │ ├ argument #0 (x2)
          │ └ content
          │   ├ text "{"
          │   ├ variable #0
          │   │ └ text "Sample"
          │   ├ text " and "
          │   ├ emphasis
          │   │ └ variable #0
          │   │   └ text "Sample"
          │   └ text "}"
          └ text " t"
          """)

    }
  }

  // Helper

  func testPairs(
    _ locations: [TextLocation], _ endLocations: [TextLocation],
    _ expectedContents: [[String]],
    _ documentManager: DocumentManager,
    _ message: String? = nil
  ) throws {
    let message = message.map { ", " + $0 } ?? ""

    for i in 0..<locations.count {
      for j in 0..<endLocations.count {
        let location = locations[i]
        let endLocation = endLocations[j]
        let range = RhTextRange(location, endLocation)!
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == expectedContents[i][j],
          "i: \(i), j: \(j)\(message)")
      }
    }
  }
}
