// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct PropertyValueType_ {
    static let a: ValueType = .none
    static let b: ValueType = .auto
    static let c: ValueType = .bool

    static let w: ValueType = .sum([a])
    static let x: ValueType = .sum([b, c])
    static let y: ValueType = .sum([a, .sum([c])])
    static let z: ValueType = .sum([])

    static let ww: ValueType = w.normalForm()
    static let xx: ValueType = x.normalForm()
    static let yy: ValueType = y.normalForm()
    static let zz: ValueType = z.normalForm()

    @Test
    static func isEmpty() {
        // z, zz is empty
        #expect(!a.isEmpty)
        #expect(!b.isEmpty)
        #expect(!c.isEmpty)
        #expect(!w.isEmpty)
        #expect(!x.isEmpty)
        #expect(!y.isEmpty)
        #expect(z.isEmpty)

        #expect(!ww.isEmpty)
        #expect(!xx.isEmpty)
        #expect(!yy.isEmpty)
        #expect(zz.isEmpty)
    }

    @Test
    static func isSimple() {
        // a, b, c, ww are simple;

        #expect(a.isSimple)
        #expect(b.isSimple)
        #expect(c.isSimple)
        #expect(!w.isSimple)
        #expect(!x.isSimple)
        #expect(!y.isSimple)

        #expect(ww.isSimple)
        #expect(!xx.isSimple)
        #expect(!yy.isSimple)
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

    @Test
    static func isNormal() {
        // w, y are not normal.

        #expect(a.isNormal())
        #expect(b.isNormal())
        #expect(c.isNormal())
        #expect(!w.isNormal())
        #expect(x.isNormal())
        #expect(!y.isNormal())
        #expect(z.isNormal())

        #expect(ww.isNormal())
        #expect(xx.isNormal())
        #expect(yy.isNormal())
        #expect(zz.isNormal())
    }

    @Test
    static func normalForm() {
        // w, y are not normal.

        #expect(a.normalForm() == a)
        #expect(b.normalForm() == b)
        #expect(c.normalForm() == c)
        #expect(w.normalForm() != w)
        #expect(x.normalForm() == x)
        #expect(y.normalForm() != y)
        #expect(z.normalForm() == z)

        #expect(ww.normalForm() == ww)
        #expect(xx.normalForm() == xx)
        #expect(yy.normalForm() == yy)
        #expect(zz.normalForm() == zz)
    }
}
