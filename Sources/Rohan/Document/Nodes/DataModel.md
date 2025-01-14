
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

