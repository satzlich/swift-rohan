
# Lexical/Core/Nodes

This directory contains all the built-in nodes. 

`Node`: Base class of all other nodes.

`DecoratorNode`: Base class of inline nodes which are non-textual in nature.

`ElementNode`: Base class of nodes that are equivalent to `Element`s in HTML.

`RootNode`: Root of document.

`UnknownNode`: Unrecognizable node.

--------

`CodeHighlightNode`: Simple subclass of `TextNode` with an extra field named `highlightType`.

`CodeNode`: ???


## Lexical/Core/Nodes/Node.swift

`NodeKey`: An alias for the `String` type, used as the unique identifier 
for each node.

Function `generateKey(node:)` is defined in 
`Lexical/Core/Utils.swift`.


## Lexical/Core/Nodes/DecoratorNode.swift

`DecoratorNode` serves as the base class for inline nodes with non-textual content, 
designed to seamlessly integrate into the text flow while maintaining their visual inline appearance.

Directions to explore:

- Subclasses of `DecoratorNode`
- Usage of method `DecoratorNode.decorate(view: UIView)`
- Read <doc:BuildingDecorators>
