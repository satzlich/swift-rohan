// Copyright 2024-2025 Lie Yan

import LatexParser
import Testing

struct NameTokenTests {
  @Test
  func coverage() {
    _ = NameToken.validate(string: "test")
    _ = NameToken("test*")
  }
}
