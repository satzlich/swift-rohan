// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct PropertyValueTypeTests {
    let a: PropertyValueType
    let b: PropertyValueType
    let c: PropertyValueType

    let w: PropertyValueType
    let x: PropertyValueType
    let y: PropertyValueType
    let z: PropertyValueType

    let ww: PropertyValueType
    let xx: PropertyValueType
    let yy: PropertyValueType

    init() {
        self.a = PropertyValueType.none
        self.b = PropertyValueType.auto
        self.c = PropertyValueType.bool

        self.w = PropertyValueType.sum([a])
        self.x = PropertyValueType.sum([b, c])
        self.y = PropertyValueType.sum([a, .sum([c])])
        self.z = PropertyValueType.sum([])

        self.ww = w.flattened()!
        self.xx = x.flattened()!
        self.yy = y.flattened()!
    }

    @Test
    func isSimple() {
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
    func flattened_isFlattened() {
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
    func isSubset() {
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

            // sum vs sum (mixed)
            #expect(y.isSubset(of: yy))
            #expect(yy.isSubset(of: y))
        }
    }
}
