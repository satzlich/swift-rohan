// Copyright 2024-2025 Lie Yan

public enum CompiledSamples {
  public static var newtonsLaw: CompiledTemplate {
    let content = [
      TextExpr("a="),
      FractionExpr(numerator: [TextExpr("F")], denominator: [TextExpr("m")]),
    ]
    return CompiledTemplate("newton", content, [])
  }

  public static var philipFox: CompiledTemplate {
    let content = [
      CompiledVariableExpr(0),
      TextExpr(" is a good "),
      EmphasisExpr([
        CompiledVariableExpr(1)
      ]),
      TextExpr(", is "),
      CompiledVariableExpr(0),
      TextExpr("?"),
    ]
    let argument0: VariablePaths = [
      [.index(0)],
      [.index(4)],
    ]
    let argument1: VariablePaths = [
      [.index(2), .index(0)]
    ]
    return CompiledTemplate("philipFox", content, [argument0, argument1])
  }

  public static var doubleText: CompiledTemplate {
    let content = [
      TextExpr("{"),
      CompiledVariableExpr(0),
      TextExpr(" and "),
      EmphasisExpr([
        CompiledVariableExpr(0)
      ]),
      TextExpr("}"),
    ]
    let argument0: VariablePaths = [
      [.index(1)],
      [.index(3), .index(0)],
    ]
    return CompiledTemplate("doubleText", content, [argument0])
  }

  public static var complexFraction: CompiledTemplate {
    let content = [
      FractionExpr(
        numerator: [
          FractionExpr(
            numerator: [CompiledVariableExpr(1), TextExpr("+1")],
            denominator: [CompiledVariableExpr(0), TextExpr("+1")])
        ],
        denominator: [
          CompiledVariableExpr(0),
          TextExpr("+"),
          CompiledVariableExpr(1),
          TextExpr("+1"),
        ])
    ]

    let argument0: VariablePaths = [
      [
        .index(0), .mathIndex(.num), .index(0), .mathIndex(.denominator), .index(0),
      ],
      [.index(0), .mathIndex(.denominator), .index(0)],
    ]
    let argument1: VariablePaths = [
      [.index(0), .mathIndex(.num), .index(0), .mathIndex(.num), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(2)],
    ]
    return CompiledTemplate("complexFraction", content, [argument0, argument1])
  }

  public static var bifun: CompiledTemplate {
    let content = [
      TextExpr("f("),
      CompiledVariableExpr(0),
      TextExpr(","),
      CompiledVariableExpr(0),
      TextExpr(")"),
    ]
    let argument0: VariablePaths = [[.index(1)], [.index(3)]]
    return CompiledTemplate("bifun", content, [argument0])
  }
}
