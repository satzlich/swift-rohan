// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ErrorCodeTests {
  @Test
  func coverage() {
    let a = ErrorCode.DeleteRangeFailure
    let b = ErrorCode.GenericInternalError

    #expect((a == b) == false)

    _ = Set<ErrorCode>([a, b])
  }
}
