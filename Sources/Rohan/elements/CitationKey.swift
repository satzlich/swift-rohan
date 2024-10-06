// Copyright 2024 Lie Yan

struct CitationKey: Equatable, Hashable {
    let key: String

    init?(_ key: String) {
        guard CitationKey.validate(key) else {
            return nil
        }
        self.key = key
    }

    static func validate(_ key: String) -> Bool {
        // TODO: implement

        return key.isEmpty == false
    }
}
