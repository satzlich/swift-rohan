// Copyright 2024 Lie Yan

import Collections
import Foundation

final class ApplyNode: ElementNode {
    let templateName: TemplateName
    let variableLocations: [OrderedSet<TreePath>]

    init(templateName: TemplateName,
         variableLocations: [OrderedSet<TreePath>],
         _ children: [Node])
    {
        self.templateName = templateName
        self.variableLocations = variableLocations
        super.init(children)
    }

    override class var type: NodeType {
        .apply
    }
}

final class VariableNode: ElementNode {
    let index: Int

    init(index: Int, _ children: [Node]) {
        precondition(NamelessVariable.validate(index: index))
        self.index = index
        super.init(children)
    }

    override class var type: NodeType {
        .variable
    }
}
