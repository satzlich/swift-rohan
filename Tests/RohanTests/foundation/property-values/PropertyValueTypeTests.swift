// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValue))
struct PropertyValueTypeTests {
    static let a: PropertyValueType = .none
    static let b: PropertyValueType = .auto
    static let c: PropertyValueType = .bool

    static let w: PropertyValueType = .sum([a])
    static let x: PropertyValueType = .sum([b, c])
    static let y: PropertyValueType = .sum([a, .sum([c])])
    static let z: PropertyValueType = .sum([])

    static let ww: PropertyValueType = w.flattened()!
    static let xx: PropertyValueType = x.flattened()!
    static let yy: PropertyValueType = y.flattened()!

    @Test
    static func isSimple() {
        // a, b, c are simple;
        // w, x, y are not.
        #expect(a.isSimple())
        #expect(b.isSimple())
        #expect(c.isSimple())
        #expect(!w.isSimple())
        #expect(!x.isSimple())
        #expect(!y.isSimple())
    }

    @Test
    static func flattened_isFlattened() {
        // by definition of `isFlattened`
        #expect(a.flattened() == a)
        #expect(b.flattened() == b)
        #expect(c.flattened() == c)
        #expect(w.flattened() != w)
        #expect(x.flattened() == x)
        #expect(y.flattened() != y)
        #expect(z.flattened() == nil)

        // a, b, c, x are flattened;
        // w, y, z are not.
        #expect(a.isFlattened())
        #expect(b.isFlattened())
        #expect(c.isFlattened())
        #expect(!w.isFlattened())
        #expect(x.isFlattened())
        #expect(!y.isFlattened())
        #expect(!z.isFlattened())
    }

    @Test
    static func isSubset() {
        // self comparison
        #expect(a.isSubset(of: a))
        #expect(b.isSubset(of: b))
        #expect(c.isSubset(of: c))
        #expect(w.isSubset(of: w))
        #expect(x.isSubset(of: x))
        #expect(y.isSubset(of: y))
        #expect(z.isSubset(of: z))
        #expect(ww.isSubset(of: ww))
        #expect(xx.isSubset(of: xx))
        #expect(yy.isSubset(of: yy))

        do {
            // simple vs simple
            #expect(!a.isSubset(of: b))

            // simple vs sum
            #expect(a.isSubset(of: w))
            #expect(!b.isSubset(of: w))

            // simple vs nested sum
            #expect(a.isSubset(of: y))
            #expect(!b.isSubset(of: y))

            // simple vs nested sum (flattened)
            #expect(a.isSubset(of: yy))
            #expect(!b.isSubset(of: yy))
        }

        do {
            // sum vs simple
            #expect(w.isSubset(of: a))
            #expect(!x.isSubset(of: a))
            #expect(!y.isSubset(of: a))

            #expect(z.isSubset(of: a))

            // sum (flattened) vs simple
            #expect(ww.isSubset(of: a))
            #expect(!xx.isSubset(of: a))
            #expect(!yy.isSubset(of: a))
        }

        do {
            // sum vs sum
            #expect(!w.isSubset(of: x))
            #expect(w.isSubset(of: y))

            // sum vs sum (flattened)
            #expect(!ww.isSubset(of: xx))
            #expect(ww.isSubset(of: yy))
        }

        // sum vs sum (mixed)
        #expect(y.isSubset(of: yy))
        #expect(yy.isSubset(of: y))
    }
}
