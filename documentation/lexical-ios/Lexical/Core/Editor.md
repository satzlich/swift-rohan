
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

