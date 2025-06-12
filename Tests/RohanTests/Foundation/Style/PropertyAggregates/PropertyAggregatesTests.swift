// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct PropertyAggregatesTests {

  private func coverageTest<T: PropertyAggregate>(_ type: T.Type) {
    let stylesheet = StyleSheets.newComputerModern(12)
    _ = stylesheet.resolveDefault() as T
  }

  @Test
  func coverage() {
    coverageTest(MathProperty.self)
    coverageTest(PageProperty.self)
    coverageTest(ParagraphProperty.self)
    coverageTest(TextProperty.self)
    coverageTest(InternalProperty.self)
  }

  @Test
  func mathProperty() {
    let font = Font.createWithName("STIX Two Math", 10)
    let mathContext = MathContext(font, .display, false, .black)!

    let textProperty = TextProperty(
      font: "STIX Two Text", size: 10, stretch: .normal, style: .normal, weight: .regular,
      foregroundColor: .black)

    func createValue(bold: Bool, italic: Bool?, _ variant: MathVariant) -> MathProperty {
      MathProperty(
        font: "STIX Two Math", bold: bold, italic: italic, cramped: false, style: .script,
        variant: variant)
    }

    for variant in MathVariant.allCases {
      for (bold, italic) in product([true, false], [true, false, nil]) {
        let mathProperty = createValue(bold: bold, italic: italic, variant)
        _ = mathProperty.getAttributes(isFlipped: false, textProperty, mathContext)
      }
    }
  }

  @Test
  func textProperty() {
    let textProperty = TextProperty(
      font: "Nonexisting", size: 10, stretch: .normal, style: .normal, weight: .regular,
      foregroundColor: .black)
    _ = textProperty.getAttributes(isFlipped: false)
  }
}
