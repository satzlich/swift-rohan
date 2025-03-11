// Copyright 2024-2025 Lie Yan

public enum TemplateSample {
  public static var newtonsLaw: CompiledTemplate {
    let content = [
      TextExpr("a="),
      FractionExpr(
        numerator: [TextExpr("F")], denominator: [TextExpr("m")]),
    ]
    return CompiledTemplate(TemplateName("newton"), 0, content, [])
  }

  public static var philipFox: CompiledTemplate {
    let content = [
      UnnamedVariableExpr(0),
      TextExpr(" is a good "),
      EmphasisExpr([
        UnnamedVariableExpr(1)
      ]),
      TextExpr(", is "),
      UnnamedVariableExpr(0),
      TextExpr("?"),
    ]
    let argument0: VariablePaths = [
      [.index(0)],
      [.index(4)],
    ]
    let argument1: VariablePaths = [
      [.index(2), .index(0)]
    ]
    return CompiledTemplate(TemplateName("philipFox"), 2, content, [argument0, argument1])
  }

  public static var doubleText: CompiledTemplate {
    let content = [
      TextExpr("{"),
      UnnamedVariableExpr(0),
      TextExpr(" and "),
      EmphasisExpr([
        UnnamedVariableExpr(0)
      ]),
      TextExpr("}"),
    ]
    let argument0: VariablePaths = [
      [.index(1)],
      [.index(3), .index(0)],
    ]
    return CompiledTemplate(TemplateName("doubleText"), 1, content, [argument0])
  }

  public static var complexFraction: CompiledTemplate {
    let content = [
      FractionExpr(
        numerator: [
          FractionExpr(
            numerator: [UnnamedVariableExpr(1), TextExpr("+1")],
            denominator: [UnnamedVariableExpr(0), TextExpr("+1")])
        ],
        denominator: [
          UnnamedVariableExpr(0),
          TextExpr("+"),
          UnnamedVariableExpr(1),
          TextExpr("+1"),
        ])
    ]

    let argument0: VariablePaths = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.denominator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(0)],
    ]
    let argument1: VariablePaths = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.numerator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(2)],
    ]
    return CompiledTemplate(TemplateName("complexFraction"), 2, content, [argument0, argument1])
  }

  public static var bifun: CompiledTemplate {
    let content = [
      TextExpr("f("),
      UnnamedVariableExpr(0),
      TextExpr(","),
      UnnamedVariableExpr(0),
      TextExpr(")"),
    ]
    let argument0: VariablePaths = [[.index(1)], [.index(3)]]
    return CompiledTemplate(TemplateName("bifun"), 1, content, [argument0])
  }
}
