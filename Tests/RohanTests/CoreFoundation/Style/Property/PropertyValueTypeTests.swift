import Foundation
import Testing

@testable import SwiftRohan

struct PropertyValueTypeTests {
  static let a: PropertyValueType = .none
  static let b: PropertyValueType = .bool
  static let c: PropertyValueType = .integer

  static let x: PropertyValueType = .sum([a, c])
  static let y: PropertyValueType = .sum([b, c])
  static let z: PropertyValueType = .sum([a, b, c])

  @Test
  static func test_isSimple() {
    #expect(a.isSimple)
    #expect(!x.isSimple)
  }

  @Test
  static func test_isSubset() {
    // reflexive
    #expect(a.isSubset(of: a))
    #expect(x.isSubset(of: x))

    // simple vs simple
    #expect(!a.isSubset(of: b))

    // simple vs sum
    #expect(a.isSubset(of: x))
    #expect(!b.isSubset(of: x))

    // sum vs simple
    #expect(!x.isSubset(of: a))

    // sum vs sum
    #expect(!x.isSubset(of: y))
    #expect(x.isSubset(of: z))
  }
}
