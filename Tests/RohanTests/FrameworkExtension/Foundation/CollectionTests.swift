import CoreGraphics
import Foundation
import Testing

@testable import SwiftRohan

struct CollectionTests {
  @Test
  func coverage() {
    let sequence = [1, 2, 3]
    let subsequence = [1, 3]
    #expect(subsequence.isSubsequence(of: sequence))
    #expect(sequence.isSubsequence(of: subsequence) == false)
  }
}
