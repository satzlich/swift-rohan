// Copyright 2024 Lie Yan

import Collections

struct AnnotatedTemplate<A> {
    typealias Annotation = A

    let canonical: Template
    let annotation: A

    var name: TemplateName {
        canonical.name
    }

    init(_ canonical: Template, annotation: A) {
        self.canonical = canonical
        self.annotation = annotation
    }
}

typealias TemplateCalls = Set<TemplateName>

/**
 variable name -> variable use paths
 */
typealias VariablePaths = Dictionary<Identifier, OrderedSet<TreePath>>
