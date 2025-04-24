// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, nuc: [])], .inlineContent, 1)

  static let superScript = CommandBody([AttachExpr(nuc: [], sup: [])], .mathContent, 2)
  static let subScript = CommandBody([AttachExpr(nuc: [], sub: [])], .mathContent, 2)
  static let supSubScript =
    CommandBody([AttachExpr(nuc: [], sub: [], sup: [])], .mathContent, 3)
  static let lsubSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3)
}
