// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct IdentifierTests {
  @Test
  func coverage() {
    _ = NameSyntax.validate(string: "test")
    _ = NameSyntax("test*")
  }
}
