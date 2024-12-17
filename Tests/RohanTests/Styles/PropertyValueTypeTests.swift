// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct PropertyValueTypeTests {
    static let a: PropertyValueType = .none
    static let b: PropertyValueType = .auto
    static let c: PropertyValueType = .bool

    static let x: PropertyValueType = .sum([a, c])
    static let y: PropertyValueType = .sum([b, c])
    static let z: PropertyValueType = .sum([a, b, c])

    @Test
    static func isSimple() {
        #expect(a.isSimple)
        #expect(!x.isSimple)
    }

    @Test
    static func isSubset() {
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
