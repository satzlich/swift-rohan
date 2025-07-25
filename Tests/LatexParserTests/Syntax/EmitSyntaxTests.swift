import LatexParser
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

    #expect(LatexParser.deparse(attach, .defaultValue) == "x_{y+z}^w")
  }

  @Test
  func equation() {
    let eqaution = MathSyntax(
      delimiter: .dollar,
      content: StreamSyntax([.text(TextSyntax("a+b=c", mode: .mathMode)!)]))
    #expect(LatexParser.deparse(eqaution, .defaultValue) == "$a+b=c$")
  }

  @Test
  func frac() {
    let frac = ControlWordSyntax(
      command: ControlWordToken(#"\frac"#)!,
      arguments: [
        ComponentSyntax(GroupSyntax([.text(TextSyntax("1", mode: .mathMode)!)])),
        ComponentSyntax(GroupSyntax([.text(TextSyntax("x+y", mode: .mathMode)!)])),
      ])
    #expect(LatexParser.deparse(frac, .defaultValue) == #"\frac{1}{x+y}"#)
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
      LatexParser.deparse(pmatrix, .defaultValue) == #"""
        \begin{pmatrix}
        1 & 2\\
        3 & 4
        \end{pmatrix}
        """#)
  }
}
