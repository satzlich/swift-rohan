// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VersionIdArrayTests {
    @Test
    static func test_VersionIdArray() {
        var array = VersionIdArray()

        array.advance(to: VersionId(0))
        array.advance(to: VersionId(3))
        array.advance(to: VersionId(7))
        array.advance(to: VersionId(11))

        #expect(array.contains(VersionId(3)))
        #expect(array.contains(VersionId(4)) == false)
        #expect(array.contains(VersionId(11)))

        array.drop(through: VersionId(12))
        #expect(array.contains(VersionId(11)))

        array.drop(through: VersionId(5))
        #expect(array.contains(VersionId(11)) == false)
        #expect(array.contains(VersionId(7)) == false)
        #expect(array.contains(VersionId(3)))

        array.drop(through: VersionId(3))
        #expect(array.contains(VersionId(3)))
    }
}
