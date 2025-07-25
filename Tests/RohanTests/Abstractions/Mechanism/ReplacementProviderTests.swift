import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ReplacementProviderTests {
  @Test
  func coverage() {
    let provider = ReplacementProvider(ReplacementRules.allCases)

    _ = provider.prefixSize(for: "'", in: .textMode)
    _ = provider.prefixSize(for: "'", in: .mathMode)

    _ = provider.replacement(for: "`", prefix: "", in: .textMode)
    _ = provider.replacement(for: "=", prefix: ":", in: .mathMode)
  }
}
