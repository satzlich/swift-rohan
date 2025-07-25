import Testing

@testable import SwiftRohan

final class LayoutUtilsTests: MathLayoutTestsBase {

  init() throws {
    try super.init(mathFont: "Latin Modern Math")
  }

  private func _testDelimiters(_ left: Character, _ right: Character) {
    guard let delimiters = DelimiterPair(left, right) else {
      Issue.record("Failed to create delimiter pair")
      return
    }
    _ = LayoutUtils.layoutDelimiters(delimiters, 40, shortfall: 0, context)
  }

  @Test
  func coverage() {
    let openings: Array<Character> = [
      "\u{0028}", "\u{005b}", "\u{007b}",
      "\u{2308}", "\u{230a}", "\u{231c}",
      "\u{231e}", "\u{2772}", "\u{27e6}",
      "\u{27e8}", "\u{27ea}", "\u{27ec}",
      "\u{27ee}", "\u{2983}", "\u{2985}",
      "\u{2987}", "\u{2989}", "\u{298b}",
      "\u{298d}", "\u{298f}", "\u{2991}",
      "\u{2993}", "\u{2995}", "\u{2997}",
      "\u{29d8}", "\u{29da}", "\u{29fc}",
      // misclassified below
      "\u{23b0}",
    ]
    let fences: Array<Character> = [
      "\u{007c}", "\u{2016}", "\u{2980}",
      "\u{2982}", "\u{2999}", "\u{299a}",
    ]

    _testDelimiters("\u{23B0}", "\u{27EF}")  // ⎰⟯
    _testDelimiters("\u{27EE}", "\u{23B1}")  // ⟮⎱

    // NOTE: STIX Two Math covers all these.
    for opening in openings {
      for fence in fences {
        _testDelimiters(opening, fence)
      }
    }
  }
}
