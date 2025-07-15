// Copyright 2024-2025 Lie Yan

public enum CompiledSamples {
  public static var newtonsLaw: CompiledTemplate {
    let content = [
      TextExpr("a="),
      FractionExpr(num: [TextExpr("F")], denom: [TextExpr("m")]),
    ]
    return CompiledTemplate("newton", content, .inline, [])
  }

  public static var philipFox: CompiledTemplate {
    let content = [
      CompiledVariableExpr(0, .inline, false),
      TextExpr(" is a good "),
      TextStylesExpr(
        .emph,
        [
          CompiledVariableExpr(1, .inline, false)
        ]),
      TextExpr(", is "),
      CompiledVariableExpr(0, .inline, false),
      TextExpr("?"),
    ]
    let argument0: VariablePaths = [
      [.index(0)],
      [.index(4)],
    ]
    let argument1: VariablePaths = [
      [.index(2), .index(0)]
    ]
    return CompiledTemplate("philipFox", content, .inline, [argument0, argument1])
  }

  public static var doubleText: CompiledTemplate {
    let content = [
      TextExpr("{"),
      CompiledVariableExpr(0, .inline, false),
      TextExpr(" and "),
      TextStylesExpr(.emph, [CompiledVariableExpr(0, .inline, false)]),
      TextExpr("}"),
    ]
    let argument0: VariablePaths = [
      [.index(1)],
      [.index(3), .index(0)],
    ]
    return CompiledTemplate("doubleText", content, .inline, [argument0])
  }

  public static var complexFraction: CompiledTemplate {
    let content = [
      FractionExpr(
        num: [
          FractionExpr(
            num: [CompiledVariableExpr(1, .inline, false), TextExpr("+1")],
            denom: [CompiledVariableExpr(0, .inline, false), TextExpr("+1")])
        ],
        denom: [
          CompiledVariableExpr(0, .inline, false),
          TextExpr("+"),
          CompiledVariableExpr(1, .inline, false),
          TextExpr("+1"),
        ])
    ]

    let argument0: VariablePaths = [
      [
        .index(0), .mathIndex(.num), .index(0), .mathIndex(.denom), .index(0),
      ],
      [.index(0), .mathIndex(.denom), .index(0)],
    ]
    let argument1: VariablePaths = [
      [.index(0), .mathIndex(.num), .index(0), .mathIndex(.num), .index(0)],
      [.index(0), .mathIndex(.denom), .index(2)],
    ]
    return CompiledTemplate("complexFraction", content, .inline, [argument0, argument1])
  }

  public static var bifun: CompiledTemplate {
    let content = [
      TextExpr("f("),
      CompiledVariableExpr(0, .inline, false),
      TextExpr(","),
      CompiledVariableExpr(0, .inline, false),
      TextExpr(")"),
    ]
    let argument0: VariablePaths = [[.index(1)], [.index(3)]]
    return CompiledTemplate("bifun", content, .inline, [argument0])
  }
}
