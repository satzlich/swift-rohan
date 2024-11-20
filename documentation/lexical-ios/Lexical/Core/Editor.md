
# Lexical/Core/Editor.swift

`EditorConfig`: Simple composite of an instance of `Theme` and  a list of `Plugin`s.

`DecoratorCacheItem`: 
`UIView` corresponding to a `DecoratorNode`. 
The state of the `UIView` is embodied in the current `enum` case.


## Editor

- `static maxUpdateCount`: ???

Member fields:

- `editorState`: the data model
- `pendingEditorState`
- `theme`

- `textStorage`: 
- `frontend`: 

- `infiniteUpdateLoopCount`
- `keyCounter`: the next available node key to be used.

- `transformCounter`: the next transform key

- `isRecoveringFromError`:

- `rangeCache`: Mapping from `NodeKey` to `RangeCacheItem`.

- `dirtyNodes: DirtyNodeMap`: Dictionary that keeps record of dirty nodes.

- `cloneNotNeeded: Set<NodeKey>`: Set that keeps record of nodes that are already cloned.

- `normalizedNodes: Set<NodeKey>`: ???



- `registeredNodes: [NodeType: Node.Type]`: 
    Used for deserialization and registration of nodes. Lexical's built-in nodes are registered by default.

- `nodeTransforms: [NodeType: [(Int, NodeTransform)]]`:
    