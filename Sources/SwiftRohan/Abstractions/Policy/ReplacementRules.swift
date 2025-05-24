// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
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
    spaceTriggered("#", CommandBodies.header(level: 1)),
    spaceTriggered("##", CommandBodies.header(level: 2)),
    spaceTriggered("###", CommandBodies.header(level: 3)),
    // emph, strong
    spaceTriggered("*", CommandBodies.emphasis),
    spaceTriggered("**", CommandBodies.strong),
  ]

  private static let mathRules: Array<ReplacementRule> = _mathRules()

  private static func _mathRules() -> Array<ReplacementRule> {
    var results: Array<ReplacementRule> =
      [
        // basics (6)
        .init("$", CommandBodies.inlineMath),
        .init("^", CommandBodies.attachMathComponent(.sup)),
        .init("_", CommandBodies.attachMathComponent(.sub)),
        .init("'", CommandBody("′", .mathText)),  // ' -> U+2032
        .init("′'", CommandBody("″", .mathText)),  // U+2032' -> U+2033
        .init("″'", CommandBody("‴", .mathText)),  // U+2033' -> U+2034

        // frequent (3)
        .init("...", CommandBody.fromNamedSymbol("ldots")!),
        spaceTriggered("oo", CommandBody.fromNamedSymbol("infty")!),
        spaceTriggered("xx", CommandBody.fromNamedSymbol("times")!),

        // inequalities (3)
        .init("!=", CommandBody.fromNamedSymbol("neq")!),
        .init("<=", CommandBody.fromNamedSymbol("leq")!),
        .init(">=", CommandBody.fromNamedSymbol("geq")!),

        // arrows (5)
        .init("<-", CommandBody.fromNamedSymbol("leftarrow")!),
        .init("->", CommandBody.fromNamedSymbol("rightarrow")!),
        .init("=>", CommandBody.fromNamedSymbol("Rightarrow")!),
        .init("-->", CommandBody.fromNamedSymbol("longrightarrow")!),
        .init("==>", CommandBody.fromNamedSymbol("Longrightarrow")!),

        // left-right delimiters (7)
        .init("()", CommandBodies.leftRight("(", ")")!),
        .init("[]", CommandBodies.leftRight("[", "]")!),
        .init("{}", CommandBodies.leftRight("{", "}")!),
        .init("[)", CommandBodies.leftRight("[", ")")!),
        .init("(]", CommandBodies.leftRight("(", "]")!),
        .init("<>", CommandBodies.leftRight("langle", "rangle")!),
        .init("||", CommandBodies.leftRight("lvert", "rvert")!),

        // set operations (5)
        spaceTriggered("cap", CommandBody.fromNamedSymbol("cap")!),
        spaceTriggered("cup", CommandBody.fromNamedSymbol("cup")!),
        spaceTriggered("in", CommandBody.fromNamedSymbol("in")!),
        spaceTriggered("sub", CommandBody.fromNamedSymbol("subset")!),
        spaceTriggered("sube", CommandBody.fromNamedSymbol("subseteq")!),

        // sum-like operators (4)
        spaceTriggered("sum", CommandBody.fromNamedSymbol("sum")!),
        spaceTriggered("prod", CommandBody.fromNamedSymbol("prod")!),
        spaceTriggered("int", CommandBody.fromNamedSymbol("int")!),
        spaceTriggered("oint", CommandBody.fromNamedSymbol("oint")!),

        // greek letters (no more than 4 chars; total: 17)
        spaceTriggered("beta", CommandBody.fromNamedSymbol("beta")!),
        spaceTriggered("chi", CommandBody.fromNamedSymbol("chi")!),
        spaceTriggered("eta", CommandBody.fromNamedSymbol("eta")!),
        spaceTriggered("iota", CommandBody.fromNamedSymbol("iota")!),
        spaceTriggered("mu", CommandBody.fromNamedSymbol("mu")!),
        spaceTriggered("nu", CommandBody.fromNamedSymbol("nu")!),
        spaceTriggered("phi", CommandBody.fromNamedSymbol("phi")!),
        spaceTriggered("pi", CommandBody.fromNamedSymbol("pi")!),
        spaceTriggered("psi", CommandBody.fromNamedSymbol("psi")!),
        spaceTriggered("rho", CommandBody.fromNamedSymbol("rho")!),
        spaceTriggered("tau", CommandBody.fromNamedSymbol("tau")!),
        spaceTriggered("xi", CommandBody.fromNamedSymbol("xi")!),
        spaceTriggered("zeta", CommandBody.fromNamedSymbol("zeta")!),
        spaceTriggered("Pi", CommandBody.fromNamedSymbol("Pi")!),
        spaceTriggered("Phi", CommandBody.fromNamedSymbol("Phi")!),
        spaceTriggered("Psi", CommandBody.fromNamedSymbol("Psi")!),
        spaceTriggered("Xi", CommandBody.fromNamedSymbol("Xi")!),

      ]

    do {
      // math variants
      for char in UnicodeScalar("A").value...UnicodeScalar("Z").value {
        let char = String(UnicodeScalar(char)!)
        results.append(spaceTriggered("bb\(char)", CommandBodies.mathbf(char)))
        results.append(spaceTriggered("bbb\(char)", CommandBodies.mathbb(char)))
        results.append(spaceTriggered("cc\(char)", CommandBodies.mathcal(char)))
        results.append(spaceTriggered("fr\(char)", CommandBodies.mathfrak(char)))
        results.append(spaceTriggered("sf\(char)", CommandBodies.mathsf(char)))
        results.append(spaceTriggered("tt\(char)", CommandBodies.mathtt(char)))
      }
      for char in UnicodeScalar("a").value...UnicodeScalar("z").value {
        let char = String(UnicodeScalar(char)!)
        results.append(spaceTriggered("bb\(char)", CommandBodies.mathbf(char)))
        results.append(spaceTriggered("sf\(char)", CommandBodies.mathsf(char)))
        results.append(spaceTriggered("tt\(char)", CommandBodies.mathtt(char)))
      }
    }

    do {
      let rules = MathOperator.predefinedCases.map {
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
}
