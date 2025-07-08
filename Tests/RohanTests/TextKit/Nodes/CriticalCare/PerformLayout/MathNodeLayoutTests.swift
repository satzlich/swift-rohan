// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

/// Tests for performing layout on math nodes and miscellaneous math-related nodes.
struct MathNodeLayoutTests {
  @Test
  func mathNodes_fromScratch() {
    let mathNodes: Array<MathNode> =
      MathNodeTests.allSamples().filter({ !isEquationNode($0) })
    let styleSheet = StyleSheetTests.testingStyleSheet()
    let contentNode = ContentNode(ElementStore(mathNodes))
    let mathContext = MathUtils.resolveMathContext(for: contentNode, styleSheet)
    let fragment = MathListLayoutFragment(mathContext)
    let context = MathListLayoutContext(styleSheet, mathContext, fragment)
    context.beginEditing()
    _ = contentNode.performLayout(context, fromScratch: true)
    context.endEditing()

    for node in mathNodes {
      for index in MathIndex.allCases {
        _ = node.getFragment(index)
      }
      let fragment = node.layoutFragment!

      let (x0, x1) = (0.0, fragment.width)
      let (y0, y1) = (-fragment.ascent, fragment.descent)

      let m = 5
      let dx = (x1 - x0) / Double(m)
      let dy = (y1 - y0) / Double(m)
      for i in 0..<m {
        for j in 0..<m {
          let point = CGPoint(
            x: x0 + Double(i) * dx + dx / 2,
            y: y0 + Double(j) * dy + dy / 2)
          _ = node.getMathIndex(interactingAt: point)
        }
      }
    }
  }

  private func createTestScene<T: Node, C: LayoutContext>(
    _ node: T, _ createContext: (ContentNode, StyleSheet) -> C
  ) -> (ContentNode, C) {
    let styleSheet = StyleSheetTests.testingStyleSheet()
    let contentNode = ContentNode([node])
    let context = createContext(contentNode, styleSheet)
    context.beginEditing()
    _ = contentNode.performLayout(context, fromScratch: true)
    context.endEditing()
    return (contentNode, context)
  }

  private func createMathTestScene<T: Node>(
    _ node: T
  ) -> (ContentNode, MathListLayoutContext) {
    createTestScene(node) { contentNode, styleSheet in
      let mathContext = MathUtils.resolveMathContext(for: contentNode, styleSheet)
      let fragment = MathListLayoutFragment(mathContext)
      let context = MathListLayoutContext(styleSheet, mathContext, fragment)
      return context
    }
  }

  private func createTextTestScene<T: Node>(
    _ node: T
  ) -> (ContentNode, TextLayoutContext) {
    createTestScene(node) { _, styleSheet in
      let textContext = TextLayoutContext(styleSheet)
      return textContext
    }
  }

  private func performLayout<T: LayoutContext>(_ context: T, _ contentNode: ContentNode) {
    context.resetCursor()
    context.beginEditing()
    _ = contentNode.performLayout(context, fromScratch: false)
    context.endEditing()
  }

