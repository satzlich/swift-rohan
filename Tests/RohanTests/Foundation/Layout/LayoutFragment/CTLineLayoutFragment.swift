// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct CTLineLayoutFragmentTests {
  @Test
  func coverage() {
    var fragments: Array<CTLineLayoutFragment> = []
    let styleSheet = StyleSheetTests.testingStyleSheet()

    let textNode = TextNode("abc")
    do {
      let fragment =
        CTLineLayoutFragment.createTextMode(textNode, styleSheet, .imageBounds)
      fragments.append(fragment)
    }
    do {
      let fragment =
        CTLineLayoutFragment.createTextMode(
          "def", textNode, styleSheet, .typographicBounds)
      fragments.append(fragment)
    }
  }
}
