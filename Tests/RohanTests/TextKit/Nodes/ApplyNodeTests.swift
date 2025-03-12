// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct ApplyNodeTests {
  @Test
  static func test_newtonsLaw() {
    guard let newtonsLaw = ApplyNode(CompiledSamples.newtonsLaw, [])
    else {
      Issue.record("Failed to create ApplyNode for newtonsLaw")
      return
    }

    #expect(
      newtonsLaw.prettyPrint() == """
        template(newton)
        └ content
          ├ text "a="
          └ fraction
            ├ numerator
            │ └ text "F"
            └ denominator
              └ text "m"
        """)

    let copy = newtonsLaw.deepCopy()
    #expect(copy.prettyPrint() == newtonsLaw.prettyPrint())
  }

  @Test
  static func test_philipFox() {
    guard let philipFox = ApplyNode(CompiledSamples.philipFox, [[], []])
    else {
      Issue.record("Failed to create ApplyNode for philipFox")
      return
    }

    philipFox.getArgument(0)
      .insertChildren(contentsOf: [TextNode("Philip")], at: 0, inStorage: false)
    philipFox.getArgument(1)
      .insertChildren(contentsOf: [TextNode("fox")], at: 0, inStorage: false)

    #expect(
      philipFox.prettyPrint() == """
        template(philipFox)
        ├ argument #0 (x2)
        ├ argument #1 (x1)
        └ content
          ├ variable #0
          │ └ text "Philip"
          ├ text " is a good "
          ├ emphasis
          │ └ variable #1
          │   └ text "fox"
          ├ text ", is "
          ├ variable #0
          │ └ text "Philip"
          └ text "?"
        """)

    let copy = philipFox.deepCopy()
    #expect(copy.prettyPrint() == philipFox.prettyPrint())
  }

  @Test
  static func test_doubleText() {
    guard
      let doubleText = ApplyNode(
        CompiledSamples.doubleText,
        [
          [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
        ])
    else {
      Issue.record("Failed to create ApplyNode for doubleText")
      return
    }

    #expect(
      doubleText.prettyPrint() == """
        template(doubleText)
        ├ argument #0 (x2)
        └ content
          ├ text "{"
          ├ variable #0
          │ └ template(doubleText)
          │   ├ argument #0 (x2)
          │   └ content
          │     ├ text "{"
          │     ├ variable #0
          │     │ └ text "fox"
          │     ├ text " and "
          │     ├ emphasis
          │     │ └ variable #0
          │     │   └ text "fox"
          │     └ text "}"
          ├ text " and "
          ├ emphasis
          │ └ variable #0
          │   └ template(doubleText)
          │     ├ argument #0 (x2)
          │     └ content
          │       ├ text "{"
          │       ├ variable #0
          │       │ └ text "fox"
          │       ├ text " and "
          │       ├ emphasis
          │       │ └ variable #0
          │       │   └ text "fox"
          │       └ text "}"
          └ text "}"
        """)
  }

  @Test
  static func test_complexFraction() {
    guard
      let complexFraction = ApplyNode(
        CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])
    else {
      Issue.record("Failed to create ApplyNode for complexFraction")
      return
    }

    #expect(
      complexFraction.prettyPrint() == """
        template(complexFraction)
        ├ argument #0 (x2)
        ├ argument #1 (x2)
        └ content
          └ fraction
            ├ numerator
            │ └ fraction
            │   ├ numerator
            │   │ ├ variable #1
            │   │ │ └ text "y"
            │   │ └ text "+1"
            │   └ denominator
            │     ├ variable #0
            │     │ └ text "x"
            │     └ text "+1"
            └ denominator
              ├ variable #0
              │ └ text "x"
              ├ text "+"
              ├ variable #1
              │ └ text "y"
              └ text "+1"
        """)
  }

  @Test
  static func test_convertTemplateBody() {
    guard
      let (contentNode, argumentNodes) = NodeUtils.applyTemplate(CompiledSamples.newtonsLaw, [])
    else {
      Issue.record("applyTemplate failed")
      return
    }

    #expect(
      contentNode.prettyPrint() == """
        content
        ├ text "a="
        └ fraction
          ├ numerator
          │ └ text "F"
          └ denominator
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
        content
        ├ variable #0
        │ └ text "Philip"
        ├ text " is a good "
        ├ emphasis
        │ └ variable #1
        │   └ text "fox"
        ├ text ", is "
        ├ variable #0
        │ └ text "Philip"
        └ text "?"
        """)
    #expect(argumentNodes.count == 2)
    #expect(
      argumentNodes[0].prettyPrint() == "argument #0 (x2)")
    #expect(
      argumentNodes[1].prettyPrint() == "argument #1 (x1)")
  }
}
