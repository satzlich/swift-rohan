
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

- `deleteCharacter(isBackwards: Bool)`: ???