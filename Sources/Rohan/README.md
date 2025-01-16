
## Overview

- Document model
- Edit model
- Style sheet     ✓
- Template system ✓
- Layout
- Reconcile algorithm
    - Reconcile out-of-sync template arguments to restore argument-and-use consistency
    - Reconcile dirty nodes to restore data-and-layout consistency
- Input method

## Data Model

- Node category
    - TextNode
    - ElementNode(children)
    - MathNode(components)

- ElementNode:
    - RootNode
    - ContentNode
    - EmphasisNode
    - HeadingNode(level)
    - ParagraphNode

- MathNode:
    - EquationNode(isBlock, nucleus)
    - ScriptsNode( subScript ∨ superScript )
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)

- Abstraction mechanism
    - ApplyNode(templateName)
        - children (immutable nodes and mutable uses of arguments)
    - NamelessVariableNode(index, content)

