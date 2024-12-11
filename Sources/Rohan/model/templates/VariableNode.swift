// Copyright 2024 Lie Yan

import Foundation

/**
 Reference to variable used in template definition.
 */
final class VariableNode: Node {
    let name: Identifier

    init(_ name: Identifier) {
        self.name = name
        super.init()
    }

    #if TESTING
    convenience init?(_ name: String) {
        guard let name = Identifier(name) else {
            return nil
        }
        self.init(name)
    }
    #endif

    override final class func getType() -> NodeType {
        .variable
    }
}
