// Copyright 2024 Lie Yan

import Foundation

@testable import SwiftRohan

struct TemplateSamples {
  nonisolated(unsafe) static let cdots = Template(name: "cdots", body: [TextExpr("⋯")])

  nonisolated(unsafe) static let circle =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        ApplyExpr("square", arguments: [[VariableExpr("x")]]),
        TextExpr("+"),
        ApplyExpr("square", arguments: [[VariableExpr("y")]]),
        TextExpr("=1"),
      ])

  nonisolated(unsafe) static let ellipse =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [ApplyExpr("square", arguments: [[VariableExpr("x")]])],
          denom: [ApplyExpr("square", arguments: [[TextExpr("a")]])]),
        TextExpr("+"),
        FractionExpr(
          num: [ApplyExpr("square", arguments: [[VariableExpr("y")]])],
          denom: [ApplyExpr("square", arguments: [[TextExpr("b")]])]),
        TextExpr("=1"),
      ])

  /// Sum of squares
  nonisolated(unsafe) static let SOS =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+"),
        ApplyExpr("cdots"),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  nonisolated(unsafe) static let square =
    Template(
      name: "square", parameters: ["x"],
      body: [AttachExpr(nuc: [VariableExpr("x")], sup: [TextExpr("2")])])

  // MARK: - Expanded

  nonisolated(unsafe) static let circle_xpd =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(nuc: [VariableExpr("x")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nuc: [VariableExpr("y")], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  nonisolated(unsafe) static let ellipse_xpd =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [AttachExpr(nuc: [VariableExpr("x")], sup: [TextExpr("2")])],
          denom: [AttachExpr(nuc: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          num: [AttachExpr(nuc: [VariableExpr("y")], sup: [TextExpr("2")])],
          denom: [AttachExpr(nuc: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  nonisolated(unsafe) static let SOS_xpd =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nuc: [VariableExpr("x")], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  // MARK: - Converted

  nonisolated(unsafe) static let circle_idx =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(nuc: [CompiledVariableExpr(0)], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nuc: [CompiledVariableExpr(1)], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ])

  nonisolated(unsafe) static let ellipse_idx =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [
            AttachExpr(nuc: [CompiledVariableExpr(0)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          num: [
            AttachExpr(nuc: [CompiledVariableExpr(1)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ])

  nonisolated(unsafe) static let SOS_idx =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [CompiledVariableExpr(0)], sub: [TextExpr("1")], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [CompiledVariableExpr(0)], sub: [TextExpr("2")], sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nuc: [CompiledVariableExpr(0)], sub: [TextExpr("n")], sup: [TextExpr("2")]),
      ])

  nonisolated(unsafe) static let square_idx =
    Template(
      name: "square", parameters: ["x"],
      body: [AttachExpr(nuc: [CompiledVariableExpr(0)], sup: [TextExpr("2")])])
}
