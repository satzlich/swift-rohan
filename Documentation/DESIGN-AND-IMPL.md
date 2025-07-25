
# Design and Implementation

We divide the functionality of an editor into the following main components:

- The document model, which represents the text and structure of the document.
- The style model, which defines how the document is presented visually.
- The editing model, which manages user interactions and modifications to the document.
- The layout model, which determines how the document is rendered on the screen and how it responds to user input.
- The abstraction mechanism, which allows for composition of new document elements.


## Document Model

The document model is a tree of nodes, where each node represents a piece of text or a structural element (like a paragraph or a heading). Nodes are classified into different types, such as text nodes, paragraph nodes, and heading nodes. Each node has its own `id`.

## Style Model

The style of the document is defined by a set of CSS-like rules that can be applied to nodes in the document model. Each node can have style rules applied to it, allowing for complex visual representations. Each node can have node-specific style rules, which are applied to that node or node type only.

Each node holds a property dictionary that contains its style properties. The style model allows for inheritance, where child nodes can inherit styles from their parent nodes. The style model plays an important role in math layout, as it defines how mathematical expressions are displayed.

## Editing Model

The editing model is responsible for handling user interactions, such as typing, deleting, and formatting text. It manages the cursor position, selection ranges, and input events. The editing model also handles undo/redo operations, allowing users to revert changes made to the document.

A compositor window is provided to the end user to type in non-text elements, such as mathematical expressions or special characters. The compositor window allows users to input complex structures that are not easily typed on a standard keyboard.

Besides, replacement mechanisms are provided to allow users to replace text with predefined elements, such as mathematical symbols or special characters. This is particularly useful for mathematical editing, where users often need to insert complex symbols or structures.

## Layout Model

The layout model is responsible for rendering the document on the screen. It takes into account the styles defined in the style model and the structure of the document model. The layout model determines how text is wrapped, how paragraphs are aligned, and how elements are positioned on the canvas.

Since we delegate the layout to TextKit 2, we can focus on the higher-level abstractions and interactions. TextKit 2 provides a powerful layout engine that can handle complex text layouts, including mathematical expressions and other non-text elements. To enable math layout, we leverage TextKit 2's capabilities to plug in custom attachments.

Layout process is unified by the `LayoutContext` protocol. Layout process is carried out in the `performLayout` method with `LayoutContext` as a parameter, each node maintains how many units it occupies in the layout. The `LayoutContext` provides methods to access the layout information of nodes, such as their positions and sizes.

## Abstraction Mechanism

The abstraction mechanism allows for the composition of new document elements. It provides a way to define 
new commands out of existing document elements, enabling developers to create complex structures without needing to do ad-hoc implementations.

Composed document elements are instantiated as objects of `ApplyNode`.

