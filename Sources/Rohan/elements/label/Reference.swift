// Copyright 2024 Lie Yan

struct Reference {
    public let labelName: String

    init?(_ labelName: String) {
        guard Label.validate(labelName) else {
            return nil
        }
        self.labelName = labelName
    }
}