  @Test
  func accent() {
    let accentNode = AccentNode(.overleftarrow, nucleus: [TextNode("x")])
    let (contentNode, context) = createMathTestScene(accentNode)
    do {
      accentNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      accentNode.nucleus.replaceChild(TextNode("xz"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func attach() {
    let attachNode = AttachNode(
      nuc: [TextNode("a")], lsub: [TextNode("1")], lsup: [TextNode("2")],
      sub: [TextNode("3")], sup: [TextNode("4")]
    )
    let (contentNode, context) = createMathTestScene(attachNode)
    // dirty
    do {
      attachNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      attachNode.lsub!.replaceChild(TextNode("5"), at: 0, inStorage: true)
      attachNode.lsup!.replaceChild(TextNode("6"), at: 0, inStorage: true)
      attachNode.sub!.replaceChild(TextNode("7"), at: 0, inStorage: true)
      attachNode.sup!.replaceChild(TextNode("8"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // dirty
    do {
      attachNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // modified
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.removeComponent(.lsup, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.addComponent(.lsub, [TextNode("9")], inStorage: true)
      attachNode.addComponent(.lsup, [TextNode("10")], inStorage: true)
      attachNode.removeComponent(.sub, inStorage: true)
      attachNode.removeComponent(.sup, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.removeComponent(.lsup, inStorage: true)
      attachNode.addComponent(.sub, [TextNode("11")], inStorage: true)
      attachNode.addComponent(.sup, [TextNode("12")], inStorage: true)
      performLayout(context, contentNode)
    }
    // modified + dirty
    do {
      attachNode.addComponent(.lsub, [TextNode("9")], inStorage: true)
      attachNode.addComponent(.lsup, [TextNode("10")], inStorage: true)
      attachNode.sub!.replaceChild(TextNode("13"), at: 0, inStorage: true)
      attachNode.sup!.replaceChild(TextNode("14"), at: 0, inStorage: true)
      attachNode.nucleus.replaceChild(TextNode("y"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.lsub!.replaceChild(TextNode("15"), at: 0, inStorage: true)
      attachNode.lsup!.replaceChild(TextNode("16"), at: 0, inStorage: true)
      attachNode.removeComponent(.sup, inStorage: true)
      attachNode.removeComponent(.sub, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      attachNode.removeComponent(.lsub, inStorage: true)
      attachNode.addComponent(.lsub, [TextNode("15")], inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func fraction() {
    let fractionNode =
      FractionNode(num: [TextNode("x")], denom: [TextNode("y")], genfrac: .frac)
    let (contentNode, context) = createMathTestScene(fractionNode)

    do {
      fractionNode.numerator.replaceChild(TextNode("x"), at: 0, inStorage: true)
      fractionNode.denominator.replaceChild(TextNode("y"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      fractionNode.numerator.replaceChild(TextNode("xxxx"), at: 0, inStorage: true)
      fractionNode.denominator.replaceChild(TextNode("yx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      fractionNode.denominator.replaceChild(TextNode("yxx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func leftRight() {
    let leftRightNode = LeftRightNode(DelimiterPair.BRACE, [TextNode("x")])
    let (contentNode, context) = createMathTestScene(leftRightNode)

    do {
      leftRightNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      leftRightNode.nucleus.replaceChild(TextNode("xx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func radical() {
    let radicalNode = RadicalNode([TextNode("m")], index: [TextNode("n")])
    let (contentNode, context) = createMathTestScene(radicalNode)

    // dirty, no frame change
    do {
      radicalNode.radicand.replaceChild(TextNode("m"), at: 0, inStorage: true)
      radicalNode.index!.replaceChild(TextNode("n"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // dirty, frame change
    do {
      radicalNode.radicand.replaceChild(TextNode("mm"), at: 0, inStorage: true)
      radicalNode.index!.replaceChild(TextNode("nn"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    // modified
    do {
      radicalNode.removeComponent(.index, inStorage: true)
      radicalNode.radicand.replaceChild(TextNode("m"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      radicalNode.addComponent(.index, [TextNode("n")], inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      radicalNode.removeComponent(.index, inStorage: true)
      radicalNode.addComponent(.index, [TextNode("nn")], inStorage: true)
      radicalNode.index!.replaceChild(TextNode("n"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func underOver() {
    let underOverNode = UnderOverNode(.overline, [TextNode("x")])
    let (contentNode, context) = createMathTestScene(underOverNode)

    do {
      underOverNode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      underOverNode.nucleus.replaceChild(TextNode("xx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func mathAttributes() {
    let mathAttrs = MathAttributesNode(.mathKind(.mathop), [TextNode("x")])
    let (contentNode, context) = createMathTestScene(mathAttrs)

    do {
      mathAttrs.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      mathAttrs.nucleus.replaceChild(TextNode("xx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func mathStyles() {
    let mathStyles = MathStylesNode(.mathbb, [TextNode("x")])
    let (contentNode, context) = createMathTestScene(mathStyles)

    do {
      mathStyles.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      mathStyles.nucleus.replaceChild(TextNode("xx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  @Test
  func textMode() {
    let textMode = TextModeNode([TextNode("x")])
    let (contentNode, context) = createMathTestScene(textMode)

    do {
      textMode.nucleus.replaceChild(TextNode("x"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
    do {
      textMode.nucleus.replaceChild(TextNode("xx"), at: 0, inStorage: true)
      performLayout(context, contentNode)
    }
  }

  // MARK: - Misc

  @Test
  func namedSymbol() {
    let namedSymbol = NamedSymbolNode(.lookup("idotsint")!)
    _ = createMathTestScene(namedSymbol)
    // no incremental layout test is necessary
  }

  private func _createTestScene(
    _ subtype: MathArray
  ) -> (ArrayNode, ContentNode, any LayoutContext) {

    // prepare the rows
    let rows: Array<Array<ArrayNode.Cell>>
    if subtype.isMultiColumnEnabled {
      rows = [
        [ContentNode([TextNode("a")]), ContentNode([TextNode("b")])],
        [ContentNode([TextNode("c")]), ContentNode([TextNode("d")])],
      ]
    }
    else {
      rows = [
        [ContentNode([TextNode("a")])],
        [ContentNode([TextNode("b")])],
      ]
    }

    // prepare the node
    if subtype.isMatrixNodeCompatible {
      let matrix = MatrixNode(subtype, rows)
      let (contentNode, context) = createMathTestScene(matrix)
      return (matrix, contentNode, context)
    }
    else {
      assert(subtype.isMultilineNodeCompatible)
      let multiline = MultilineNode(subtype, rows)
      let (contentNode, context) = createTextTestScene(multiline)
      return (multiline, contentNode, context)
    }
  }

  @Test
  func equationNode_dirtyCount() {
    let equationNode = EquationNode(.equation, [TextNode("x")])
    let (contentNode, context) = createTextTestScene(equationNode)
    do {
      equationNode.counterSegment?.begin.propagateDirty()
      performLayout(context, contentNode)
    }
  }

  @Test("arrayNode", arguments: [MathArray.bmatrix, .align, .multline])
  func arrayNode(_ subtype: MathArray) {
    let (arrayNode, contentNode, context) = _createTestScene(subtype)

    if subtype.isMultiColumnEnabled {
      // dirty
      do {
        let child = arrayNode.getElement(0, 1)
        child.replaceChild(TextNode("b"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      // dirty
      do {
        let child = arrayNode.getElement(0, 1)
        child.replaceChild(TextNode("x"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      // modified
      do {
        arrayNode.removeRow(at: 1, inStorage: true)
        arrayNode.insertColumn(at: 1, inStorage: true)
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("y"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      do {
        arrayNode.insertRow(at: 1, inStorage: true)
        arrayNode.removeColumn(at: 1, inStorage: true)
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("y"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
    }
    else {
      // dirty
      do {
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("b"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      // dirty
      do {
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("x"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      // modified
      do {
        arrayNode.removeRow(at: 1, inStorage: true)
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("y"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
      do {
        arrayNode.insertRow(at: 1, inStorage: true)
        let child = arrayNode.getElement(0, 0)
        child.replaceChild(TextNode("y"), at: 0, inStorage: true)
        performLayout(context, contentNode)
      }
    }

    // counter dirty
    if subtype.shouldProvideCounter {
      arrayNode.counterSegment?.begin.propagateDirty()
      performLayout(context, contentNode)
    }
  }
}
