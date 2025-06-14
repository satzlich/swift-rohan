// Copyright 2024-2025 Lie Yan

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct RohanMacro: CompilerPlugin {
  var providingMacros: Array<Macro.Type> = [
    // Declaration
    ErrorCodeMacro.self
  ]
}
