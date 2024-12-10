// Copyright 2024 Lie Yan

import Foundation

/**
 Reference to variable used in template definition.
 */
final class VariableNode: Node {
    let name: IdentifierName

    #if TESTING
    convenience init?(_ name: String) {
        guard let name = IdentifierName(name) else {
            return nil
        }
        self.init(name)
    }
    #endif

    init(_ name: IdentifierName) {
        self.name = name
        super.init()
    }

    override final class func getType() -> NodeType {
        .variable
    }
}
