// Copyright 2024 Lie Yan

struct Label {
    public let name: String

    init(_ name: String) {
        precondition(Label.validateName(name))
        self.name = name
    }

    static func validateName(_ name: String) -> Bool {
        CiteKey.validateText(name)
    }
}
