// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class ExportLatexTests: TextKitTestsBase {
  private func _simpleExport(_ content: ElementStore) -> String? {
    let documentManager = createDocumentManager(RootNode(content))
    let latex = documentManager.getLatexContent()
    return latex
  }

  @Test
  func coverage() {
    let content: ElementStore = [
      HeadingNode(
        .sectionAst,
        [
          TextNode("Heading 1"),
          LinebreakNode(),
          TextNode("with a line break."),
          UnknownNode(.null),
        ]),
      ParagraphNode([
        TextNode("This is a paragraph with "),
        TextStylesNode(.emph, [TextNode("emphasis")]),
        TextNode(" and "),
        TextStylesNode(.textbf, [TextNode("strong")]),
        TextNode("."),
        EquationNode(
          .display,
          [
            TextNode("E=m"),
            AttachNode(nuc: [TextNode("c")], sup: [TextNode("2")]),
          ]),
      ]),
      ParagraphNode([
        TextNode("This is a paragraph with an inline equation: "),
        EquationNode(
          .inline,
          [
            TextNode("f"),
            MathExpressionNode(MathExpression.lookup("colon")!),
            TextNode("X"),
            NamedSymbolNode(NamedSymbol.lookup("rightarrow")!),
            TextNode("Y"),
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
        TextNode("Mary has a little lamb, its fleece was white as snow."),
        EquationNode(
          .display,
          [
            TextNode("M="),
            MatrixNode(
              .bmatrix,
              [
                [ContentNode([TextNode("1")]), ContentNode([TextNode("2")])],
                [ContentNode([TextNode("3")]), ContentNode([TextNode("4")])],
              ]),
          ]),
      ]),
    ]

    let document = self.createDocumentManager(RootNode(content))

    do {
      let latex: String? = document.exportDocument(to: .latexDocument)
        .flatMap { String(data: $0, encoding: .utf8) }

      let expected =
        #"""
        % !TEX program = xelatex
        \documentclass[10pt]{article}
        \usepackage[usenames]{color}
        \usepackage{amssymb}
        \usepackage{amsmath}
        \usepackage{amsthm}
        \usepackage[utf8]{inputenc}
        \usepackage{mathtools}
        \usepackage{unicode-math}

        \newtheorem{theorem}{Theorem}
        \newtheorem{lemma}{Lemma}
        \newtheorem{corollary}{Corollary}

        %\setlength\parindent{0pt}
        \setlength{\parskip}{0.5em}

        \begin{document}
        \section*{Heading 1\\ with a line break.[Unknown Node]}

        This is a paragraph with \emph{emphasis} and \textbf{strong}.
        \[E=mc^2\]

        This is a paragraph with an inline equation: $f\colon X\rightarrow Y$. Newton's second law states that $a=\frac{F}{m}$.

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
      let range = RhTextRange.parse("[↓1]:3..<[↓3,↓0]:10")!
      let latex = document.getLatexContent(for: range)
      let expected =
        #"""
        \textbf{strong}.
        \[E=mc^2\]

        This is a paragraph with an inline equation: $f\colon X\rightarrow Y$. Newton's second law states that $a=\frac{F}{m}$.

        Mary has a
        """#
      #expect(latex == expected)
    }
  }

  // MARK: - Math

  @Test
  func accent() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          AccentNode(.acute, nucleus: [TextNode("n")]),
          TextNode("+"),
          AccentNode(.grave, nucleus: [TextNode("m")]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\acute{n}+\grave{m}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func attach() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          AttachNode(nuc: [TextNode("n")], sup: [TextNode("2")]),
          TextNode("+"),
          AttachNode(nuc: [TextNode("m")], lsup: [TextNode("3")]),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[n^2+{}^3 m\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func genFraction() {
    let exported = _simpleExport([
      EquationNode(
        .display,
        [
          FractionNode(num: [TextNode("n")], denom: [TextNode("d")]),
          TextNode("+"),
          FractionNode(num: [TextNode("m")], denom: [TextNode("k")], genfrac: .binom),
          TextNode("+"),
          FractionNode(num: [TextNode("n")], denom: [TextNode("d")], genfrac: .atop),
        ])
    ])
    // Note that \atop is an infix command.
    let expected =
      #"""
      \[\frac{n}{d}+\binom{m}{k}+{n\atop d}\]
      """#
    #expect(exported == expected)
  }

  @Test
  func leftRight() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          LeftRightNode(.DOUBLE_VERT, [TextNode("a+b")])
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\left\lVert a+b\right\rVert\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func mathAttributes() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          // atom kind
          MathAttributesNode(.mathop, [TextNode("+")]),
          // limits and nolimits
          AttachNode(
            nuc: [MathAttributesNode(.nolimits, [NamedSymbolNode(.lookup("sum")!)])],
            sub: [TextNode("i=1")],
            sup: [TextNode("n")]),
          TextNode("i+"),
          AttachNode(
            nuc: [MathAttributesNode(.limits, [NamedSymbolNode(.lookup("int")!)])],
            sub: [TextNode("a")],
            sup: [TextNode("b")]),
          TextNode("f(x)dx+"),
          // nucleus
          MathAttributesNode(.limits, [MathAttributesNode(.mathop, [TextNode("r")])]),
          MathAttributesNode(.limits, [MathExpressionNode(.varinjlim)]),
          MathAttributesNode(.limits, [MathOperatorNode(.max)]),
          MathAttributesNode(.limits, [NamedSymbolNode(.lookup("prod")!)]),
          MathAttributesNode(.limits, [TextNode("W")]),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\mathop{+}\sum\nolimits_{i=1}^n i+\int\limits_a^b f(x)dx+\mathop{r}\limits\varinjlim\limits\max\limits\prod\limits\mathop{W}\limits\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func mathExpression() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          TextNode("f"),
          MathExpressionNode(.colon),
          TextNode("X"),
          NamedSymbolNode(.lookup("rightarrow")!),
          TextNode("Y"),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[f\colon X\rightarrow Y\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func mathOperator() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          MathOperatorNode(.max),
          TextNode("x+"),
          MathOperatorNode(.min),
          TextNode("y"),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\max x+\min y\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func mathStyles() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          MathStylesNode(.mathbb, [TextNode("x")]),
          TextNode("+"),
          MathStylesNode(.scriptstyle, [TextNode("y")]),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\mathbb{x}+{\scriptstyle y}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func matrix() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          MatrixNode(
            .pmatrix,
            [
              [ContentNode([TextNode("1")]), ContentNode([TextNode("2")])],
              [ContentNode([TextNode("3")]), ContentNode([TextNode("4")])],
            ]),
          TextNode("+"),
          MatrixNode(
            .bmatrix,
            [
              [ContentNode([TextNode("5")]), ContentNode([TextNode("6")])],
              [ContentNode([TextNode("7")]), ContentNode([TextNode("8")])],
            ]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\begin{pmatrix}
        1 & 2\\
        3 & 4
        \end{pmatrix}+\begin{bmatrix}
        5 & 6\\
        7 & 8
        \end{bmatrix}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func multiline() {
    guard
      let latex = _simpleExport([
        MultilineNode(
          .multlineAst,
          [
            MultilineNode.Row([
              ContentNode([TextNode("a")])
            ]),
            MultilineNode.Row([
              ContentNode([TextNode("b")])
            ]),
          ])
      ])
    else {
      Issue.record("Failed to export multiline node")
      return
    }
    let expected =
      #"""
      \begin{multline*}
      a\\
      b
      \end{multline*}
      """#
    #expect(latex == expected)
  }

  @Test
  func sqrt() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          RadicalNode([TextNode("n")]),
          TextNode("+"),
          RadicalNode([TextNode("m")], index: [TextNode("k")]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\sqrt{n}+\sqrt[k]{m}\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func textMode() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          TextModeNode([TextNode("This is text mode")]),
          TextNode("+"),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\text{This is text mode}+\]
        """#
      #expect(latex == expected)
    }
  }

  @Test
  func underOver() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          UnderOverNode(.overbrace, [TextNode("abc")]),
          TextNode("+"),
          UnderOverNode(.overline, [TextNode("abc")]),
          TextNode("+"),
          UnderOverNode(.underbrace, [TextNode("xyz")]),
          TextNode("+"),
          UnderOverNode(.underline, [TextNode("xyz")]),
        ])
    ]

    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\overbrace{abc}+\overline{abc}+\underbrace{xyz}+\underline{xyz}\]
        """#
      #expect(latex == expected)
    }
  }

  // MARK: - Template

  @Test
  func apply() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          ApplyNode(MathTemplate.pmod, [[TextNode("2m+n")]])!
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\pmod{2m+n}\]
        """#
      #expect(latex == expected)
    }
    do {
      let range = RhTextRange.parse("[↓0,nuc,↓0,⇒0,↓0]:1..<[↓0,nuc,↓0,⇒0,↓0]:3")!
      let latex = documentManager.getLatexContent(for: range)
      let expected =
        #"""
        m+
        """#
      #expect(latex == expected)
    }
  }

  // MARK: - Regression

  @Test
  func regress_min() {
    let content: ElementStore = [
      EquationNode(
        .display,
        [
          AttachNode(nuc: [MathOperatorNode(.min)], sub: [TextNode("x")]),
          TextNode("+"),
          AttachNode(nuc: [TextNode("x")], sub: [MathOperatorNode(.min)]),
        ])
    ]
    let documentManager = createDocumentManager(RootNode(content))
    do {
      let latex = documentManager.getLatexContent()
      let expected =
        #"""
        \[\min_x+x_{\min}\]
        """#
      #expect(latex == expected)
    }
  }
}
