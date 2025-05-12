// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct PerformLayoutTests {

  @Test
  func elementNodes() {
    let elements: [ElementNode] = ElementNodeTests.allSamples()
    let styleSheet = StyleSheetTests.sampleStyleSheet()

    for element in elements {
      let context = TextLayoutContext(styleSheet)

      context.beginEditing()
      element.performLayout(context, fromScratch: true)
      context.endEditing()
    }
  }
}
