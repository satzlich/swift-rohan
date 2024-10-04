// Copyright 2024 Lie Yan

// MARK: - Label

struct Label {
    let name: String

    init?(_ name: String) {
        guard Label.validate(name) else {
            return nil
        }
        self.name = name
    }

    static func validate(_ string: String) -> Bool {
        return !string.isEmpty
    }
}
