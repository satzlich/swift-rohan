// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct EmitSyntaxTests {
  @Test
  func attach() {
    let attach = AttachSyntax(
      nucleus: ComponentSyntax(CharSyntax("x")),
      subscript_:
        ComponentSyntax(GroupSyntax(StreamSyntax([StreamletSyntax(TextToken("y+z"))]))),
      supscript: ComponentSyntax(CharSyntax("w")))

    #expect(LaTeXParser.deparse(attach) == "x_{y+z}^w")
  }

  @Test
  func equation() {
    let eqaution = MathSyntax(
      delimiter: .dollar, content: StreamSyntax([.text(TextSyntax("a+b=c"))]))
    #expect(LaTeXParser.deparse(eqaution) == "$a+b=c$")
  }

  @Test
  func frac() {
    let frac = CommandSeqSyntax(
      command: CommandSeqToken(#"\frac"#)!,
      arguments: [
        ComponentSyntax(GroupSyntax([.text(TextSyntax("1"))])),
        ComponentSyntax(GroupSyntax([.text(TextSyntax("x+y"))])),
      ])
    #expect(LaTeXParser.deparse(frac) == #"\frac{1}{x+y}"#)
  }

  @Test
  func pmatrix() {
    let pmatrix = ArrayEnvSyntax(
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
    #expect(
      LaTeXParser.deparse(pmatrix) == #"""
        \begin{pmatrix}
        1 & 2\\
        3 & 4
        \end{pmatrix}
        """#)
  }
}
