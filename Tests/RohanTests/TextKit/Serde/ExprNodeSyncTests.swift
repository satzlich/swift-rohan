// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class ExprNodeSyncTests {
  var count: Int = 0

  @Test
  func elements() throws {
    // Element
    do {
      let content = ContentExpr([TextExpr("abc")])
      try assertSerdeSync(content, ContentNode.self)
    }
    do {
      let emphasis = EmphasisExpr([TextExpr("abc")])
      try assertSerdeSync(emphasis, EmphasisNode.self)
    }
    do {
      let heading = HeadingExpr(level: 1, [TextExpr("abc")])
      try assertSerdeSync(heading, HeadingNode.self)
    }
    do {
      let paragraph = ParagraphExpr([TextExpr("abc")])
      try assertSerdeSync(paragraph, ParagraphNode.self)
    }
    do {
      let strong = StrongExpr([TextExpr("abc")])
      try assertSerdeSync(strong, StrongNode.self)
    }
  }

  @Test
  func grids() throws {
    // Matrix
    do {
      let aligned = AlignedExpr([
        AlignedExpr.Row([
          AlignedExpr.Element([TextExpr("abc")]),
          AlignedExpr.Element([TextExpr("def")]),
        ]),
        AlignedExpr.Row([
          AlignedExpr.Element([TextExpr("ghi")]),
          AlignedExpr.Element([TextExpr("jkl")]),
        ]),
      ])
      try assertSerdeSync(aligned, AlignedNode.self)
    }
    do {
      let cases = CasesExpr([
        CasesExpr.Row([
          CasesExpr.Element([TextExpr("abc")]),
          CasesExpr.Element([TextExpr("def")]),
        ]),
        CasesExpr.Row([
          CasesExpr.Element([TextExpr("ghi")]),
          CasesExpr.Element([TextExpr("jkl")]),
        ]),
      ])
      try assertSerdeSync(cases, CasesNode.self)
    }
    do {
      let matrix = MatrixExpr(
        [
          MatrixExpr.Row([
            MatrixExpr.Element([TextExpr("abc")]),
            MatrixExpr.Element([TextExpr("def")]),
          ]),
          MatrixExpr.Row([
            MatrixExpr.Element([TextExpr("ghi")]),
            MatrixExpr.Element([TextExpr("jkl")]),
          ]),
        ], DelimiterPair.BRACE)
      try assertSerdeSync(matrix, MatrixNode.self)
    }
  }

  @Test
  func underOver() throws {
    // UnderOver
    do {
      let overline = OverlineExpr([TextExpr("abc")])
      try assertSerdeSync(overline, OverlineNode.self)
    }
    do {
      let underline = UnderlineExpr([TextExpr("abc")])
      try assertSerdeSync(underline, UnderlineNode.self)
    }
    do {
      let overbrace = OverspreaderExpr(Characters.overBrace, [TextExpr("abc")])
      try assertSerdeSync(overbrace, OverspreaderNode.self)
    }
    do {
      let underbrace = OverspreaderExpr(Characters.underBrace, [TextExpr("abc")])
      try assertSerdeSync(underbrace, OverspreaderNode.self)
    }
  }

  func assertSerdeSync<T: Expr, U: Node>(_ expr: T, _ dummy: U.Type) throws {
    self.count += 1

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let decoder = JSONDecoder()

    // expr -> data -> node -> data2 -> expr -> data3
    let data = try encoder.encode(expr)
    do {
      let decodedNode = try decoder.decode(U.self, from: data)
      let data2 = try encoder.encode(decodedNode)
      #expect(data2 == data)
      let redecodedExpr = try decoder.decode(T.self, from: data2)
      let data3 = try encoder.encode(redecodedExpr)
      #expect(data3 == data)
    }

    // expr -> node -> data4
    do {
      guard let node = NodeUtils.convertExprs([expr]).getOnlyElement()
      else {
        Issue.record("Cannot convert expr to node")
        return
      }
      let data4 = try encoder.encode(node)
      #expect(data4 == data)
    }
  }
}
