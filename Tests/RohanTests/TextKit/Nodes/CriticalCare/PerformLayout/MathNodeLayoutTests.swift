// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

struct MathNodeLayoutTests {
  @Test
  func mathNodes_fromScratch() {
    let mathNodes: [MathNode] = MathNodeTests.allSamples()
    let styleSheet = StyleSheetTests.sampleStyleSheet()
    let contentNode = ContentNode(mathNodes)
    let mathContext = MathUtils.resolveMathContext(for: contentNode, styleSheet)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(styleSheet, mathContext, fragment)
    context.beginEditing()
    contentNode.performLayout(context, fromScratch: true)
    context.endEditing()
  }

  private func createTestScene<T: MathNode>(
    _ node: T
  ) -> (ContentNode, MathListLayoutContext) {
    let styleSheet = StyleSheetTests.sampleStyleSheet()
    let contentNode = ContentNode([node])
    let mathContext = MathUtils.resolveMathContext(for: contentNode, styleSheet)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(styleSheet, mathContext, fragment)
    context.beginEditing()
    contentNode.performLayout(context, fromScratch: true)
    context.endEditing()
    return (contentNode, context)
  }

  private func performLayout(
    _ context: MathListLayoutContext, _ contentNode: ContentNode
  ) {
    context.resetCursor()
    context.beginEditing()
    contentNode.performLayout(context, fromScratch: false)
    context.endEditing()
  }

  @Test
  func accent() {
    let accentNode = AccentNode(.overleftarrow, nucleus: [TextNode("x")])
    let (contentNode, context) = createTestScene(accentNode)
    do {
      accentNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      accentNode.nucleus.replaceChild(TextNode("xz"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func attach() {
    let attachNode = AttachNode(
      nuc: [TextNode("a")], lsub: [TextNode("1")], lsup: [TextNode("2")],
      sub: [TextNode("3")], sup: [TextNode("4")]
    )
    let (contentNode, context) = createTestScene(attachNode)
    // dirty
    do {
      attachNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      attachNode.lsub!.replaceChild(TextNode("5"), at: 0, inStorage: true)
      attachNode.lsup!.replaceChild(TextNode("6"), at: 0, inStorage: true)
      attachNode.sub!.replaceChild(TextNode("7"), at: 0, inStorage: true)
      attachNode.sup!.replaceChild(TextNode("8"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // dirty
    do {
      attachNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // modified
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.removeComponent(.lsup, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.addComponent(.lsub, [TextNode("9")], inStorage: true)
      attachNode.addComponent(.lsup, [TextNode("10")], inStorage: true)
      attachNode.removeComponent(.sub, inStorage: true)
      attachNode.removeComponent(.sup, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.removeComponent(.lsup, inStorage: true)
      attachNode.addComponent(.sub, [TextNode("11")], inStorage: true)
      attachNode.addComponent(.sup, [TextNode("12")], inStorage: true)
      performLayout(context, contentNode)
    }
    // modified + dirty
    do {
      attachNode.addComponent(.lsub, [TextNode("9")], inStorage: true)
      attachNode.addComponent(.lsup, [TextNode("10")], inStorage: true)
      attachNode.sub!.replaceChild(TextNode("13"), at: 0, inStorage: true)
      attachNode.sup!.replaceChild(TextNode("14"), at: 0, inStorage: true)
      attachNode.nucleus.replaceChild(TextNode("y"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.lsub!.replaceChild(TextNode("15"), at: 0, inStorage: true)
      attachNode.lsup!.replaceChild(TextNode("16"), at: 0, inStorage: true)
      attachNode.removeComponent(.sup, inStorage: true)
      attachNode.removeComponent(.sub, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.addComponent(.lsub, [TextNode("15")], inStorage: true)
      performLayout(context, contentNode)
    }
  }
}
