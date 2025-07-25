import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ErrorCodeMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> Array<DeclSyntax> {
        // verify
        guard node.arguments.count == 3
        else { throw DefaultError.message("Need 3 arguments") }

        // extract arguments
        let code: ExprSyntax
        let name: ExprSyntax
        let type: ExprSyntax
        do {
            let arguments = node.arguments.map { $0 }
            code = arguments[0].expression
            name = arguments[1].expression
            type = arguments[2].expression
        }

        guard let name = getStringLiteral(name)
        else {
            throw DefaultError.message("Need a static string for parameter `name`")
        }

        let decl =
            """
            public static let \(name) = ErrorCode(code: \(code), name: "\(name)", type: \(type))
            """

        return [DeclSyntax(stringLiteral: decl)]
    }

    /// Extract a string literal from an expression
    private static func getStringLiteral(_ expr: ExprSyntax) -> String? {
        guard let segments = expr.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case let .stringSegment(string)? = segments.first
        else {
            return nil
        }
        return string.content.text
    }
}

enum DefaultError: Error {
    case message(String)
}
