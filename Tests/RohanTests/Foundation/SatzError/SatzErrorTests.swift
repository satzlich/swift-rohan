// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct SatzErrorTests {
  @Test
  func coverage() {
    let a = ErrorCode.DeleteRangeFailure
    let b = ErrorCode.GenericInternalError

    #expect((a == b) == false)

    _ = Set<ErrorCode>([a, b])
  }

  @Test
  func satzError_Equatble() {
    let a = SatzError(.DeleteRangeFailure)
    let b = SatzError(.GenericInternalError)
    let c = SatzError(.DeleteRangeFailure, message: "Test")

    #expect((a == b) == false)
    #expect((a == c) == false)
  }
}
