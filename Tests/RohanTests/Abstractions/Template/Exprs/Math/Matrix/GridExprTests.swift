// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct GridExprTests {
  @Test
  func coverage() {
    let exprs: [ArrayExpr] = GridExprTests.allSamples()

    let visitor = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.with(rows: createRows())
      _ = expr.accept(visitor, ())
    }

    func createRows() -> [ArrayExpr.Row] {
      [
        ArrayExpr.Row([
          ContentExpr([TextExpr("X")])
        ]),
        ArrayExpr.Row([
          ContentExpr([TextExpr("Y")])
        ]),
      ]
    }
  }

  static func allSamples() -> [ArrayExpr] {
    [
      // aligned
      AlignedExpr([
        AlignedExpr.Row([
          ContentExpr([TextExpr("a")]),
          ContentExpr([TextExpr("b")]),
        ]),
        AlignedExpr.Row([
          ContentExpr([TextExpr("c")]),
          ContentExpr([TextExpr("d")]),
        ]),
      ]),
      // cases
      CasesExpr([
        CasesExpr.Row([
          ContentExpr([TextExpr("e")])
        ]),
        CasesExpr.Row([
          ContentExpr([TextExpr("f")])
        ]),
      ]),
      // matrix
      MatrixExpr(
        DelimiterPair.PAREN,
        [
          MatrixExpr.Row([
            ContentExpr([TextExpr("g")]),
            ContentExpr([TextExpr("h")]),
          ]),
          MatrixExpr.Row([
            ContentExpr([TextExpr("i")]),
            ContentExpr([TextExpr("j")]),
          ]),
        ]),
    ]
  }
}
