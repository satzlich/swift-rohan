// Copyright 2024 Lie Yan

public struct Document {
    private(set) var selection: Selection?

    public var isSelected: Bool {
        self.selection != nil
    }
}
