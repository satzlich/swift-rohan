// Copyright 2024 Lie Yan

import Foundation

@testable import Rohan

struct TemplateSamples {
  static let square =
    Template(
      name: TemplateName("square"),
      parameters: [Identifier("x")],
      body: [
        VariableExpr("x"),
        ScriptsExpr(superScript: [TextExpr("2")]),
      ])

  static let circle =
    Template(
      name: TemplateName("circle"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        ApplyExpr(TemplateName("square"), arguments: [[VariableExpr("x")]]),
        TextExpr("+"),
        ApplyExpr(TemplateName("square"), arguments: [[VariableExpr("y")]]),
        TextExpr("=1"),
      ])

  static let ellipse =
    Template(
      name: TemplateName("ellipse"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        FractionExpr(
          numerator: [
            ApplyExpr(TemplateName("square"), arguments: [[VariableExpr("x")]])
          ],
          denominator: [
            ApplyExpr(TemplateName("square"), arguments: [[TextExpr("a")]])
          ]),
        TextExpr("+"),
        FractionExpr(
          numerator: [
            ApplyExpr(TemplateName("square"), arguments: [[VariableExpr("y")]])
          ],
          denominator: [
            ApplyExpr(TemplateName("square"), arguments: [[TextExpr("b")]])
          ]),
        TextExpr("=1"),
      ])

  static let cdots =
    Template(
      name: TemplateName("cdots"),
      parameters: [],
      body: [TextExpr("⋯")])

  /// Sum of squares
  static let SOS =
    Template(
      name: TemplateName("SOS"),
      parameters: [Identifier("x")],
      body: [
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("1")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("2")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        ApplyExpr(TemplateName("cdots")),
        TextExpr("+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("n")], superScript: [TextExpr("2")]),
      ])

  // MARK: - Expanded

  static let circle_0 =
    Template(
      name: TemplateName("circle"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        VariableExpr("x"),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("+"),
        VariableExpr("y"),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  static let circle_idx =
    Template(
      name: TemplateName("circle"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        UnnamedVariableExpr(0),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("+"),
        UnnamedVariableExpr(1),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  static let ellipse_0 =
    Template(
      name: TemplateName("ellipse"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        FractionExpr(
          numerator: [VariableExpr("x"), ScriptsExpr(superScript: [TextExpr("2")])],
          denominator: [TextExpr("a"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          numerator: [VariableExpr("y"), ScriptsExpr(superScript: [TextExpr("2")])],
          denominator: [TextExpr("b"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  // MARK: - Nameless

  static let square_idx =
    Template(
      name: TemplateName("square"),
      parameters: [Identifier("x")],
      body: [UnnamedVariableExpr(0), ScriptsExpr(superScript: [TextExpr("2")])])

  static let ellipse_idx =
    Template(
      name: TemplateName("ellipse"),
      parameters: [Identifier("x"), Identifier("y")],
      body: [
        FractionExpr(
          numerator: [UnnamedVariableExpr(0), ScriptsExpr(superScript: [TextExpr("2")])],
          denominator: [TextExpr("a"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          numerator: [UnnamedVariableExpr(1), ScriptsExpr(superScript: [TextExpr("2")])],
          denominator: [TextExpr("b"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  static let SOS_0 =
    Template(
      name: TemplateName("SOS"),
      parameters: [Identifier("x")],
      body: [
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("1")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("2")], superScript: [TextExpr("2")]),
        TextExpr("+⋯+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("n")], superScript: [TextExpr("2")]),
      ])
  static let SOS_idx =
    Template(
      name: TemplateName("SOS"),
      parameters: [Identifier("x")],
      body: [
        UnnamedVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("1")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        UnnamedVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("2")], superScript: [TextExpr("2")]),
        TextExpr("+⋯+"),
        UnnamedVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("n")], superScript: [TextExpr("2")]),
      ])
}
