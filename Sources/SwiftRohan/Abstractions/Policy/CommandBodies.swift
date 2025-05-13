// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  // text

  static let emphasis = CommandBody([EmphasisExpr([])], .inlineContent, 1)
  static let strong = CommandBody([StrongExpr([])], .inlineContent, 1)

  static let equation =
    CommandBody([EquationExpr(isBlock: true, [])], .containsBlock, 1)
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, [])], .inlineContent, 1)

  // math
  static let overline =
    CommandBody([OverlineExpr([])], .mathContent, 1, image: "overline")
  static let underline =
    CommandBody([UnderlineExpr([])], .mathContent, 1, image: "underline")

  static let sqrt = CommandBody([RadicalExpr([])], .mathContent, 1, image: "sqrt")
  static let root = CommandBody([RadicalExpr([], [])], .mathContent, 2, image: "root")

  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3, image: "lrsub")

  static let textMode = CommandBody([TextModeExpr([])], .mathContent, 1)

  // MARK: - Methods

  // text

  static func header(level: Int) -> CommandBody {
    let exprs = [HeadingExpr(level: level, [])]
    return CommandBody(exprs, .topLevelNodes, 1)
  }

  // math

  static func attachMathComponent(_ index: MathIndex) -> CommandBody {
    CommandBody(.addComponent(index))
  }

  static func accent(_ char: Character) -> CommandBody {
    let exprs = [AccentExpr(char, [])]
    let preview = "\(Chars.dottedSquare)\(char)"
    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func aligned(
    _ rowCount: Int, _ columnCount: Int, image imageName: String
  ) -> CommandBody {
    let rows: [AlignedExpr.Row] = (0..<rowCount).map { _ in
      let elements: [AlignedExpr.Element] = (0..<columnCount).map { _ in
        AlignedExpr.Element()
      }
      return AlignedExpr.Row(elements)
    }
    let exprs = [AlignedExpr(rows)]
    let n = rowCount * columnCount
    return CommandBody(exprs, .mathContent, n, image: imageName)
  }

  static func cases(_ count: Int, image imageName: String) -> CommandBody {
    let rows: [CasesExpr.Row] = (0..<count).map { _ in
      let element = CasesExpr.Element()
      return CasesExpr.Row([element])
    }
    let exprs = [CasesExpr(rows)]
    return CommandBody(exprs, .mathContent, count, image: imageName)
  }

  static func genfrac(_ subtype: FractionNode.Subtype, image image: String) -> CommandBody
  {
    CommandBody(
      [FractionExpr(num: [], denom: [], subtype: subtype)],
      .mathContent, 2, image: image)
  }

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    precondition(Delimiter.validate(left) && Delimiter.validate(right))
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let exprs = [LeftRightExpr(delimiters, [])]
    let preview = "\(left)\(Chars.dottedSquare)\(right)"

    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func mathVariant(
    _ mathVariant: MathVariant?, bold: Bool?, italic: Bool?, _ preview: String
  ) -> CommandBody {
    let exprs = [MathVariantExpr(mathVariant, bold: bold, italic: italic, [])]
    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair,
    image imageName: String
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] = (0..<columnCount).map { _ in
        MatrixExpr.Element()
      }
      return MatrixExpr.Row(elements)
    }
    let exprs = [MatrixExpr(delimiters, rows)]
    let n = rowCount * columnCount

    return CommandBody(exprs, .mathContent, n, image: imageName)
  }

  static func overSpreader(_ char: Character, image imageName: String) -> CommandBody {
    let exprs = [OverspreaderExpr(char, [])]
    return CommandBody(exprs, .mathContent, 1, image: imageName)
  }

  static func underSpreader(_ char: Character, image imageName: String) -> CommandBody {
    let exprs = [UnderspreaderExpr(char, [])]
    return CommandBody(exprs, .mathContent, 1, image: imageName)
  }

  // MARK: - Math Operator

  static func mathOperator(_ name: String, _ limits: Bool = false) -> CommandBody {
    let exprs = [MathOperatorExpr([TextExpr(name)], limits)]
    let preview = "\(name)"
    return CommandBody(exprs, .mathContent, 0, preview)
  }
}

enum MathOperators {
  /*
   arccos, arcsin, arctan, arg, cos, cosh, cot, coth, csc, csch, ctg, deg, det, dim,
   exp, gcd, lcm, hom, id, im, inf, ker, lg, lim, liminf, limsup, ln, log, max, min,
   mod, Pr, sec, sech, sin, sinc, sinh, sup, tan, tanh, tg and tr.
   */
  static let arccos = CommandBodies.mathOperator("arccos")
  static let arcsin = CommandBodies.mathOperator("arcsin")
  static let arctan = CommandBodies.mathOperator("arctan")
  static let arg = CommandBodies.mathOperator("arg")
  static let cos = CommandBodies.mathOperator("cos")
  static let cosh = CommandBodies.mathOperator("cosh")
  static let cot = CommandBodies.mathOperator("cot")
  static let coth = CommandBodies.mathOperator("coth")
  static let csc = CommandBodies.mathOperator("csc")
  static let csch = CommandBodies.mathOperator("csch")
  static let ctg = CommandBodies.mathOperator("ctg")
  static let deg = CommandBodies.mathOperator("deg")
  static let det = CommandBodies.mathOperator("det")
  static let dim = CommandBodies.mathOperator("dim")
  static let exp = CommandBodies.mathOperator("exp")
  static let gcd = CommandBodies.mathOperator("gcd")
  static let lcm = CommandBodies.mathOperator("lcm")
  static let hom = CommandBodies.mathOperator("hom")
  static let id = CommandBodies.mathOperator("id")
  static let im = CommandBodies.mathOperator("im")
  static let inf = CommandBodies.mathOperator("inf", true)
  static let ker = CommandBodies.mathOperator("ker")
  static let lg = CommandBodies.mathOperator("lg")
  static let lim = CommandBodies.mathOperator("lim", true)
  static let liminf = CommandBodies.mathOperator("lim\u{2009}inf", true)
  static let limsup = CommandBodies.mathOperator("lim\u{2009}sup", true)
  static let ln = CommandBodies.mathOperator("ln")
  static let log = CommandBodies.mathOperator("log")
  static let max = CommandBodies.mathOperator("max", true)
  static let min = CommandBodies.mathOperator("min", true)
  static let mod = CommandBodies.mathOperator("mod")
  static let Pr = CommandBodies.mathOperator("Pr")
  static let sec = CommandBodies.mathOperator("sec")
  static let sech = CommandBodies.mathOperator("sech")
  static let sin = CommandBodies.mathOperator("sin")
  static let sinc = CommandBodies.mathOperator("sinc")
  static let sinh = CommandBodies.mathOperator("sinh")
  static let sup = CommandBodies.mathOperator("sup", true)
  static let tan = CommandBodies.mathOperator("tan")
  static let tanh = CommandBodies.mathOperator("tanh")
  static let tg = CommandBodies.mathOperator("tg")
  static let tr = CommandBodies.mathOperator("tr")
}
