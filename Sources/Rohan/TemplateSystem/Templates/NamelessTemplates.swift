// Copyright 2024 Lie Yan

struct NamelessTemplates { }

struct NamelessTemplate {
    let parameterCount: Int
    let body: Content

    /**

     ## Conditions to check
     * contains no apply, named or nameless;
     * contains no named variables;
     * variable indices are in range

     */
    public static func validate(body: Content,
                                _ parameterCount: Int) -> Bool
    {
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
