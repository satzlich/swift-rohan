// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct PropertyValueTypeTests {
    static let a: PropertyValueType = .none
    static let b: PropertyValueType = .auto
    static let c: PropertyValueType = .bool

    static let w: PropertyValueType = .sum([a])
    static let x: PropertyValueType = .sum([b, c])
    static let y: PropertyValueType = .sum([a, .sum([c])])
    static let z: PropertyValueType = .sum([])

    @Test
    static func isEmpty() {
        // z is empty
        #expect(!a.isEmpty)
        #expect(!b.isEmpty)
        #expect(!c.isEmpty)
        #expect(!w.isEmpty)
        #expect(!x.isEmpty)
        #expect(!y.isEmpty)
        #expect(z.isEmpty)
    }

    @Test
    static func isSimple() {
        // a, b, c, w are simple;

        #expect(a.isSimple)
        #expect(b.isSimple)
        #expect(c.isSimple)
        #expect(w.isSimple)
        #expect(!x.isSimple)
        #expect(!y.isSimple)
    }

    @Test
    static func isSubset() {
        // reflexive
        #expect(a.isSubset(of: a))
        #expect(b.isSubset(of: b))
        #expect(c.isSubset(of: c))
        #expect(w.isSubset(of: w))
        #expect(x.isSubset(of: x))
        #expect(y.isSubset(of: y))
        #expect(z.isSubset(of: z))

        // nil
        #expect(z.isSubset(of: a))
        #expect(z.isSubset(of: x))
        #expect(!a.isSubset(of: z))
        #expect(!x.isSubset(of: z))

        // simple vs simple
        #expect(!a.isSubset(of: b))

        // simple vs sum
        #expect(a.isSubset(of: w))
        #expect(!b.isSubset(of: w))

        // simple vs nested sum
        #expect(a.isSubset(of: y))
        #expect(!b.isSubset(of: y))

        // sum vs simple
        #expect(w.isSubset(of: a))
        #expect(!x.isSubset(of: a))
        #expect(!y.isSubset(of: a))
        #expect(z.isSubset(of: a))

        // sum vs sum
        #expect(!w.isSubset(of: x))
        #expect(w.isSubset(of: y))
    }
}
