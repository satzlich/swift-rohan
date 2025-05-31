// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class ExportLaTeXTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func coverage() {
    let content: [Node] = [
      HeadingNode(
        level: 1,
        [
          TextNode("Heading 1")
        ]),
      ParagraphNode([
        TextNode("This is a paragraph with "),
        EmphasisNode([TextNode("emphasis")]),
        TextNode(" and "),
        StrongNode([TextNode("strong")]),
        TextNode("."),
      ]),
      EquationNode(
        .block,
        [
          TextNode("E=m"),
          AttachNode(nuc: [TextNode("c")], sup: [TextNode("2")]),
        ]),
      ParagraphNode([
        TextNode("This is a paragraph with an inline equation: "),
        EquationNode(
          .inline,
          [
            TextNode("PV=nRT")
          ]),
        TextNode(". Newton's second law states that "),
        EquationNode(
          .inline,
          [
            TextNode("a="),
            FractionNode(num: [TextNode("F")], denom: [TextNode("m")]),
          ]
        ),
        TextNode("."),
      ]),
      ParagraphNode([
        TextNode("Mary has a little lamb, its fleece was white as snow.")
      ]),
      EquationNode(
        .block,
        [
          TextNode("M="),
          MatrixNode(
            .bmatrix,
            [
              [ContentNode([TextNode("1")]), ContentNode([TextNode("2")])],
              [ContentNode([TextNode("3")]), ContentNode([TextNode("4")])],
            ]),
        ]),
    ]

    let document = self.createDocumentManager(RootNode(content))

    do {
      let latex: String? = document.exportDocument(to: .latexDocument)
        .flatMap { String(data: $0, encoding: .utf8) }

      let expected =
        #"""
        \documentclass[10pt]{article}
        \usepackage[usenames]{color}
        \usepackage{amssymb}
        \usepackage{amsmath}
        \usepackage[utf8]{inputenc}
        \usepackage{unicode-math}

        \DeclareMathOperator{\csch}{csch}
        \DeclareMathOperator{\ctg}{ctg}
        \DeclareMathOperator{\id}{id}
        \DeclareMathOperator{\im}{im}
        \DeclareMathOperator{\lcm}{lcm}
        \DeclareMathOperator{\sech}{sech}
        \DeclareMathOperator{\sinc}{sinc}
        \DeclareMathOperator{\tg}{tg}
        \DeclareMathOperator{\tr}{tr}

        \begin{document}
        \section{Heading 1}
        This is a paragraph with \emph{emphasis} and \textbf{strong}.
        \[E=mc^2\]
        This is a paragraph with an inline equation: $PV=nRT$. Newton's second law states that $a=\frac{F}{m}$.

        Mary has a little lamb, its fleece was white as snow.
        \[M=\begin{bmatrix}
        1 & 2\\
        3 & 4
        \end{bmatrix}\]
        \end{document}
        """#
      #expect(latex == expected)
    }

    do {
      let range = RhTextRange.parse("[↓1]:3..<[↓4,↓0]:10")!
      let latex = document.getLaTeXContent(for: range)
      let expected =
        #"""
        \textbf{strong}.
        \[E=mc^2\]
        This is a paragraph with an inline equation: $PV=nRT$. Newton's second law states that $a=\frac{F}{m}$.

        Mary has a
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func accent() {
    let content: [Node] = [
      EquationNode(
        .block,
        [
          AccentNode(.acute, nucleus: [TextNode("n")]),
          TextNode("+"),
          AccentNode(.grave, nucleus: [TextNode("m")]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLaTeXContent()
      let expected =
        #"""
        \[\acute{n}+\grave{m}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func attach() {
    let content: [Node] = [
      EquationNode(
        .block,
        [
          AttachNode(nuc: [TextNode("n")], sup: [TextNode("2")]),
          TextNode("+"),
          AttachNode(nuc: [TextNode("m")], lsup: [TextNode("3")]),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLaTeXContent()
      let expected =
        #"""
        \[n^2+{}^3 m\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func sqrt() {
    let content: [Node] = [
      EquationNode(
        .block,
        [
          RadicalNode([TextNode("n")]),
          TextNode("+"),
          RadicalNode([TextNode("m")], [TextNode("k")]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLaTeXContent()
      let expected =
        #"""
        \[\sqrt{n}+\sqrt[k]{m}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func leftRight() {
    let content: [Node] = [
      EquationNode(
        .block,
        [
          LeftRightNode(.DOUBLE_VERT, [TextNode("a+b")])
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLaTeXContent()
      let expected =
        #"""
        \[\left\lVert a+b\right\rVert\]
        """#
      #expect(latex == expected)
    }
  }
}
