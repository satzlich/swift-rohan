// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct EitherBothTests {

  private typealias EitherBoth = SwiftRohan.EitherBoth<String, Int>

  @Test
  func coverage() {
    let string = EitherBoth.left("Hello")
    let integer = EitherBoth.right(42)
    let pair = EitherBoth.pair("World", 100)

    #expect(string.isLeft == true)
    #expect(string.isRight == false)
    #expect(string.isPair == false)
    #expect(integer.isLeft == false)
    #expect(integer.isRight == true)
    #expect(integer.isPair == false)
    #expect(pair.isLeft == false)
    #expect(pair.isRight == false)
    #expect(pair.isPair == true)

    #expect(string.left() == "Hello")
    #expect(string.right() == nil)
    #expect(string.pair() == nil)
    #expect(integer.left() == nil)
    #expect(integer.right() == 42)
    #expect(integer.pair() == nil)
    #expect(pair.left() == nil)
    #expect(pair.right() == nil)
    #expect(pair.pair()! == ("World", 100))
  }
}
