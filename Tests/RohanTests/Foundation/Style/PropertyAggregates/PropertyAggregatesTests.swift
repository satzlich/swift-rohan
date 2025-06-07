// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct PropertyAggregatesTests {

  private func coverageTest<T: PropertyAggregate>(_ type: T.Type) {
    let stylesheet = StyleSheets.latinModern(12)
    let property = stylesheet.resolveDefault() as T

    _ = property.getProperties()
    _ = property.getAttributes()
  }

  @Test
  func coverage() {
    coverageTest(MathProperty.self)
    coverageTest(PageProperty.self)
    coverageTest(ParagraphProperty.self)
    coverageTest(TextProperty.self)
    coverageTest(InternalProperty.self)
  }

}
