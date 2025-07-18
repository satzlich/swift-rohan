// Copyright 2024 Lie Yan

import Foundation

@testable import SwiftRohan

struct TemplateSamples {
  nonisolated(unsafe) static let cdots = Template(
    name: "cdots", body: [TextExpr("⋯")],
    layoutType: .inline)

  nonisolated(unsafe) static let circle =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        ApplyExpr("square", arguments: [[VariableExpr("x", .inline)]]),
        TextExpr("+"),
        ApplyExpr("square", arguments: [[VariableExpr("y", .inline)]]),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let ellipse =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [ApplyExpr("square", arguments: [[VariableExpr("x", .inline)]])],
          denom: [ApplyExpr("square", arguments: [[TextExpr("a")]])]),
        TextExpr("+"),
        FractionExpr(
          num: [ApplyExpr("square", arguments: [[VariableExpr("y", .inline)]])],
          denom: [ApplyExpr("square", arguments: [[TextExpr("b")]])]),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  /// Sum of squares
  nonisolated(unsafe) static let SOS =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("1")],
          sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("2")],
          sup: [TextExpr("2")]),
        TextExpr("+"),
        ApplyExpr("cdots"),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("n")],
          sup: [TextExpr("2")]),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let square =
    Template(
      name: "square", parameters: ["x"],
      body: [AttachExpr(nuc: [VariableExpr("x", .inline)], sup: [TextExpr("2")])],
      layoutType: .inline)

  // MARK: - Expanded

  nonisolated(unsafe) static let circle_xpd =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(nuc: [VariableExpr("x", .inline)], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nuc: [VariableExpr("y", .inline)], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let ellipse_xpd =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [
            AttachExpr(nuc: [VariableExpr("x", .inline)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          num: [
            AttachExpr(nuc: [VariableExpr("y", .inline)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let SOS_xpd =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("1")],
          sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("2")],
          sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nuc: [VariableExpr("x", .inline)], sub: [TextExpr("n")],
          sup: [TextExpr("2")]),
      ],
      layoutType: .inline)

  // MARK: - Converted

  nonisolated(unsafe) static let circle_idx =
    Template(
      name: "circle", parameters: ["x", "y"],
      body: [
        AttachExpr(
          nuc: [CompiledVariableExpr(0, .inline, .inline)], sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(nuc: [CompiledVariableExpr(1, .inline, .inline)], sup: [TextExpr("2")]),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let ellipse_idx =
    Template(
      name: "ellipse", parameters: ["x", "y"],
      body: [
        FractionExpr(
          num: [
            AttachExpr(
              nuc: [CompiledVariableExpr(0, .inline, .inline)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("a")], sup: [TextExpr("2")])]
        ),
        TextExpr("+"),
        FractionExpr(
          num: [
            AttachExpr(
              nuc: [CompiledVariableExpr(1, .inline, .inline)], sup: [TextExpr("2")])
          ],
          denom: [AttachExpr(nuc: [TextExpr("b")], sup: [TextExpr("2")])]
        ),
        TextExpr("=1"),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let SOS_idx =
    Template(
      name: "SOS", parameters: ["x"],
      body: [
        AttachExpr(
          nuc: [CompiledVariableExpr(0, .inline, .inline)], sub: [TextExpr("1")],
          sup: [TextExpr("2")]),
        TextExpr("+"),
        AttachExpr(
          nuc: [CompiledVariableExpr(0, .inline, .inline)], sub: [TextExpr("2")],
          sup: [TextExpr("2")]),
        TextExpr("+⋯+"),
        AttachExpr(
          nuc: [CompiledVariableExpr(0, .inline, .inline)], sub: [TextExpr("n")],
          sup: [TextExpr("2")]),
      ],
      layoutType: .inline)

  nonisolated(unsafe) static let square_idx =
    Template(
      name: "square", parameters: ["x"],
      body: [
        AttachExpr(nuc: [CompiledVariableExpr(0, .inline, .inline)], sup: [TextExpr("2")])
      ],
      layoutType: .inline)
}
