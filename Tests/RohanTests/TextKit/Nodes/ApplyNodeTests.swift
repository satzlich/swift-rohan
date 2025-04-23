// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ApplyNodeTests {
  @Test
  static func test_newtonsLaw() {
    guard let newtonsLaw = ApplyNode(CompiledSamples.newtonsLaw, [])
    else {
      Issue.record("Failed to create ApplyNode for newtonsLaw")
      return
    }

    // pretty print
    #expect(
      newtonsLaw.prettyPrint() == """
        template(newton)
        └ content
          ├ text "a="
          └ fraction
            ├ num
            │ └ text "F"
            └ denominator
              └ text "m"
        """)

    // deep copy
    let copy = newtonsLaw.deepCopy()
    #expect(copy.prettyPrint() == newtonsLaw.prettyPrint())

    // stringify
    #expect(newtonsLaw.stringify() == "a=(F)/(m)")
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

    // pretty print
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

    // deep copy
    let copy = philipFox.deepCopy()
    #expect(copy.prettyPrint() == philipFox.prettyPrint())

    // stringify

    #expect(philipFox.stringify() == "Philip is a good fox, is Philip?")
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

    let expectedPrint =
      """
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
      """

    #expect(doubleText.prettyPrint() == expectedPrint)

    // deep copy
    let copy = doubleText.deepCopy()
    #expect(copy.prettyPrint() == expectedPrint)

    // stringify
    #expect(doubleText.stringify() == "{{fox and fox} and {fox and fox}}")
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

    let expectedPrint =
      """
      template(complexFraction)
      ├ argument #0 (x2)
      ├ argument #1 (x2)
      └ content
        └ fraction
          ├ num
          │ └ fraction
          │   ├ num
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
      """

    #expect(complexFraction.prettyPrint() == expectedPrint)

    // deep copy
    let copy = complexFraction.deepCopy()
    #expect(copy.prettyPrint() == expectedPrint)

    // stringify
    #expect(complexFraction.stringify() == "((y+1)/(x+1))/(x+y+1)")
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
        content
        ├ text "a="
        └ fraction
          ├ num
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
    #expect(argumentNodes[0].prettyPrint() == "argument #0 (x2)")
    #expect(argumentNodes[1].prettyPrint() == "argument #1 (x1)")
  }
}
