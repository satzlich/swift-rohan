// Copyright 2024 Lie Yan

struct CitationKey {
    let string: String

    init?(_ string: String) {
        guard CitationKey.validate(string) else {
            return nil
        }
        self.string = string
    }

    static func validate(_ string: String) -> Bool {
        return !string.isEmpty
    }
}
