// Copyright 2024-2025 Lie Yan

struct SelectionPoint: Equatable, Hashable {
    let node: Node
    let offset: Int
    let version: VersionId

    init(_ node: Node, _ offset: Int, _ version: VersionId) {
        precondition(Self.validate(offset: offset))
        self.node = node
        self.offset = offset
        self.version = version
    }

    static func validate(offset: Int) -> Bool {
        return offset >= 0
    }

    static func == (lhs: SelectionPoint, rhs: SelectionPoint) -> Bool {
        ObjectIdentifier(lhs.node) == ObjectIdentifier(rhs.node) &&
            lhs.offset == rhs.offset &&
            lhs.version == rhs.version
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(node))
        hasher.combine(offset)
        hasher.combine(version)
    }
}

struct RangeSelection: SelectionProtocol {
    let anchor: SelectionPoint
    let focus: SelectionPoint
}
