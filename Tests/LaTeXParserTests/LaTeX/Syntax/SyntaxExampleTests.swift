// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct SyntaxExampleTests {
  @Test
  func accents() {
    _ = CommandSeqSyntax(
      command: CommandSeqToken("\\acute")!, arguments: [.char(CharSyntax("a")!)])
  }

  @Test
  func attach() {
    _ = AttachSyntax(nucleus: .char(CharSyntax("x")!), supscript: .char(CharSyntax("2")!))
  }

  @Test
  func equation() {
    _ = MathSyntax(
      open: .dollar, close: .dollar,
      content: StreamSyntax(stream: [.text(TextSyntax(text: "a+b=c"))]))
  }
}
