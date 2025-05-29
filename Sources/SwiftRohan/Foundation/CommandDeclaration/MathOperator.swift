// Copyright 2024-2025 Lie Yan

import Foundation

struct MathOperator: Codable, CommandDeclarationProtocol {
  /// Command sequence.
  let command: String
  /// Operator text.
  let string: String
  /// true if limits are used.
  let limits: Limits

  init(_ command: String, _ string: String, _ limits: Bool = false) {
    self.command = command
    self.string = string
    self.limits = limits ? .display : .never
  }
}

extension MathOperator {
  static let allCommands: [MathOperator] = [
    // total: 32 (Table 203: Log-like Symbols)
    .arccos, .arcsin, .arctan, .arg,
    .cos, .cosh, .cot, .coth,
    .csc, .deg, .det, .dim,
    .exp, .gcd, .hom, .inf,
    .ker, .lg, .lim, .liminf,
    .limsup, .ln, .log, .max,
    .min, .Pr, .sec, .sin,
    .sinh, .sup, .tan, .tanh,
    // total 6 (Table 204: Log-like Symbols)
    .injlim, .projlim,
    // `varinjlim, varliminf, varlimsup, varprojlim` defined as MathExpression's

    // other (9)
    .csch, .ctg, .lcm, .id,
    .im, .sech, .sinc, .tg,
    .tr,
  ]

  private static let _dictionary: [String: MathOperator] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathOperator? {
    _dictionary[command]
  }

  /*
   arccos, arcsin, arctan, arg, cos, cosh, cot, coth, csc,
   csch, ctg, deg, det, dim, exp, gcd, lcm, hom, id,
   im, inf, ker, lg, lim, liminf, limsup, ln,
   log, max, min, Pr, sec,
   sech, sin, sinc, sinh, sup, tan, tanh, tg and tr.
   */
  static let arccos = MathOperator("arccos", "arccos")
  static let arcsin = MathOperator("arcsin", "arcsin")
  static let arctan = MathOperator("arctan", "arctan")
  static let arg = MathOperator("arg", "arg")
  static let cos = MathOperator("cos", "cos")
  static let cosh = MathOperator("cosh", "cosh")
  static let cot = MathOperator("cot", "cot")
  static let coth = MathOperator("coth", "coth")
  static let csc = MathOperator("csc", "csc")
  static let csch = MathOperator("csch", "csch")
  static let ctg = MathOperator("ctg", "ctg")
  static let deg = MathOperator("deg", "deg")
  static let det = MathOperator("det", "det")
  static let dim = MathOperator("dim", "dim")
  static let exp = MathOperator("exp", "exp")
  static let gcd = MathOperator("gcd", "gcd", true)
  static let lcm = MathOperator("lcm", "lcm")
  static let hom = MathOperator("hom", "hom")
  static let id = MathOperator("id", "id")
  static let im = MathOperator("im", "im")
  static let inf = MathOperator("inf", "inf", true)
  static let injlim = MathOperator("injlim", "inj\u{2009}lim", true)
  static let ker = MathOperator("ker", "ker")
  static let lg = MathOperator("lg", "lg")
  static let lim = MathOperator("lim", "lim", true)
  static let liminf = MathOperator("liminf", "lim\u{2009}inf", true)
  static let limsup = MathOperator("limsup", "lim\u{2009}sup", true)
  static let ln = MathOperator("ln", "ln")
  static let log = MathOperator("log", "log")
  static let max = MathOperator("max", "max", true)
  static let min = MathOperator("min", "min", true)
  static let Pr = MathOperator("Pr", "Pr", true)
  static let projlim = MathOperator("projlim", "proj\u{2009}lim", true)
  static let sec = MathOperator("sec", "sec")
  static let sech = MathOperator("sech", "sech")
  static let sin = MathOperator("sin", "sin")
  static let sinc = MathOperator("sinc", "sinc")
  static let sinh = MathOperator("sinh", "sinh")
  static let sup = MathOperator("sup", "sup", true)
  static let tan = MathOperator("tan", "tan")
  static let tanh = MathOperator("tanh", "tanh")
  static let tg = MathOperator("tg", "tg")
  static let tr = MathOperator("tr", "tr")
}
