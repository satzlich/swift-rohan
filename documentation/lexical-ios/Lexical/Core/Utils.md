#  Utils.swift


`generateKey(node: Node) -> NodeKey?`: 
    A `keyCounter` is maintained in `EditorState`.

- `maybeMoveChildrenSelectionToParent(parentNode: Node, offset: Int) -> BaseSelection?`:
    If selection is in one of the children, move it to the parent.
