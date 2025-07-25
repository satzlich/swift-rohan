import Testing

@testable import SwiftRohan

struct FragmentFactoryTests {
  @Test
  func coverage() {
    let font = Font.createWithName("Latin Modern Math", 10, isFlipped: true)
    let mathContext = MathContext(font, .display, false, Color.black)!
    var factory = FragmentFactory(mathContext)
    let mathProperty = MathProperty(
      font: "Latin Modern Math", bold: false, italic: nil, cramped: false,
      style: .script, variant: .bb)

    do {
      _ = factory.resolveCharacter("x", mathProperty)
      _ = factory.makeFragments(from: "x+y-z", mathProperty)
      _ = factory.replacementGlyph(3)
      // prime
      _ = factory.makeFragments(from: "\u{2032}", mathProperty)
      _ = factory.makeFragments(from: "\u{2057}", mathProperty)
      // fallback
      _ = factory.makeFragments(from: "碐", mathProperty)
    }
  }
}
