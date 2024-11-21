// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class PropertyValueTests: XCTestCase {
    func testType() {
        let a = PropertyValueType.int
        let b = PropertyValueType.auto
        let c = PropertyValueType.sum([b, .bool])
        let d = PropertyValueType.sum([a, .sum([.bool])])
        let dd = d.flattened()
        let e = PropertyValueType.sum([a, .sum([b, .bool])])
        let ee = e.flattened()

        // simple
        XCTAssertTrue(a.isSimple())
        XCTAssertTrue(b.isSimple())
        XCTAssertFalse(c.isSimple())
        XCTAssertFalse(d.isSimple())
        XCTAssertFalse(dd.isSimple())
        XCTAssertFalse(e.isSimple())
        XCTAssertFalse(ee.isSimple())

        // flattened
        XCTAssertTrue(a.isFlattened())
        XCTAssertTrue(b.isFlattened())
        XCTAssertTrue(c.isFlattened())
        XCTAssertFalse(d.isFlattened())
        XCTAssertTrue(dd.isFlattened())
        XCTAssertFalse(e.isFlattened())
        XCTAssertTrue(ee.isFlattened())

        // self vs self
        XCTAssertTrue(a.isSubset(of: a))
        XCTAssertTrue(b.isSubset(of: b))
        XCTAssertTrue(c.isSubset(of: c))
        XCTAssertTrue(d.isSubset(of: d))
        XCTAssertTrue(dd.isSubset(of: dd))
        XCTAssertTrue(e.isSubset(of: e))
        XCTAssertTrue(ee.isSubset(of: ee))

        // simple vs simple
        XCTAssertFalse(a.isSubset(of: b))
        XCTAssertFalse(b.isSubset(of: a))

        // simple vs sum
        XCTAssertFalse(a.isSubset(of: c))
        XCTAssertTrue(b.isSubset(of: c))

        // xx vs nested sum
        XCTAssertTrue(a.isSubset(of: d))
        XCTAssertFalse(b.isSubset(of: d))
        XCTAssertFalse(c.isSubset(of: d))
        XCTAssertTrue(c.isSubset(of: e))

        // xx vs flattened sum
        XCTAssertTrue(a.isSubset(of: dd))
        XCTAssertFalse(b.isSubset(of: dd))
        XCTAssertFalse(c.isSubset(of: dd))
        XCTAssertTrue(c.isSubset(of: ee))
    }

    func testMemoryLayout() {
        XCTAssertEqual(MemoryLayout<String>.size, 16)

        XCTAssertEqual(MemoryLayout<PropertyValue>.size, 17)
    }

    func testFontSize() {
        XCTAssertNil(FontSize(0.5))
        XCTAssertNotNil(FontSize(1))
        XCTAssertNotNil(FontSize(10))
        XCTAssertNotNil(FontSize(10.5))
        XCTAssertNil(FontSize(10.8))
        XCTAssertNotNil(FontSize(1638))
        XCTAssertNil(FontSize(1639))
    }

    func testAbsLength() {
        let abs = AbsLength.pt(10)
        let eps = 1e-9

        XCTAssertEqual(abs.ptValue, 10)
        XCTAssertEqual(abs.mmValue, 3.527_777_777, accuracy: eps)
        XCTAssertEqual(abs.cmValue, 0.352_777_777, accuracy: eps)
        XCTAssertEqual(abs.picaValue, 10 / 12, accuracy: eps)
        XCTAssertEqual(abs.inValue, 10 / 72, accuracy: eps)
    }
}
