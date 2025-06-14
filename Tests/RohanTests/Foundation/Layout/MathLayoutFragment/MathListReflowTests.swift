// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

final class MathListReflowTests: MathLayoutTestsBase {
  private func reflowExample(
    _ fragments: Array<MathLayoutFragment>
  ) -> MathListLayoutFragment {
    let mathList = MathListLayoutFragment(context)

    mathList.beginEditing()
    mathList.insert(contentsOf: fragments, at: 0)
    mathList.endEditing()
    mathList.fixLayout(context)
    #expect(mathList.reflowSegmentCount == 0)
    mathList.performReflow()

    return mathList
  }

  @Test
  func reflowEmpty() {
    let mathList = reflowExample([])
    #expect(mathList.reflowSegmentCount == 0)
  }

  @Test
  func reflowMultiFragments() {
    let glyphs = "x+y=+zw".compactMap { createGlyphFragment($0, styled: false) }
    let mathList = reflowExample(glyphs)

    #expect(mathList.count == 7)
    #expect(mathList.reflowSegmentCount == 3)

    let reflowSegments = mathList.reflowSegments
    do {
      let width = reflowSegments.map(\.width).reduce(0, +)
      #expect(width.isNearlyEqual(to: mathList.width))

      let layoutLength = reflowSegments.map(\.offsetRange.count).reduce(0, +)
      #expect(layoutLength == mathList.contentLayoutLength)

      for fragment in reflowSegments {
        MathLayoutFragmentsTests.callStandardMethods(fragment, context)
      }
    }

    do {
      let segment = reflowSegments[0]
      #expect(segment.range == 0..<2)
      #expect(segment.offsetRange == 0..<2)
      #expect(segment.fragmentIndex(0) == 0)
      #expect(segment.fragmentIndex(1) == 1)
      #expect(segment.fragmentIndex(2) == 2)
      #expect(segment.distanceThroughSegment(0) == 0)
      #expect(segment.distanceThroughSegment(1).isNearlyEqual(to: 7.0122222))
      #expect(segment.distanceThroughSegment(2).isNearlyEqual(to: 14.21222222))
      #expect(segment.cursorDistanceThroughSegment(0) == 0)
      #expect(segment.cursorDistanceThroughSegment(1).isNearlyEqual(to: 4.79))
      #expect(segment.cursorDistanceThroughSegment(2).isNearlyEqual(to: 16.43444444))
      //
      #expect(segment.equivalentPosition(0) == 0)
    }
    do {
      let segment = reflowSegments[1]
      #expect(segment.range == 2..<4)
      #expect(segment.offsetRange == 2..<4)
      #expect(segment.fragmentIndex(2) == 2)
      #expect(segment.fragmentIndex(3) == 3)
      #expect(segment.fragmentIndex(4) == 4)
      #expect(segment.distanceThroughSegment(2) == 0)
      #expect(segment.distanceThroughSegment(3).isNearlyEqual(to: 7.6077777))
      #expect(segment.distanceThroughSegment(4).isNearlyEqual(to: 14.8077777))
      #expect(segment.cursorDistanceThroughSegment(2) == 0)
      #expect(segment.cursorDistanceThroughSegment(3).isNearlyEqual(to: 4.82999999))
      #expect(segment.cursorDistanceThroughSegment(4).isNearlyEqual(to: 16.19666666))
      //
      #expect(segment.equivalentPosition(0).isNearlyEqual(to: 16.434444444))
    }
    do {
      let segment = reflowSegments[2]
      #expect(segment.range == 4..<7)
      #expect(segment.offsetRange == 4..<7)
      #expect(segment.fragmentIndex(3) == 4)
      #expect(segment.fragmentIndex(4) == 4)
      #expect(segment.fragmentIndex(5) == 5)
      #expect(segment.fragmentIndex(6) == 6)
      #expect(segment.fragmentIndex(7) == 7)
      #expect(segment.fragmentIndex(8) == 7)
      #expect(segment.distanceThroughSegment(4).isNearlyEqual(to: 1.38888888))
      #expect(segment.distanceThroughSegment(5).isNearlyEqual(to: 8.58888888))
      #expect(segment.distanceThroughSegment(6).isNearlyEqual(to: 13.1688888))
      #expect(segment.distanceThroughSegment(7).isNearlyEqual(to: 20.6588888))
      #expect(segment.cursorDistanceThroughSegment(4) == 0)
      #expect(segment.cursorDistanceThroughSegment(5).isNearlyEqual(to: 8.5888888))
      #expect(segment.cursorDistanceThroughSegment(6).isNearlyEqual(to: 13.1688888))
      #expect(segment.cursorDistanceThroughSegment(7).isNearlyEqual(to: 20.65888888))
      //
      #expect(segment.equivalentPosition(0).isNearlyEqual(to: 32.63111111))
    }
  }
}
