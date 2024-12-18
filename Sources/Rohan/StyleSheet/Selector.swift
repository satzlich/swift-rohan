// Copyright 2024 Lie Yan

struct Selector: Equatable, Hashable, Codable {
    /**
     Target node type
     */
    let type: NodeType

    /**
     Target intrinsic property to match
     */
    let matcher: PropertyMatcher?

    init(_ type: NodeType, _ matcher: PropertyMatcher? = nil) {
        self.type = type
        self.matcher = matcher
    }
}

struct PropertyMatcher: Equatable, Hashable, Codable {
    let name: PropertyName
    let value: PropertyValue

    init(_ name: PropertyName, _ value: PropertyValue) {
        self.name = name
        self.value = value
    }
}
