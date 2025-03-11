// Copyright 2024-2025 Lie Yan

public enum TemplateSample {
  public static let newtonsLaw = {
    let content = [
      TextExpr("a="),
      FractionExpr(
        numerator: [TextExpr("F")], denominator: [TextExpr("m")]),
    ]
    let template = CompiledTemplate(
      name: TemplateName("newton"), parameterCount: 0, body: content,
      variableLocations: [:])

    return template
  }()

  public static let philipFox = {
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

    let argument0: Nano.VariableLocations = [
      [.index(0)],
      [.index(4)],
    ]
    let argument1: Nano.VariableLocations = [
      [.index(2), .index(0)]
    ]

    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0,
      1: argument1,
    ]

    let template = CompiledTemplate(
      name: TemplateName("philipFox"), parameterCount: 2, body: content,
      variableLocations: variableLocations)

    return template
  }()

  public static let doubleText = {
    let content = [
      TextExpr("{"),
      UnnamedVariableExpr(0),
      TextExpr(" and "),
      EmphasisExpr([
        UnnamedVariableExpr(0)
      ]),
      TextExpr("}"),
    ]
    let argument0: Nano.VariableLocations = [
      [.index(1)],
      [.index(3), .index(0)],
    ]
    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0
    ]

    let template = CompiledTemplate(
      name: TemplateName("doubleText"), parameterCount: 1, body: content,
      variableLocations: variableLocations)

    return template
  }()

  public static let complexFraction = {
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

    let argument0: Nano.VariableLocations = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.denominator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(0)],
    ]
    let argument1: Nano.VariableLocations = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.numerator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(2)],
    ]
    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0,
      1: argument1,
    ]

    let template = CompiledTemplate(
      name: TemplateName("complexFraction"), parameterCount: 2, body: content,
      variableLocations: variableLocations)
    return template
  }()

  public static let bifun = {
    let content = [
      TextExpr("f("),
      UnnamedVariableExpr(0),
      TextExpr(","),
      UnnamedVariableExpr(0),
      TextExpr(")"),
    ]
    let argument0: Nano.VariableLocations = [[.index(1)], [.index(3)]]
    let variableLocations: Nano.VariableLocationsDict = [0: argument0]

    let template = CompiledTemplate(
      name: TemplateName("bifun"), parameterCount: 1, body: content,
      variableLocations: variableLocations)
    return template
  }()
}
