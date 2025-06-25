// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

final class MathListLayoutFragmentTests: MathLayoutTestsBase {

  @Test
  func emptyMathList() {
    let mathList = MathListLayoutFragment(context)
    _ = mathList.isSpaced

    // insert and delete to obtain an empty math list
    do {
      guard let x = createGlyphFragment("x"),
        let y = createGlyphFragment("y")
      else {
        Issue.record("Failed to create glyph fragment")
        return
      }
      mathList.beginEditing()
      mathList.insert(x, at: 0)
      mathList.insert(y, at: 1)
      mathList.removeSubrange(0..<2)
      mathList.endEditing()
      mathList.fixLayout(context)
    }

    #expect(mathList.getSegmentFrame(0) == SegmentFrame(.zero, 0))

    // test enumerateTextSegments()
    do {
      var rect: CGRect? = nil
      var baseline: CGFloat = 0

      let shouldContinue =
        mathList.enumerateTextSegments(
          0..<0, context.cursorHeight(), type: .standard, options: []
        ) {
          (_, frame, baselinePosition) in
          rect = frame
          baseline = baselinePosition
          return false  // stop
        }

      #expect(shouldContinue == false)
      #expect(rect != nil)
      #expect(baseline.isNearlyEqual(to: 7.6200154))
    }

    #expect(mathList.cursorDistanceThroughUpstream(0) == 0)
  }

  @Test
  func moreMathList() {
    guard let mathList = createMathListFragment("x+y-z"),
      let w = createGlyphFragment("w")
    else {
      Issue.record("Failed to create math list fragment")
      return
    }

    //
    mathList.beginEditing()
    mathList.insert(w, at: 5)  // ensure startIndex in fixLayout() is non-zero.
    mathList.endEditing()
    mathList.fixLayout(context)

    //
    #expect(mathList.count == 6)
    #expect(mathList.getSegmentFrame(6) != nil)  // layout offset == count
    #expect(mathList.getSegmentFrame(7) == nil)  // layout offset > count

    //
    #expect(mathList.getLayoutRange(interactingAt: CGPoint(x: -10, y: 5)) == (0..<0, 0))
    #expect(mathList.getLayoutRange(interactingAt: CGPoint(x: 10000, y: 5)) == (6..<6, 0))

    //
    mathList.beginEditing()
    #expect(mathList.index(0, llOffsetBy: 3) == 3)
    mathList.endEditing()
  }

  @Test
  func cursorDistance_edgeCases() {
    guard let mathList = createMathListFragment("x+(y-z)") else {
      Issue.record("Failed to create math list fragment")
      return
    }
    mathList.markDirty(0)
    mathList.fixLayout(context)

    // cursor position between "+" and "(" is middle.
    #expect(mathList.cursorDistanceThroughUpstream(2).isNearlyEqual(to: 16.2233333))
  }
}
