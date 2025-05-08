// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TextPropertyTests {
  @Test
  func coverage() {
    let stylesheet = StyleSheets.latinModern(12)
    let property = stylesheet.resolveDefault() as TextProperty

    _ = property.getProperties()
    _ = property.getAttributes()
  }
}
