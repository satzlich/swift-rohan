import Foundation
import Testing

@testable import SwiftRohan

struct ApplyNodeTests {
  @Test
  static func test_newtonsLaw() {
    guard let newtonsLaw = ApplyNode(MathTemplateSamples.newtonsLaw, [])
    else {
      Issue.record("Failed to create ApplyNode for newtonsLaw")
      return
    }

    // pretty print
    #expect(
      newtonsLaw.prettyPrint() == """
        template(newton)
        └ expansion
          ├ text "a="
          └ fraction
            ├ num
            │ └ text "F"
            └ denom
              └ text "m"
        """)

    // deep copy
    let copy = newtonsLaw.deepCopy()
    #expect(copy.prettyPrint() == newtonsLaw.prettyPrint())

  }

  @Test
  static func test_philipFox() {
    guard let philipFox = ApplyNode(MathTemplateSamples.philipFox, [[], []])
    else {
      Issue.record("Failed to create ApplyNode for philipFox")
      return
    }

    philipFox.getArgument(0)
      .insertChildren(contentsOf: [TextNode("Philip")], at: 0, inStorage: false)
    philipFox.getArgument(1)
      .insertChildren(contentsOf: [TextNode("fox")], at: 0, inStorage: false)

    // pretty print
    #expect(
      philipFox.prettyPrint() == """
        template(philipFox)
        ├ argument #0 (x2)
        ├ argument #1 (x1)
        └ expansion
          ├ variable #0
          │ └ text "Philip"
          ├ text " is a good "
          ├ emph
          │ └ variable #1
          │   └ text "fox"
          ├ text ", is "
          ├ variable #0
          │ └ text "Philip"
          └ text "?"
        """)

    // deep copy
    let copy = philipFox.deepCopy()
    #expect(copy.prettyPrint() == philipFox.prettyPrint())

    // stringify

  }

  @Test
  static func test_doubleText() {
    guard
      let doubleText = ApplyNode(
        MathTemplateSamples.doubleText,
        [
          [ApplyNode(MathTemplateSamples.doubleText, [[TextNode("fox")]])!]
        ])
    else {
      Issue.record("Failed to create ApplyNode for doubleText")
      return
    }

    let expectedPrint =
      """
      template(doubleText)
      ├ argument #0 (x2)
      └ expansion
        ├ text "{"
        ├ variable #0
        │ └ template(doubleText)
        │   ├ argument #0 (x2)
        │   └ expansion
        │     ├ text "{"
        │     ├ variable #0
        │     │ └ text "fox"
        │     ├ text " and "
        │     ├ emph
        │     │ └ variable #0
        │     │   └ text "fox"
        │     └ text "}"
        ├ text " and "
        ├ emph
        │ └ variable #0
        │   └ template(doubleText)
        │     ├ argument #0 (x2)
        │     └ expansion
        │       ├ text "{"
        │       ├ variable #0
        │       │ └ text "fox"
        │       ├ text " and "
        │       ├ emph
        │       │ └ variable #0
        │       │   └ text "fox"
        │       └ text "}"
        └ text "}"
      """

    #expect(doubleText.prettyPrint() == expectedPrint)

    // deep copy
    let copy = doubleText.deepCopy()
    #expect(copy.prettyPrint() == expectedPrint)

  }

  @Test
  static func test_complexFraction() {
    guard
      let complexFraction = ApplyNode(
        MathTemplateSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])
    else {
      Issue.record("Failed to create ApplyNode for complexFraction")
      return
    }

    let expectedPrint =
      """
      template(complexFraction)
      ├ argument #0 (x2)
      ├ argument #1 (x2)
      └ expansion
        └ fraction
          ├ num
          │ └ fraction
          │   ├ num
          │   │ ├ variable #1
          │   │ │ └ text "y"
          │   │ └ text "+1"
          │   └ denom
          │     ├ variable #0
          │     │ └ text "x"
          │     └ text "+1"
          └ denom
            ├ variable #0
            │ └ text "x"
            ├ text "+"
            ├ variable #1
            │ └ text "y"
            └ text "+1"
      """

    #expect(complexFraction.prettyPrint() == expectedPrint)

    // deep copy
    let copy = complexFraction.deepCopy()
    #expect(copy.prettyPrint() == expectedPrint)

  }

  @Test
  static func test_convertTemplateBody() {
    let result = NodeUtils.applyTemplate(CompiledSamples.newtonsLaw, [])
    guard let (contentNode, argumentNodes) = result
    else {
      Issue.record("applyTemplate failed")
      return
    }

    #expect(
      contentNode.prettyPrint() == """
        expansion
        ├ text "a="
        └ fraction
          ├ num
          │ └ text "F"
          └ denom
            └ text "m"
        """
    )
    #expect(argumentNodes.count == 0)
  }

  @Test
  static func test_applyTemplate() {
    // NOTE: hold argumentNodes, otherwise they will be deallocated and cause error
    guard
      let (contentNode, argumentNodes) = NodeUtils.applyTemplate(
        CompiledSamples.philipFox, [[TextNode("Philip")], [TextNode("fox")]])
    else {
      Issue.record("applyTemplate failed")
      return
    }

    #expect(
      contentNode.prettyPrint() == """
        expansion
        ├ variable #0
        │ └ text "Philip"
        ├ text " is a good "
        ├ emph
        │ └ variable #1
        │   └ text "fox"
        ├ text ", is "
        ├ variable #0
        │ └ text "Philip"
        └ text "?"
        """)
    #expect(argumentNodes.count == 2)
    #expect(argumentNodes[0].prettyPrint() == "argument #0 (x2)")
    #expect(argumentNodes[1].prettyPrint() == "argument #1 (x1)")
  }
}
