// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ArrayExprTests {
  @Test
  func coverage() {
    let exprs: Array<ArrayExpr> = ArrayExprTests.allSamples()

    let visitor = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.with(rows: createRows())
      _ = expr.accept(visitor, ())
    }

    func createRows() -> Array<ArrayExpr.Row> {
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

  static func allSamples() -> Array<ArrayExpr> {
    [
      // matrix
      MatrixExpr(
        MathArray.pmatrix,
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
      //
      MultilineExpr(
        .multlineAst,
        [
          MatrixExpr.Row([
            ContentExpr([TextExpr("g")])
          ]),
          MatrixExpr.Row([
            ContentExpr([TextExpr("i")])
          ]),
        ]),
    ]
  }

  @Test
  func validate() {
    #expect(false == ArrayExpr.validate(rows: []))
    #expect(false == ArrayExpr.validate(rows: [ArrayExpr.Row([])]))
  }

  @Test
  func gridRow() {
    var row = GridRow<Int>([1, 2, 3])
    row[2] = 4
  }
}
