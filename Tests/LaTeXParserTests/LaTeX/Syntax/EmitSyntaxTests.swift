// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct EmitSyntaxTests {
  @Test
  func attach() {
    _ = AttachSyntax(
      nucleus: ComponentSyntax(CharSyntax("x")),
      subscript_:
        ComponentSyntax(GroupSyntax(StreamSyntax([StreamletSyntax(TextToken("y+z"))]))),
      supscript: ComponentSyntax(CharSyntax("w")))
  }

  @Test
  func frac() {
    // \frac{1}{2}
    _ = CommandSeqSyntax(
      command: CommandSeqToken("\\frac")!,
      arguments: [
        ComponentSyntax(GroupSyntax([.text(TextSyntax("1"))]))
      ])
  }

  @Test
  func pmatrix() {
    // \begin{pmatrix}1 & 2 \\ 3 & 4 \end{pmatrix}
    _ = ArrayEnvSyntax(
      name: NameToken("pmatrix")!,
      wrapped: ArraySyntax([
        [
          StreamSyntax([StreamletSyntax(TextSyntax("1"))]),
          StreamSyntax([StreamletSyntax(TextSyntax("2"))]),
        ],
        [
          StreamSyntax([StreamletSyntax(TextSyntax("3"))]),
          StreamSyntax([StreamletSyntax(TextSyntax("4"))]),
        ],
      ]))
  }
}
