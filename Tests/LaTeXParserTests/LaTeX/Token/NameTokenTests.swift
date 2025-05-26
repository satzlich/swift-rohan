// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct NameTokenTests {
  @Test
  func coverage() {
    _ = NameToken.validate(string: "test")
    _ = NameToken("test*")
  }
}
