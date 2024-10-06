// Copyright 2024 Lie Yan

struct CitationKey: Equatable, Hashable {
    /**

     - intrinsic property
     - subject to syntax validation
     */
    public let text: String

    init?(_ text: String) {
        guard CitationKey.validateSyntax(text) else {
            return nil
        }
        self.text = text
    }

    static func validateSyntax(_ text: String) -> Bool {
        // TODO:
        //  Use BibTeX's syntax

        return !text.isEmpty
    }
}
