
# Lexical/Core/EditorState.swift

## `kRootNodeKey`

`kRootNodeKey`: the node key for the root node. Each editor state has a
single root node.


## `EditorState`

An `EditorState` contains nodes and a selection.

Member fields:

- Mapping from `NodeKey` to `Node`
- Selection

Member methods:

- `init()`: Initializes the instance with a single root node.

- `init(_ editorState:)`: Initializes the instance with given `EditorState`.

- `getRootNode()`: Returns the root node.

- `getNodeMap()`: Returns the node map.

- `read<V>(closure: () -> V) -> V`: ???

- `clone(selection: RangeSelection?) -> EditorState`: Clones this instance, 
optionally adding a new selection.

- `static ==(lhs:, rhs:) -> Bool`: Checks equality.

- `createEmptyEditorState()`: Creates empty editor state.

- `toJSON()`: Serializes the instance to a JSON string.

- `fromJSON(json: String, editor: Editor)`: Deserializes a JSON string. 