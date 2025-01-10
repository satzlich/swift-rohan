// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    // MARK: - Key

    public struct Key: Equatable, Hashable, Codable {
        let nodeType: NodeType
        let propertyName: Name

        init(_ nodeType: NodeType, _ propertyName: Name) {
            self.nodeType = nodeType
            self.propertyName = propertyName
        }
    }
}

