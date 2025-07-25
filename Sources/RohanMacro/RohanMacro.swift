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
