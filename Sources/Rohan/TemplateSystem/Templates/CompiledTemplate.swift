// Copyright 2024 Lie Yan

import Collections

struct CompiledTemplate {
    let name: TemplateName
    let parameterCount: Int
    let body: Content
    let variableLocations: [Nano.VariableLocations]

    init(
        name: TemplateName,
        parameterCount: Int,
        body: Content,
        variableLocations: Nano.VariableLocationsDict
    ) {
        precondition(Self.validate(body: body, parameterCount))

        self.name = name
        self.parameterCount = parameterCount
        self.body = body
        self.variableLocations = Self.convert(variableLocations: variableLocations,
                                              parameterCount)
    }

    static func convert(variableLocations: Nano.VariableLocationsDict,
                        _ parameterCount: Int) -> [Nano.VariableLocations]
    {
        precondition(variableLocations.keys.allSatisfy { $0 < parameterCount })
        var output = [Nano.VariableLocations](repeating: .init(), count: parameterCount)
        for (index, locations) in variableLocations {
            output[index] = locations
        }
        return output
    }

    static func validate(body: Content, _ parameterCount: Int) -> Bool {
        /*
         Conditions to check:
         - contains no apply, whether named or nameless;
         - contains no named variables;
         - variable indices are in range
         */
        let countApply = Espresso.CountingAction { $0.type == .apply }
        let countVariable = Espresso.CountingAction { $0.type == .variable }
        let countViolation = Espresso.CountingAction {
            $0.type == .namelessVariable &&
                $0.unwrapNamelessVariable()!.index >= parameterCount
        }

        let (apply, variable, violation) =
            Espresso.play(actions: countApply, countVariable, countViolation,
                          on: body)

        return apply.count == 0 &&
            variable.count == 0 &&
            violation.count == 0
    }
}
