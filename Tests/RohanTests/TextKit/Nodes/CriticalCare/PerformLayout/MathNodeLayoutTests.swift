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
}
