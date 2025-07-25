import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

final class EnumerateContentsTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  // Helper function to copy contents in a given range

  private func copyContents(
    in range: RhTextRange, _ documentManager: DocumentManager
  ) throws -> ContentNode {
    let nodes: ElementStore =
      documentManager.mapContents(in: range, { $0.deepCopy() }) ?? []
    return ContentNode(nodes)
  }

  // Simple selection: both path and endPath are into the same node
  @Test
  func testSimpleSelection() throws {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("Hello, world!")]),
      ParagraphNode([TextNode("This is a paragraph.")]),
      ParagraphNode([
        EquationNode(
          .inline,
          [
            TextNode("a="),
            FractionNode(num: [TextNode("F")], denom: [TextNode("m")]),
            TextNode("."),
          ])
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    // selection into text node: empty, partial, and full
    do {
      // paragraph -> equation -> nucleus -> text
      let location = TextLocation.compose("[↓2,↓0,nuc,↓0]", 0)!
      let midLocation = TextLocation.compose("[↓2,↓0,nuc,↓0]", 1)!
      let endLocation = TextLocation.compose("[↓2,↓0,nuc,↓0]", 2)!

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
      // paragraph -> equation -> nucleus
      let location = TextLocation.compose("[↓2,↓0,nuc]", 1)!
      let endLocation = TextLocation.compose("[↓2,↓0,nuc]", 3)!

      do {
        let range = RhTextRange(location, endLocation)!
        let content = try copyContents(in: range, documentManager)
        #expect(
          content.prettyPrint() == """
            content
            ├ fraction
            │ ├ num
            │ │ └ text "F"
            │ └ denom
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
        .sectionAst,
        [
          TextNode("Hello, "),
          TextStylesNode(.emph, [TextNode("world")]),
          TextNode("!"),
        ])
    ])
    let documentManager = createDocumentManager(rootNode)

    do {  // Text vs Element
      let locations: Array<TextLocation> = [
        // heading -> text -> 0
        TextLocation.compose("[↓0,↓0]", 0)!,
        // heading -> text -> "Hel".length
        TextLocation.compose("[↓0,↓0]", "Hel".length)!,
        // heading -> text -> "Hello, ".length
        TextLocation.compose("[↓0,↓0]", "Hello, ".length)!,
      ]
      let endLocations = [
        // heading -> emphasis
        TextLocation.compose("[↓0]", 1)!,
        // heading -> text
        TextLocation.compose("[↓0]", 3)!,
      ]
      let expectedContents: [Array<String>] = [
        [
          """
          content
          └ text "Hello, "
          """,
          """
          content
          ├ text "Hello, "
          ├ emph
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
          ├ emph
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
          ├ emph
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
        TextLocation.compose("[↓0]", 0)!,
        // heading -> emphasis
        TextLocation.compose("[↓0]", 1)!,
      ]
      let endLocations: Array<TextLocation> = [
        // heading -> text -> 0
        TextLocation.compose("[↓0,↓2]", 0)!,
        // heading -> text -> "!".length
        TextLocation.compose("[↓0,↓2]", "!".length)!,
      ]
      let expectedContents: [Array<String>] = [
        [
          """
          content
          ├ text "Hello, "
          └ emph
            └ text "world"
          """,
          """
          content
          ├ text "Hello, "
          ├ emph
          │ └ text "world"
          └ text "!"
          """,
        ],
        [
          """
          content
          └ emph
            └ text "world"
          """,
          """
          content
          ├ emph
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
      _ locations: Array<TextLocation>, _ endLocations: Array<TextLocation>,
      _ expectedContents: [Array<String>],
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
        .sectionAst,
        [
          TextNode("Hello, "),
          TextStylesNode(.emph, [TextNode("world")]),
          TextNode("!"),
        ]),
      ParagraphNode([
        TextStylesNode(.emph, [TextNode("Emphasized text. ")]),
        TextNode("Normal text."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    let textLocations = [
      // heading -> text -> <offset>
      TextLocation.compose("[↓0,↓0]", 0)!,
      TextLocation.compose("[↓0,↓0]", "Hel".length)!,
      TextLocation.compose("[↓0,↓0]", "Hello, ".length)!,
    ]

    let endTextLocations = [
      // paragraph -> text -> <offset>
      TextLocation.compose("[↓1,↓1]", 0)!,
      TextLocation.compose("[↓1,↓1]", "Normal".length)!,
      TextLocation.compose("[↓1,↓1]", "Normal text.".length)!,
    ]

    let elemLocations = [
      // heading -> <offset>
      TextLocation.compose("[↓0]", 0)!,
      TextLocation.compose("[↓0]", 1)!,
      TextLocation.compose("[↓0]", 3)!,
    ]

    let endElemLocations = [
      // paragraph -> <offset>
      TextLocation.compose("[↓1]", 0)!,
      TextLocation.compose("[↓1]", 1)!,
      TextLocation.compose("[↓1]", 2)!,
    ]

    // MARK: - Text vs Text
    do {
      let locations: Array<TextLocation> = textLocations
      let endLocations: Array<TextLocation> = endTextLocations
      let expectedContents: [Array<String>] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Text vs Text")
    }

    // MARK: - Text vs Element
    do {
      let locations: Array<TextLocation> = textLocations
      let endLocations: Array<TextLocation> = endElemLocations
      let expectedContents: [Array<String>] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "lo, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Text vs Element")
    }

    // MARK: - Element vs Text
    do {
      let locations: Array<TextLocation> = elemLocations
      let endLocations: Array<TextLocation> = endTextLocations
      let expectedContents: [Array<String>] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal"
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Element vs Text")
    }

    // MARK: - Element vs Element
    do {
      let locations: Array<TextLocation> = elemLocations
      let endLocations: Array<TextLocation> = endElemLocations
      let expectedContents: [Array<String>] = [
        [
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ text "Hello, "
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
        [
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          │ ├ emph
          │ │ └ text "world"
          │ └ text "!"
          └ paragraph
            ├ emph
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
            └ emph
              └ text "Emphasized text. "
          """,
          """
          content
          ├ heading
          └ paragraph
            ├ emph
            │ └ text "Emphasized text. "
            └ text "Normal text."
          """,
        ],
      ]
      try testPairs(locations, endLocations, expectedContents, "Element vs Element")
    }

    // Helper
    func testPairs(
      _ locations: Array<TextLocation>, _ endLocations: Array<TextLocation>,
      _ expectedContents: [Array<String>],
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
          MathTemplateSamples.doubleText,
          [
            [
              TextNode("Good "),
              TextStylesNode(.emph, [TextNode("job")]),
            ]
          ])!
      ]),
      ParagraphNode([
        ApplyNode(
          MathTemplateSamples.doubleText,
          [
            [
              ApplyNode(MathTemplateSamples.doubleText, [[TextNode("Sample")]])!,
              TextNode(" text."),
            ]
          ])!
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    do {
      // paragraph -> apply -> argument -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓0,⇒0,↓0]", "Go".length)!
      // paragraph -> apply -> argument -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓0,⇒0]", 2)!

      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          ├ text "od "
          └ emph
            └ text "job"
          """)
    }

    do {
      // paragraph -> apply -> #0 -> apply -> #0 -> text -> <offset>
      let location = TextLocation.compose("[↓1,↓0,⇒0,↓0,⇒0,↓0]", "S".length)!
      let endLocation = TextLocation.compose("[↓1,↓0,⇒0,↓0,⇒0,↓0]", "Sample".length)!

      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          └ text "ample"
          """)
    }

    do {
      let location = TextLocation.compose("[↓1,↓0,⇒0]", 0)!
      let endLocation = TextLocation.compose("[↓1,↓0,⇒0,↓1]", " t".length)!

      let range = RhTextRange(location, endLocation)!
      let content = try self.copyContents(in: range, documentManager)
      #expect(
        content.prettyPrint() == """
          content
          ├ template(doubleText)
          │ ├ argument #0 (x2)
          │ └ expansion
          │   ├ text "{"
          │   ├ variable #0
          │   │ └ text "Sample"
          │   ├ text " and "
          │   ├ emph
          │   │ └ variable #0
          │   │   └ text "Sample"
          │   └ text "}"
          └ text " t"
          """)
    }
  }

  // Helper

  private func testPairs(
    _ locations: Array<TextLocation>, _ endLocations: Array<TextLocation>,
    _ expectedContents: [Array<String>],
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
