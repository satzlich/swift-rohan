// Copyright 2024 Lie Yan

struct Label {
    public let name: String

    init(_ name: String) {
        precondition(Label.validate(name: name))
        self.name = name
    }

    static func validate(name: String) -> Bool {
        CiteKey.validate(string: name)
    }
}
