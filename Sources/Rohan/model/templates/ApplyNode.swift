// Copyright 2024 Lie Yan

import Foundation

final class ApplyNode: Node {
    var templateName: Identifier
    var arguments: [ContentNode]

    init(_ templateName: Identifier, arguments: [ContentNode]) {
        self.templateName = templateName
        self.arguments = arguments

        super.init()
    }

    #if TESTING
    convenience init?(_ templateName: String, arguments: [Node] ...) {
        guard let templateName = Identifier(templateName) else {
            return nil
        }
        self.init(templateName, arguments: arguments.map { ContentNode($0) })
    }
    #endif

    var children: [Node] {
        preconditionFailure("not implemented")
    }

    override final class func getType() -> NodeType {
        .apply
    }
}
