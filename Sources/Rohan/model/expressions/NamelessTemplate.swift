// Copyright 2024 Lie Yan

struct NamelessTemplate {
    let parameterCount: Int
    let body: Content

    /**

     ## Conditions to check
     * contains no apply, named or nameless;
     * variables are nameless;
     * variable indices are in range

     */
    public static func validate(body: Content,
                                _ parameterCount: Int) -> Bool
    {
        preconditionFailure("Not implemented")
    }
}
