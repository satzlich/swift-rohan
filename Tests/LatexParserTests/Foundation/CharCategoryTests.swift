import Foundation
import Testing

@testable import LatexParser

struct CharCategoryTests {
  @Test
  func coverage() {
    let strings = [
      #"\def\swap#1#2{{#2}{#1}} % swap parameters"#,
      #"""
      $$
      \begin{matrix}
      n^{2} & m_{1,2} \\
      n_{1,2} & m^{2}
      \end{matrix}
      $$
      """#,
      "Theorem~1\u{0000} is a fundamental result in mathematics.",
    ]

    for string in strings {
      for char in string {
        _ = char.charCategory
      }
    }
  }
}
