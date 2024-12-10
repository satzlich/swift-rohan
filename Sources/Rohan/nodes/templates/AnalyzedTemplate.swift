// Copyright 2024 Lie Yan

import Collections
import Foundation

struct AnalyzedTemplate {
    let template: Template

    let expansion: [Node]

    /**
     Paths to parameter use in the template expansion.
     */
    let usePaths: [IdentifierName: OrderedSet<TreePath>]
}
