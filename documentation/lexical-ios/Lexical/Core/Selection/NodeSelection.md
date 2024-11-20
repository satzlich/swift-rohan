
# NodeSelection

Selection of a set of nodes.

Member fields:

- `nodes: Set<NodeKey>`
- `dirty: Bool`

Member methods:

- `add(key: NodeKey)`: natural semantic. Mark selection as dirty.

- `delete(key: NodeKey)`: natural semantic. Mark selection as dirty.

- `clear(key: NodeKey)`: natural semantic. Mark selection as dirty.

- `has(key: NodeKey)`: natural semantic.

- `getNodes()`: natural semantic.

- `extract()`: Invokes `getNodes()`.

- `getTextContent() -> String`: Concates the text contents of the selected nodes.

- `insertRawText(_ text: String)`: No-op.

- `isSelection(_ selection: BaseSelection) -> Bool`: Check equality.

- `insertNodes(nodes: [Node], selectStart: Bool) -> Bool`: No-op.

- `deleteCharacter(isBackwards: Bool)`: Delete the selected set of nodes.

- `deleteWord(isBackwards: Bool)`: Delete the selected set of nodes.

- `deleteLine(isBackwards: Bool)`: Delete the selected set of nodes.

- `insertParagraph()`: 
    Inserts a paragraph at the selection.

    Works only when the selection encompasses a single node.

- `insertLineBreak(selectStart: Bool)`:
    Inserts a line break at the selection.

    Works only when the selection encompasses a single node.

- `insertText(_ text: String)`:
    Inserts `text` at the selection.

    Works only when the selection encompasses a single node.

- `isSingleNode() -> Bool`: True if the selection encompasses a single node.

- `rangeSelectionForNode(_ node: Node)`: 
    Converts given `node` to a range selection of the node.

