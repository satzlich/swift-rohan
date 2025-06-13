// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct PositionResultTests {

  private typealias PositionResult = SwiftRohan.PositionResult<String>

  @Test
  func coverage() {
    let terminal = PositionResult.terminal(value: "abc", target: 3)
    let halfway = PositionResult.halfway(value: "xyzw", consumed: 4)
    let null = PositionResult.null
    let failure = PositionResult.failure(SatzError(.GenericInternalError))

    do {
      #expect(terminal.isTerminal)
      #expect(terminal.isHalfway == false)
      #expect(terminal.isNull == false)
      #expect(terminal.isFailure == false)
      //
      #expect(halfway.isTerminal == false)
      #expect(halfway.isHalfway)
      #expect(halfway.isNull == false)
      #expect(halfway.isFailure == false)
      //
      #expect(null.isTerminal == false)
      #expect(null.isHalfway == false)
      #expect(null.isNull)
      #expect(null.isFailure == false)
      //
      #expect(failure.isTerminal == false)
      #expect(failure.isHalfway == false)
      #expect(failure.isNull == false)
      #expect(failure.isFailure)
    }
    do {
      #expect(terminal.value == "abc")
      #expect(terminal.offset == 3)

      #expect(halfway.value == "xyzw")
      #expect(halfway.offset == 4)

      #expect(null.value == nil)
      #expect(null.offset == nil)

      #expect(failure.value == nil)
      #expect(failure.offset == nil)
    }

  }
}
