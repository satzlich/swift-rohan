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

    // basics (6)
    results.append(contentsOf: [
      .init("$", Snippets.inlineMath),
      .init("^", Snippets.attachMathComponent(.sup)),
      .init("_", Snippets.attachMathComponent(.sub)),
      .init("'", CommandBody("′", .mathText)),  // ' -> U+2032
      .init("′'", CommandBody("″", .mathText)),  // U+2032' -> U+2033
      .init("″'", CommandBody("‴", .mathText)),  // U+2033' -> U+2034
      .init("‴'", CommandBody("⁗", .mathText)),  // U+2034' -> U+2057
    ])

    // miscellaneous (5)
    results.append(contentsOf: [
      .init("...", CommandBody.fromNamedSymbol("ldots")!),
      spaceTriggered(
        "mod", CommandBody.from(MathExpression.bmod, preview: .string("mod"))),
      spaceTriggered("frac", Snippets.fraction),
      spaceTriggered("oo", CommandBody.fromNamedSymbol("infty")!),
      spaceTriggered("xx", CommandBody.fromNamedSymbol("times")!),
    ])

    // inequalities (3)
    results.append(contentsOf: [
      .init("/=", CommandBody.fromNamedSymbol("neq")!),
      .init("<=", CommandBody.fromNamedSymbol("leq")!),
      .init(">=", CommandBody.fromNamedSymbol("geq")!),
    ])

    // arrows (5)
    results.append(contentsOf: [
      .init("<-", CommandBody.fromNamedSymbol("leftarrow")!),
      .init("->", CommandBody.fromNamedSymbol("rightarrow")!),
      .init("=>", CommandBody.fromNamedSymbol("Rightarrow")!),
      .init("-->", CommandBody.fromNamedSymbol("longrightarrow")!),
      .init("==>", CommandBody.fromNamedSymbol("Longrightarrow")!),
    ])

    // set operations (5)
    results.append(contentsOf: [
      spaceTriggered("cap", CommandBody.fromNamedSymbol("cap")!),
      spaceTriggered("cup", CommandBody.fromNamedSymbol("cup")!),
      spaceTriggered("in", CommandBody.fromNamedSymbol("in")!),
      spaceTriggered("sub", CommandBody.fromNamedSymbol("subset")!),
      spaceTriggered("sube", CommandBody.fromNamedSymbol("subseteq")!),
    ])

    // sum-like operators (4)
    results.append(contentsOf: [
      spaceTriggered("sum", CommandBody.fromNamedSymbol("sum")!),
      spaceTriggered("prod", CommandBody.fromNamedSymbol("prod")!),
      spaceTriggered("int", CommandBody.fromNamedSymbol("int")!),
      spaceTriggered("oint", CommandBody.fromNamedSymbol("oint")!),
    ])

    // greek letters (no more than 4 chars; total: 29)
    results.append(contentsOf: [
      spaceTriggered("alpha", CommandBody.fromNamedSymbol("alpha")!),
      spaceTriggered("beta", CommandBody.fromNamedSymbol("beta")!),
      spaceTriggered("chi", CommandBody.fromNamedSymbol("chi")!),
      spaceTriggered("delta", CommandBody.fromNamedSymbol("delta")!),
      spaceTriggered("eta", CommandBody.fromNamedSymbol("eta")!),
      spaceTriggered("gamma", CommandBody.fromNamedSymbol("gamma")!),
      spaceTriggered("iota", CommandBody.fromNamedSymbol("iota")!),
      spaceTriggered("kappa", CommandBody.fromNamedSymbol("kappa")!),
      spaceTriggered("mu", CommandBody.fromNamedSymbol("mu")!),
      spaceTriggered("nu", CommandBody.fromNamedSymbol("nu")!),
      spaceTriggered("omega", CommandBody.fromNamedSymbol("omega")!),
      spaceTriggered("phi", CommandBody.fromNamedSymbol("phi")!),
      spaceTriggered("pi", CommandBody.fromNamedSymbol("pi")!),
      spaceTriggered("psi", CommandBody.fromNamedSymbol("psi")!),
      spaceTriggered("rho", CommandBody.fromNamedSymbol("rho")!),
      spaceTriggered("sigma", CommandBody.fromNamedSymbol("sigma")!),
      spaceTriggered("tau", CommandBody.fromNamedSymbol("tau")!),
      spaceTriggered("theta", CommandBody.fromNamedSymbol("theta")!),
      spaceTriggered("xi", CommandBody.fromNamedSymbol("xi")!),
      spaceTriggered("zeta", CommandBody.fromNamedSymbol("zeta")!),
      spaceTriggered("Delta", CommandBody.fromNamedSymbol("Delta")!),
      spaceTriggered("Gamma", CommandBody.fromNamedSymbol("Gamma")!),
      spaceTriggered("Omega", CommandBody.fromNamedSymbol("Omega")!),
      spaceTriggered("Phi", CommandBody.fromNamedSymbol("Phi")!),
      spaceTriggered("Pi", CommandBody.fromNamedSymbol("Pi")!),
      spaceTriggered("Psi", CommandBody.fromNamedSymbol("Psi")!),
      spaceTriggered("Sigma", CommandBody.fromNamedSymbol("Sigma")!),
      spaceTriggered("Theta", CommandBody.fromNamedSymbol("Theta")!),
      spaceTriggered("Xi", CommandBody.fromNamedSymbol("Xi")!),
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

      let rules: Array<ReplacementRule> = product(leftDelimiters, rightDelimiters)
        .map { (left, right) in
          spaceTriggered([left, right], Snippets.leftRight(left, right)!)
        }

      results.append(contentsOf: rules)
    }

    // math variants
    for char in UnicodeScalar("A").value...UnicodeScalar("Z").value {
      let char = String(UnicodeScalar(char)!)
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
    for char in UnicodeScalar("a").value...UnicodeScalar("z").value {
      let char = String(UnicodeScalar(char)!)
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

    // math operators
    do {
      let rules = MathOperator.allCommands.map {
        spaceTriggered($0.command, CommandBody.from($0))
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
