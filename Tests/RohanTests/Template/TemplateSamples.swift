// Copyright 2024 Lie Yan

import Foundation

@testable import SwiftRohan

struct TemplateSamples {
  static let cdots = Template(name: "cdots", body: [TextExpr("⋯")])

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
          numerator: [ApplyExpr("square", arguments: [[VariableExpr("x")]])],
          denominator: [ApplyExpr("square", arguments: [[TextExpr("a")]])]),
        TextExpr("+"),
        FractionExpr(
          numerator: [ApplyExpr("square", arguments: [[VariableExpr("y")]])],
          denominator: [ApplyExpr("square", arguments: [[TextExpr("b")]])]),
        TextExpr("=1"),
      ])

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

  static let square =
    Template(
      name: "square", parameters: ["x"],
      body: [
        VariableExpr("x"),
        ScriptsExpr(superScript: [TextExpr("2")]),
      ])

  // MARK: - Expanded

  static let circle_xpd =
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

  static let ellipse_xpd =
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

  static let SOS_xpd =
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

  // MARK: - Converted

  static let circle_idx =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        CompiledVariableExpr(0),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("+"),
        CompiledVariableExpr(1),
        ScriptsExpr(superScript: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  static let ellipse_idx =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          numerator: [
            CompiledVariableExpr(0), ScriptsExpr(superScript: [TextExpr("2")]),
          ],
          denominator: [TextExpr("a"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          numerator: [
            CompiledVariableExpr(1), ScriptsExpr(superScript: [TextExpr("2")]),
          ],
          denominator: [TextExpr("b"), ScriptsExpr(superScript: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  static let SOS_idx =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        CompiledVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("1")], superScript: [TextExpr("2")]),
        TextExpr("+"),
        CompiledVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("2")], superScript: [TextExpr("2")]),
        TextExpr("+⋯+"),
        CompiledVariableExpr(0),
        ScriptsExpr(subScript: [TextExpr("n")], superScript: [TextExpr("2")]),
      ])

  static let square_idx =
    Template(
      name: "square", parameters: ["x"],
      body: [CompiledVariableExpr(0), ScriptsExpr(superScript: [TextExpr("2")])])
}
