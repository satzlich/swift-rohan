// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct EmitSyntaxTests {
  @Test
  func attach() {
    let attach = AttachSyntax(
      nucleus: ComponentSyntax(CharSyntax("x", mode: .mathMode)!),
      subscript_:
        ComponentSyntax(
          GroupSyntax(StreamSyntax([StreamletSyntax(TextToken("y+z", mode: .mathMode)!)]))
        ),
      supscript: ComponentSyntax(CharSyntax("w", mode: .mathMode)!))

    #expect(LaTeXParser.deparse(attach) == "x_{y+z}^w")
  }

  @Test
  func equation() {
    let eqaution = MathSyntax(
      delimiter: .dollar,
      content: StreamSyntax([.text(TextSyntax("a+b=c", mode: .mathMode)!)]))
    #expect(LaTeXParser.deparse(eqaution) == "$a+b=c$")
  }

  @Test
  func frac() {
    let frac = ControlSeqSyntax(
      command: ControlSeqToken(#"\frac"#)!,
      arguments: [
        ComponentSyntax(GroupSyntax([.text(TextSyntax("1", mode: .mathMode)!)])),
        ComponentSyntax(GroupSyntax([.text(TextSyntax("x+y", mode: .mathMode)!)])),
      ])
    #expect(LaTeXParser.deparse(frac) == #"\frac{1}{x+y}"#)
  }

  @Test
  func pmatrix() {
    let pmatrix = ArrayEnvSyntax(
      name: NameToken("pmatrix")!,
      wrapped: ArraySyntax([
        [
          StreamSyntax([StreamletSyntax(TextSyntax("1", mode: .mathMode)!)]),
          StreamSyntax([StreamletSyntax(TextSyntax("2", mode: .mathMode)!)]),
        ],
        [
          StreamSyntax([StreamletSyntax(TextSyntax("3", mode: .mathMode)!)]),
          StreamSyntax([StreamletSyntax(TextSyntax("4", mode: .mathMode)!)]),
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
