// Copyright 2024 Lie Yan

struct Reference {
    public let labelName: String

    init(_ labelName: String) {
        precondition(Label.validateName(labelName))
        self.labelName = labelName
    }
}
