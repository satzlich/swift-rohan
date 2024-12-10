// Copyright 2024 Lie Yan

import Collections
import Foundation

struct AnalyzedTemplate {
    let template: Template
    let expansion: [Node]
    let parameterPaths: [IdentifierName: OrderedSet<TreePath>]
}
