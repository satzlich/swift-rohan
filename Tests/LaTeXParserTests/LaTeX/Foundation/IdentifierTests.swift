// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct IdentifierTests {
  @Test
  func coverage() {
    _ = CommandNameSyntax.validate(string: "test")
    _ = CommandNameSyntax("test*")
  }
}
