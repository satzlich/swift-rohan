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
}
