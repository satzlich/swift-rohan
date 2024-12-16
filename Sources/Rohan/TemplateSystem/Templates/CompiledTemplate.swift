// Copyright 2024 Lie Yan

import Collections

struct CompiledTemplate {
    let name: TemplateName
    let parameterCount: Int
    let body: Content
    let parameterUseLocations: Nano.VariableLocationsDict

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
