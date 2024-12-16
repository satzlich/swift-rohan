// Copyright 2024 Lie Yan

import Foundation

struct PropertyKey: Equatable, Hashable, Codable {
    let nodeType: NodeType
    let propertyName: PropertyName

    init(_ nodeType: NodeType, _ propertyName: PropertyName) {
        self.nodeType = nodeType
        self.propertyName = propertyName
    }
}
