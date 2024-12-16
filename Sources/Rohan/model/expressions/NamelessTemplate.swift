// Copyright 2024 Lie Yan

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
        let apply = Espresso.CountingAction { $0.type == .apply }
        let variable = Espresso.CountingAction { $0.type == .variable }
        let violation = Espresso.CountingAction {
            $0.type == .namelessVariable &&
                $0.unwrapNamelessVariable()!.index >= parameterCount
        }

        let (applyCount, variableCount, violationCount) =
            Espresso.play(actions: apply, variable, violation, on: body)

        return applyCount.count == 0 &&
            variableCount.count == 0 &&
            violationCount.count == 0
    }
}
