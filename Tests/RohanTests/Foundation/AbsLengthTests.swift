// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Numerics
import Testing

struct AbsLengthTests {
    @Test(arguments:
        [
            AbsLength.pt(10),
            AbsLength.mm(3.527_777_777_777),
            AbsLength.cm(0.352_777_777_777),
            AbsLength.pica(10 / 12),
            AbsLength.inch(10 / 72),
        ])
    func testUnitConversions(_ abs: AbsLength) {
        let eps = 1e-9

        #expect(abs.ptValue.isApproximatelyEqual(to: 10, absoluteTolerance: eps))
        #expect(abs.mmValue.isApproximatelyEqual(to: 3.527_777_777, absoluteTolerance: eps))
        #expect(abs.cmValue.isApproximatelyEqual(to: 0.352_777_777, absoluteTolerance: eps))
        #expect(abs.picaValue.isApproximatelyEqual(to: 10 / 12, absoluteTolerance: eps))
        #expect(abs.inchValue.isApproximatelyEqual(to: 10 / 72, absoluteTolerance: eps))
    }
}
