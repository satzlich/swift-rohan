// Copyright 2024 Lie Yan

import Foundation

struct AttributeKey: Equatable, Hashable, Codable {
    let nodeType: NodeType
    let attributeName: AttributeName

    init(_ nodeType: NodeType, _ attributeName: AttributeName) {
        self.nodeType = nodeType
        self.attributeName = attributeName
    }
}
