// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public enum ReplacementRules {
  nonisolated(unsafe) public static let allCases: Array<ReplacementRule> =
    textRules + mathRules

  nonisolated(unsafe) private static let textRules: Array<ReplacementRule> = [
    // quote
    .init("`", CommandBody("‘", .textText)),  // ` -> U+2018
    .init("‘`", CommandBody("“", .textText)),  // U+2018` -> U+201C
    .init("'", CommandBody("’", .textText)),  // ' -> U+2019
    .init("’'", CommandBody("”", .textText)),  // U+2019 ' -> U+201D
    // dash
    .init("--", CommandBody("–", .textText)),  // -- -> U+2013 (en-dash)
    .init("–-", CommandBody("—", .textText)),  // U+2013- -> U+2014 (em-dash)
    // dots
    .init("...", CommandBody("…", .textText)),  // ... -> U+2026
    // headers
    spaceTriggered("#", Snippets.header(level: 1)),
    spaceTriggered("##", Snippets.header(level: 2)),
    spaceTriggered("###", Snippets.header(level: 3)),
    // emph, strong
    spaceTriggered("*", Snippets.emphasis),
    spaceTriggered("**", Snippets.strong),
  ]

  nonisolated(unsafe) private static let mathRules: Array<ReplacementRule> = _mathRules()

  private static func _mathRules() -> Array<ReplacementRule> {
    var results: Array<ReplacementRule> = []

    // basics (7)
    results.append(contentsOf: [
      .init("$", Snippets.inlineMath),
      .init("^", Snippets.attachOrGotoMathComponent(.sup)),
      .init("_", Snippets.attachOrGotoMathComponent(.sub)),
      .init("'", CommandBody("′", .mathText)),  // ' -> U+2032
      .init("′'", CommandBody("″", .mathText)),  // U+2032' -> U+2033
      .init("″'", CommandBody("‴", .mathText)),  // U+2033' -> U+2034
      .init("‴'", CommandBody("⁗", .mathText)),  // U+2034' -> U+2057
    ])

    // miscellaneous (6)
    results.append(contentsOf: [
      .init("...", CommandBody.namedSymbolExpr("ldots")!),
      spaceTriggered("cdots", CommandBody.namedSymbolExpr("cdots")!),
      spaceTriggered(
        "mod",
        CommandBody.mathExpressionExpr(MathExpression.bmod, preview: .string("mod"))),
      spaceTriggered("frac", Snippets.fraction),
      spaceTriggered("oo", CommandBody.namedSymbolExpr("infty")!),
      spaceTriggered("xx", CommandBody.namedSymbolExpr("times")!),
    ])

    // inequalities (3)
    results.append(contentsOf: [
      .init("/=", CommandBody.namedSymbolExpr("neq")!),
      .init("<=", CommandBody.namedSymbolExpr("leq")!),
      .init(">=", CommandBody.namedSymbolExpr("geq")!),
    ])

    // arrows (5)
    results.append(contentsOf: [
      .init("<-", CommandBody.namedSymbolExpr("leftarrow")!),
      .init("->", CommandBody.namedSymbolExpr("rightarrow")!),
      .init("=>", CommandBody.namedSymbolExpr("Rightarrow")!),
      .init("-->", CommandBody.namedSymbolExpr("longrightarrow")!),
      .init("==>", CommandBody.namedSymbolExpr("Longrightarrow")!),
    ])

    // set operations (5)
    results.append(contentsOf: [
      spaceTriggered("cap", CommandBody.namedSymbolExpr("cap")!),
      spaceTriggered("cup", CommandBody.namedSymbolExpr("cup")!),
      spaceTriggered("in", CommandBody.namedSymbolExpr("in")!),
      spaceTriggered("sub", CommandBody.namedSymbolExpr("subset")!),
      spaceTriggered("sube", CommandBody.namedSymbolExpr("subseteq")!),
    ])

    // sum-like operators (4)
    results.append(contentsOf: [
      spaceTriggered("sum", CommandBody.namedSymbolExpr("sum")!),
      spaceTriggered("prod", CommandBody.namedSymbolExpr("prod")!),
      spaceTriggered("int", CommandBody.namedSymbolExpr("int")!),
      spaceTriggered("oint", CommandBody.namedSymbolExpr("oint")!),
    ])

    // greek letters (no more than 5 chars; total: 32)
    results.append(contentsOf: [
      spaceTriggered("alpha", CommandBody.namedSymbolExpr("alpha")!),
      spaceTriggered("beta", CommandBody.namedSymbolExpr("beta")!),
      spaceTriggered("chi", CommandBody.namedSymbolExpr("chi")!),
      spaceTriggered("delta", CommandBody.namedSymbolExpr("delta")!),
      spaceTriggered("eta", CommandBody.namedSymbolExpr("eta")!),
      spaceTriggered("gamma", CommandBody.namedSymbolExpr("gamma")!),
      spaceTriggered("iota", CommandBody.namedSymbolExpr("iota")!),
      spaceTriggered("kappa", CommandBody.namedSymbolExpr("kappa")!),
      spaceTriggered("mu", CommandBody.namedSymbolExpr("mu")!),
      spaceTriggered("nu", CommandBody.namedSymbolExpr("nu")!),
      spaceTriggered("omega", CommandBody.namedSymbolExpr("omega")!),
      spaceTriggered("phi", CommandBody.namedSymbolExpr("phi")!),
      spaceTriggered("pi", CommandBody.namedSymbolExpr("pi")!),
      spaceTriggered("psi", CommandBody.namedSymbolExpr("psi")!),
      spaceTriggered("rho", CommandBody.namedSymbolExpr("rho")!),
      spaceTriggered("sigma", CommandBody.namedSymbolExpr("sigma")!),
      spaceTriggered("tau", CommandBody.namedSymbolExpr("tau")!),
      spaceTriggered("theta", CommandBody.namedSymbolExpr("theta")!),
      spaceTriggered("varpi", CommandBody.namedSymbolExpr("varpi")!),
      spaceTriggered("xi", CommandBody.namedSymbolExpr("xi")!),
      spaceTriggered("zeta", CommandBody.namedSymbolExpr("zeta")!),
      spaceTriggered("Delta", CommandBody.namedSymbolExpr("Delta")!),
      spaceTriggered("Gamma", CommandBody.namedSymbolExpr("Gamma")!),
      spaceTriggered("Omega", CommandBody.namedSymbolExpr("Omega")!),
      spaceTriggered("Phi", CommandBody.namedSymbolExpr("Phi")!),
      spaceTriggered("Pi", CommandBody.namedSymbolExpr("Pi")!),
      spaceTriggered("Psi", CommandBody.namedSymbolExpr("Psi")!),
      spaceTriggered("Sigma", CommandBody.namedSymbolExpr("Sigma")!),
      spaceTriggered("Theta", CommandBody.namedSymbolExpr("Theta")!),
      spaceTriggered("Xi", CommandBody.namedSymbolExpr("Xi")!),
      //
      spaceTriggered("eps", CommandBody.namedSymbolExpr("epsilon")!),
      spaceTriggered("veps", CommandBody.namedSymbolExpr("varepsilon")!),
    ])

    // left-right delimiters
    do {
      let delimiterPairs: Array<(ExtendedChar, ExtendedChar)> = [
        (.char("("), .char(")")),
        (.char("["), .char("]")),
        (.char("{"), .char("}")),
        (.symbol(.lookup("langle")!), .symbol(.lookup("rangle")!)),
        (.symbol(.lookup("lbrace")!), .symbol(.lookup("rbrace")!)),
        (.symbol(.lookup("lbrack")!), .symbol(.lookup("rbrack")!)),
        (.symbol(.lookup("lceil")!), .symbol(.lookup("rceil")!)),
        (.symbol(.lookup("lfloor")!), .symbol(.lookup("rfloor")!)),
        (.symbol(.lookup("lgroup")!), .symbol(.lookup("rgroup")!)),
        (.symbol(.lookup("lmoustache")!), .symbol(.lookup("rmoustache")!)),
        (.symbol(.lookup("lvert")!), .symbol(.lookup("rvert")!)),
        (.symbol(.lookup("lVert")!), .symbol(.lookup("rVert")!)),
      ]

      let leftDelimiters = delimiterPairs.map { $0.0 }
      let rightDelimiters = delimiterPairs.map { $0.1 }

      // pairs
      let pairs = product(leftDelimiters, rightDelimiters).map { (left, right) in
        spaceTriggered([left, right], Snippets.leftRight(.pair(left, right))!)
      }
      results.append(contentsOf: pairs)
      // left + dot
      let leftOnly = leftDelimiters.map { left in
        spaceTriggered([left, .char(".")], Snippets.leftRight(.left(left))!)
      }
      results.append(contentsOf: leftOnly)
      // dot + right
      let rightOnly = rightDelimiters.map { right in
        spaceTriggered([.char("."), right], Snippets.leftRight(.right(right))!)
      }
      results.append(contentsOf: rightOnly)
      // <>
      let langle = ExtendedChar.symbol(.lookup("langle")!)
      let rangle = ExtendedChar.symbol(.lookup("rangle")!)
      results.append(spaceTriggered("<>", Snippets.leftRight(.pair(langle, rangle))!))
      // ||
      let lvert = ExtendedChar.symbol(.lookup("lvert")!)
      let rvert = ExtendedChar.symbol(.lookup("rvert")!)
      results.append(spaceTriggered("||", Snippets.leftRight(.pair(lvert, rvert))!))
      // ||||
      let lVert = ExtendedChar.symbol(.lookup("lVert")!)
      let rVert = ExtendedChar.symbol(.lookup("rVert")!)
      results.append(spaceTriggered("||||", Snippets.leftRight(.pair(lVert, rVert))!))
    }

    // math variants
    do {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      assert(letters.count == 52)
      for char in letters {
        let char = String(char)
        let list = [
          spaceTriggered("bb\(char)", Snippets.mathTextStyle(.mathbf, char)),
          spaceTriggered("bbb\(char)", Snippets.mathTextStyle(.mathbb, char)),
          spaceTriggered("cc\(char)", Snippets.mathTextStyle(.mathcal, char)),
          spaceTriggered("fr\(char)", Snippets.mathTextStyle(.mathfrak, char)),
          spaceTriggered("sf\(char)", Snippets.mathTextStyle(.mathsf, char)),
          spaceTriggered("tt\(char)", Snippets.mathTextStyle(.mathtt, char)),
        ]
        results.append(contentsOf: list)
      }
    }

    // math operators
    do {
      let rules = MathOperator.allCommands.map {
        spaceTriggered($0.command, CommandBody.mathOperatorExpr($0))
      }
      results.append(contentsOf: rules)
    }

    return results
  }

  /// Replacement triggered by `string` + ` ` (space).
  private static func spaceTriggered(
    _ string: String, _ command: CommandBody
  ) -> ReplacementRule {
    ReplacementRule(string, " ", command)
  }

  /// Replacement triggered by `string` + ` ` (space).
  private static func spaceTriggered(
    _ string: ExtendedString, _ command: CommandBody
  ) -> ReplacementRule {
    ReplacementRule(string, " ", command)
  }
}
