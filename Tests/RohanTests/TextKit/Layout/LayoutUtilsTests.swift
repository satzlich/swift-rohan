// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class LayoutUtilsTests: MathLayoutTestsBase {

  init() throws {
    try super.init(mathFont: "Latin Modern Math")
  }

  @Test
  func coverage() {
    // lmoustache, rgroup
    guard let delimiters = DelimiterPair("\u{23B0}", "\u{27EF}") else {
      Issue.record("Failed to create delimiter pair")
      return
    }
    let result = LayoutUtils.layoutDelimiters(delimiters, 40, shortfall: 0, context)
  }
}
