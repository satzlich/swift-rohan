// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct ApplyNodeTests {
  @Test
  static func test_newtonsLaw() {
    guard let newtonsLaw = ApplyNode(TemplateSample.newtonsLaw, [])
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
               │  └ text "F"
               └ denominator
                  └ text "m"
        """)

    let copy = newtonsLaw.deepCopy()
    #expect(copy.prettyPrint() == newtonsLaw.prettyPrint())
  }

  @Test
  static func test_philipFox() {
    guard let philipFox = ApplyNode(TemplateSample.philipFox, [[], []])
    else {
      Issue.record("Failed to create ApplyNode for philipFox")
      return
    }

    philipFox.getArgument(0).insertChildren(contentsOf: [TextNode("Philip")], at: 0)
    philipFox.getArgument(1).insertChildren(contentsOf: [TextNode("fox")], at: 0)

    #expect(
      philipFox.prettyPrint() == """
        template(philipFox)
         ├ argument #0 (x2)
         │  ├ variable #0
         │  │  └ text "Philip"
         │  └ variable #0
         │     └ text "Philip"
         ├ argument #1 (x1)
         │  └ variable #1
         │     └ text "fox"
         └ content
            ├ variable #0
            │  └ text "Philip"
            ├ text " is a good "
            ├ emphasis
            │  └ variable #1
            │     └ text "fox"
            ├ text ", is "
            ├ variable #0
            │  └ text "Philip"
            └ text "?"
        """)

    let copy = philipFox.deepCopy()
    #expect(copy.prettyPrint() == philipFox.prettyPrint())
  }

  @Test
  static func test_convertTemplateBody() {
    guard
      let (contentNode, argumentNodes) = NodeUtils.applyTemplate(TemplateSample.newtonsLaw, [])
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
            │  └ text "F"
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
        TemplateSample.philipFox, [[TextNode("Philip")], [TextNode("fox")]])
    else {
      Issue.record("applyTemplate failed")
      return
    }

    #expect(
      contentNode.prettyPrint() == """
        content
         ├ variable #0
         │  └ text "Philip"
         ├ text " is a good "
         ├ emphasis
         │  └ variable #1
         │     └ text "fox"
         ├ text ", is "
         ├ variable #0
         │  └ text "Philip"
         └ text "?"
        """)
    #expect(argumentNodes.count == 2)
    #expect(
      argumentNodes[0].prettyPrint() == """
        argument #0 (x2)
         ├ variable #0
         │  └ text "Philip"
         └ variable #0
            └ text "Philip"
        """)
    #expect(
      argumentNodes[1].prettyPrint() == """
        argument #1 (x1)
         └ variable #1
            └ text "fox"
        """)
  }
}
