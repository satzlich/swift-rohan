// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct PropertyValueType_ {
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
        // a, b, c, ww are simple;

        #expect(a.isSimple())
        #expect(b.isSimple())
        #expect(c.isSimple())
        #expect(!w.isSimple())
        #expect(!x.isSimple())
        #expect(!y.isSimple())

        #expect(ww.isSimple())
        #expect(!xx.isSimple())
        #expect(!yy.isSimple())
    }

    @Test
    static func isValid() {
        // z is invalid.

        #expect(a.isValid())
        #expect(b.isValid())
        #expect(c.isValid())
        #expect(w.isValid())
        #expect(x.isValid())
        #expect(y.isValid())

        #expect(!z.isValid())

        #expect(ww.isValid())
        #expect(xx.isValid())
        #expect(yy.isValid())
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
        #expect(ww.isSubset(of: ww))
        #expect(xx.isSubset(of: xx))
        #expect(yy.isSubset(of: yy))

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

        // sum vs simple
        #expect(w.isSubset(of: a))
        #expect(!x.isSubset(of: a))
        #expect(!y.isSubset(of: a))
        #expect(z.isSubset(of: a))

        // sum (flattened) vs simple
        #expect(ww.isSubset(of: a))
        #expect(!xx.isSubset(of: a))
        #expect(!yy.isSubset(of: a))

        // sum vs sum
        #expect(!w.isSubset(of: x))
        #expect(w.isSubset(of: y))

        // sum vs sum (flattened)
        #expect(!ww.isSubset(of: xx))
        #expect(ww.isSubset(of: yy))

        // sum vs sum (mixed)
        #expect(y.isSubset(of: yy))
        #expect(yy.isSubset(of: y))
    }

    @Test
    static func isFlat_flattened() {
        // w, y, z are not flat.

        #expect(a.isFlat())
        #expect(b.isFlat())
        #expect(c.isFlat())
        #expect(!w.isFlat())
        #expect(x.isFlat())
        #expect(!y.isFlat())
        #expect(!z.isFlat())

        #expect(ww.isFlat())
        #expect(xx.isFlat())
        #expect(yy.isFlat())

        // by definition of `isFlat`

        #expect(a.flattened() == a)
        #expect(b.flattened() == b)
        #expect(c.flattened() == c)
        #expect(w.flattened() != w)
        #expect(x.flattened() == x)
        #expect(y.flattened() != y)
        #expect(z.flattened() != z)

        #expect(ww.flattened() == ww)
        #expect(xx.flattened() == xx)
        #expect(yy.flattened() == yy)

        // z is special
        #expect(z.flattened() == nil)
    }
}
