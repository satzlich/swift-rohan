// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathPropertyTests {
  @Test
  func coverage() {
    let stylesheet = StyleSheets.latinModern(12)
    let property = stylesheet.resolveDefault() as MathProperty

    _ = property.getProperties()
    _ = property.getAttributes()
  }
}
