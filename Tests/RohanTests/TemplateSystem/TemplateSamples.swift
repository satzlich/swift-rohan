// Copyright 2024 Lie Yan

import Foundation

@testable import Rohan

struct TemplateSamples {
  static let square =
    Template(
      name: "square", parameters: ["x"],
      body: [
        VariableExpr("x"),
        ScriptsExpr(superScript: [TextExpr("2")]),
      ])

  static let circle =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        ApplyExpr("square", arguments: [[VariableExpr("x")]]),
        TextExpr("+"),
        ApplyExpr("square", arguments: [[VariableExpr("y")]]),
        TextExpr("=1"),
      ])

  static let ellipse =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          numerator: [
            ApplyExpr("square", arguments: [[VariableExpr("x")]])
          ],
          denominator: [
            ApplyExpr("square", arguments: [[TextExpr("a")]])
          ]),
        TextExpr("+"),
        FractionExpr(
          numerator: [
            ApplyExpr("square", arguments: [[VariableExpr("y")]])
          ],
          denominator: [
            ApplyExpr("square", arguments: [[TextExpr("b")]])
          ]),
        TextExpr("=1"),
      ])

  static let cdots = Template(name: "cdots", body: [TextExpr("⋯")])

  /// Sum of squares
  static let SOS =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("1")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("2")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        ApplyExpr("cdots"),
        TextExpr("+"),
        VariableExpr("x"),
        ScriptsExpr(subScript: [TextExpr("n")], superScript: [TextExpr("2")]),
      ])

  // MARK: - Expanded

  static let circle_0 =
    Template(
      name: "circle", parameters: ["x", "y"],
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
      name: "circle", parameters: ["x", "y"],
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
      name: "ellipse", parameters: ["x", "y"],
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
      name: "square", parameters: ["x"],
      body: [UnnamedVariableExpr(0), ScriptsExpr(superScript: [TextExpr("2")])])

  static let ellipse_idx =
    Template(
      name: "ellipse", parameters: ["x", "y"],
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
      name: "SOS", parameters: ["x"],
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
      name: "SOS", parameters: ["x"],
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
