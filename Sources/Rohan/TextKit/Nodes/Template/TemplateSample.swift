// Copyright 2024-2025 Lie Yan

public enum TemplateSample {
  public static let newtonsLaw = {
    let content = Content {
      "a="
      Fraction(
        numerator: { "F" },
        denominator: { "m" })
    }
    let template = CompiledTemplate(
      name: TemplateName("newton"), parameterCount: 0, body: content,
      variableLocations: [:])

    return template
  }()

  public static let philipFox = {
    let content = Content {
      NamelessVariable(0)
      " is a good "
      Emphasis {
        NamelessVariable(1)
      }
      ", is "
      NamelessVariable(0)
      "?"
    }

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
    let content = Content {
      "{"
      NamelessVariable(0)
      " and "
      Emphasis {
        NamelessVariable(0)
      }
      "}"
    }
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
    let content = Content {
      Fraction(
        numerator: {
          Fraction(
            numerator: {
              NamelessVariable(1)
              "+1"
            },
            denominator: {
              NamelessVariable(0)
              "+1"
            })
        },
        denominator: {
          NamelessVariable(0)
          "+"
          NamelessVariable(1)
          "+1"
        })
    }
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
    let content = Content {
      "f("
      NamelessVariable(0)
      ","
      NamelessVariable(0)
      ")"
    }
    let argument0: Nano.VariableLocations = [[.index(1)], [.index(3)]]
    let variableLocations: Nano.VariableLocationsDict = [0: argument0]

    let template = CompiledTemplate(
      name: TemplateName("bifun"), parameterCount: 1, body: content,
      variableLocations: variableLocations)
    return template
  }()
}
