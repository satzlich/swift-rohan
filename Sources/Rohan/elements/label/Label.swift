// Copyright 2024 Lie Yan

struct Label {
    public let name: String

    init?(_ name: String) {
        guard Label.validate(name) else {
            return nil
        }
        self.name = name
    }

    static func validate(_ name: String) -> Bool {
        // TODO:
        //  Use a certain syntax. Define it.
        return !name.isEmpty
    }
}
