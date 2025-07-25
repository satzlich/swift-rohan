import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct LimitsTests {
  @Test
  func isActive_in() {
    let limits = Limits.allCases
    let mathStyles = MathStyle.allCases

    for (limit, mathStyle) in product(limits, mathStyles) {
      _ = limit.isActive(in: mathStyle)
    }
  }

  @Test
  func defaultValue_forChar() {
    // Large
    #expect(UnicodeScalar("∫").mathClass == .Large)
    #expect(Limits.defaultValue(forChar: "∫") == .never)

    #expect(UnicodeScalar("∑").mathClass == .Large)
    #expect(Limits.defaultValue(forChar: "∑") == .display)

    // Relation
    #expect(UnicodeScalar("<").mathClass == .Relation)
    #expect(Limits.defaultValue(forChar: "<") == .never)

    // Alphabetic
    #expect(UnicodeScalar("c").mathClass == .Alphabetic)
    #expect(Limits.defaultValue(forChar: "c") == .never)
  }

  @Test
  func defaultValue_forMathClass() {
    #expect(Limits.defaultValue(forMathClass: .Large) == .display)
    #expect(Limits.defaultValue(forMathClass: .Relation) == .never)
    #expect(Limits.defaultValue(forMathClass: .Alphabetic) == .never)
  }
}
