import Foundation
import Numerics
import Testing

@testable import SwiftRohan

struct AbsLengthTests {
  @Test
  func coverage() {
    do {
      _ = AbsLength.pt(10)
      _ = AbsLength.mm(10)
      _ = AbsLength.cm(10)
      _ = AbsLength.pica(10)
      _ = AbsLength.inch(10)
    }

    do {
      let value = AbsLength.pt(10)
      let eps = 1e-6

      #expect(value.ptValue == 10)
      #expect(value.mmValue.isNearlyEqual(to: 3.5277777, absoluteTolerance: eps))
      #expect(value.cmValue.isNearlyEqual(to: 0.3527777, absoluteTolerance: eps))
      #expect(value.picaValue.isNearlyEqual(to: 0.833333, absoluteTolerance: eps))
      #expect(value.inchValue.isNearlyEqual(to: 0.138888, absoluteTolerance: eps))
      #expect(value.isFinite)

      _ = "\(value)"
      _ = value.debugDescription
    }

    do {
      let a = AbsLength.pt(10)
      let b = AbsLength.pt(20)

      #expect(a < b)
      #expect(a - b == .pt(-10))
      #expect(a + b == .pt(30))
      #expect(AbsLength.zero == .pt(0))
      #expect(-a == .pt(-10))
      #expect(a * 2 == .pt(20))
      #expect(2 * a == .pt(20))
      #expect(a / 2 == .pt(5))
      #expect(a / b == 0.5)
    }

    do {
      let _: AbsLength = 10
      let _: AbsLength = 20.0
    }
  }
}
