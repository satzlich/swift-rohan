// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Testing

@testable import SwiftRohan

struct CTLineLayoutContextTests {

  private func standardQueries<T: LayoutContext>(_ context1: T) {
    do {
      guard let segmentFrame = context1.getSegmentFrame(3, .downstream) else {
        Issue.record("Failed to get segment frame")
        return
      }
      #expect(segmentFrame.baselinePosition != 0)
    }
    do {
      var rect: CGRect? = nil
      var baseline: CGFloat = 0

      let shouldContinue =
        context1.enumerateTextSegments(3..<5, type: .standard, options: []) {
          (_, frame, baseline_) in

          rect = frame
          baseline = baseline_
          return false  // stop
        }

      #expect(rect != nil)
      #expect(baseline != 0)
      #expect(shouldContinue == false)
    }
    do {
      guard let range1 = context1.getLayoutRange(interactingAt: CGPoint(x: 10, y: 3)),
        let range2 = context1.getLayoutRange(interactingAt: CGPoint(x: 80, y: 5))
      else {
        Issue.record("Failed to get layout range")
        return
      }
      #expect(range1.layoutRange.isEmpty == false)
      #expect(range2.layoutRange.isEmpty)
    }
    do {
      guard
        let result1 = context1.rayshoot(from: 3, affinity: .downstream, direction: .up),
        let result2 = context1.rayshoot(from: 3, affinity: .downstream, direction: .down)
      else {
        Issue.record("Failed to rayshoot")
        return
      }

      #expect(result1.position.y < result2.position.y)
    }
    do {
      let result =
        context1.neighbourLineFrame(from: 3, affinity: .downstream, direction: .up)
      #expect(result == nil)
    }
  }

  @Test(
    "TextLineLayoutContext",
    arguments: [
      CTLineLayoutFragment.BoundsOption.typographicBounds,
      .imageBounds,
    ])
  func textLineLayoutContext(_ bounds: CTLineLayoutFragment.BoundsOption) {
    let context0 = TextLineLayoutContext(StyleSheetTests.testingStyleSheet(), bounds)

    // Edit
    let string = "Hello, World!"
    let textNode = TextNode(string)
    do {
      context0.beginEditing()
      context0.insertTextForward(textNode.string, textNode)
      context0.endEditing()
      #expect(context0.renderedString.string == string)
    }
    do {
      context0.resetCursorForForwardEditing()
      context0.beginEditing()
      context0.invalidateForward(5)
      context0.deleteForward(2)
      context0.skipForward(5)
      context0.deleteForward(1)
      context0.addParagraphStyle(textNode, 0..<10)
      context0.endEditing()
      #expect(context0.renderedString.string == "HelloWorld")
    }

    // Query
    let fragment = CTLineLayoutFragment(context0, bounds)
    let context1 = TextLineLayoutContext(context0.styleSheet, fragment)
    standardQueries(context1)
  }

  @Test
  func mathLineLayoutContext() {
    let font = Font.createWithName("Latin Modern Math", 10, isFlipped: true)
    let mathContext = MathContext(font, .display, false, Color.black)!
    let context0 = MathLineLayoutContext(StyleSheetTests.testingStyleSheet(), mathContext)

    // Edit
    let string = "a+b-c/w"
    let textNode = TextNode(string)
    do {
      context0.beginEditing()
      context0.insertTextForward(textNode.string, textNode)
      context0.endEditing()
      #expect(context0.renderedString.string == string)
    }
    do {
      context0.resetCursorForForwardEditing()
      context0.beginEditing()
      context0.skipForward(1)
      context0.deleteForward(1)
      context0.invalidateForward(3)
      context0.deleteForward(1)
      context0.addParagraphStyle(textNode, 0..<5)
      context0.endEditing()
      #expect(context0.renderedString.string == "ab-cw")
    }

    // Query

    let fragment = CTLineLayoutFragment(context0)
    let context1 = MathLineLayoutContext(context0.styleSheet, fragment, mathContext)
    standardQueries(context1)
  }
}
