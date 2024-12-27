// Copyright 2024 Lie Yan

struct SelectionPoint {
    let node: NodeKey
    let offset: Int

    init(_ node: NodeKey, _ offset: Int) {
        precondition(Self.validate(offset: offset))
        self.node = node
        self.offset = offset
    }

    static func validate(offset: Int) -> Bool {
        return offset >= 0
    }
}

struct RangeSelection: SelectionProtocol {
    let anchor: SelectionPoint
    let focus: SelectionPoint
}
