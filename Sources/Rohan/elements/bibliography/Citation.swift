// Copyright 2024 Lie Yan

struct Citation {
    let citationKey: String

    init?(_ citationKey: String) {
        guard Citation.validate(citationKey) else {
            return nil
        }
        self.citationKey = citationKey
    }

    static func validate(_ string: String) -> Bool {
        return !string.isEmpty
    }
}
