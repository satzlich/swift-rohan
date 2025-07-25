import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct MathIndexTests {
  @Test
  func coverage() {
    for (lhs, rhs) in zip(MathIndex.allCases, MathIndex.allCases) {
      _ = lhs < rhs
    }

    for i in MathIndex.allCases {
      _ = "\(i)"
    }
  }

  @Test
  func parse() {
    for i in MathIndex.allCases {
      let str = "\(i)"
      let parsed = MathIndex.parse(str)
      #expect(parsed == i)
    }
    
    #expect(MathIndex.parse("invalid") == nil)
  }
}
