// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, nuc: [])], .inlineContent, 1)
}
