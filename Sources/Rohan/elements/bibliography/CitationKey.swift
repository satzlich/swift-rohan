// Copyright 2024 Lie Yan

struct CitationKey: Equatable, Hashable {
    /**

     - intrinsic property
     - subject to syntax validation
     */
    public let text: String

    init?(_ text: String) {
        guard CitationKey.validateText(text) else {
            return nil
        }
        self.text = text
    }

    static func validateText(_ text: String) -> Bool {
        // TODO:
        //  Use BibTeX's syntax

        return !text.isEmpty
    }
}
