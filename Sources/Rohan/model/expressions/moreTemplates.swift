// Copyright 2024 Lie Yan

import Collections
import Foundation

struct AnnotatedTemplate<A> {
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

typealias TemplateUses = Set<TemplateName>

/**
 variable name -> variable use paths
 */
typealias VariableUses = OrderedDictionary<Identifier, OrderedSet<TreePath>>

struct NamelessTemplate {
    let parameterCount: Int
    let body: Content

    /**

     ## Conditions to check
     * contains no apply, named or nameless;
     * variables are nameless;
     * variable indices are in range

     */
    public static func validateBody(_ body: Content,
                                    _ parameterCount: Int) -> Bool
    {
        false
    }
}
