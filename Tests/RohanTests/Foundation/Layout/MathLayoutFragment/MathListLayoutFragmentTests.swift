// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

final class MathListLayoutFragmentTests: MathLayoutTestsBase {
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
    #expect(mathList.getSegmentFrame(6) != nil)  // layout offset == count
    #expect(mathList.getSegmentFrame(7) == nil)  // layout offset > count
  }
}
