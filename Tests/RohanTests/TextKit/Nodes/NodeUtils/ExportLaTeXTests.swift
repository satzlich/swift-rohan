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
    let latex = document.exportLaTeX()

    #expect(
      latex == #"""
        \section{Heading 1}
        This is a paragraph with \emph{emphasis} and \textbf{strong}
        \[E=m{c}^{2}\]
        This is a paragraph with an inline equation: $PV=nRT$

        Mary has a little lamb, its fleece was white as snow.
        \[M=\begin{bmatrix}
        1 & 2\\
        3 & 4
        \end{bmatrix}\]
        """#)
  }
}
