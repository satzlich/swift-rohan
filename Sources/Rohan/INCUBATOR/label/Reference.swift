// Copyright 2024 Lie Yan

struct Reference {
    public let labelName: String

    init(_ labelName: String) {
        precondition(Label.validate(name: labelName))
        self.labelName = labelName
    }
}
