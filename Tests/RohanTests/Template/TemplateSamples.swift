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
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+"),
        ApplyExpr("cdots"),
        TextExpr("+"),
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  static let square =
    Template(
      name: "square", parameters: ["x"],
      body: [AttachExpr(nucleus: [VariableExpr("x")], sup: [TextExpr("2")])])

  // MARK: - Expanded

  static let circle_xpd =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(nucleus: [VariableExpr("x")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nucleus: [VariableExpr("y")], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  static let ellipse_xpd =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          numerator: [AttachExpr(nucleus: [VariableExpr("x")], sup: [TextExpr("2")])],
          denominator: [AttachExpr(nucleus: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          numerator: [AttachExpr(nucleus: [VariableExpr("y")], sup: [TextExpr("2")])],
          denominator: [AttachExpr(nucleus: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  static let SOS_xpd =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nucleus: [VariableExpr("x")], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  // MARK: - Converted

  static let circle_idx =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(nucleus: [CompiledVariableExpr(0)], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nucleus: [CompiledVariableExpr(1)], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  static let ellipse_idx =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          numerator: [
            AttachExpr(nucleus: [CompiledVariableExpr(0)], sup: [TextExpr("2")])
          ],
          denominator: [AttachExpr(nucleus: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          numerator: [
            AttachExpr(nucleus: [CompiledVariableExpr(1)], sup: [TextExpr("2")])
          ],
          denominator: [AttachExpr(nucleus: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  static let SOS_idx =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nucleus: [CompiledVariableExpr(0)], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nucleus: [CompiledVariableExpr(0)], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nucleus: [CompiledVariableExpr(0)], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  static let square_idx =
    Template(
      name: "square", parameters: ["x"],
      body: [AttachExpr(nucleus: [CompiledVariableExpr(0)], sup: [TextExpr("2")])])
}
