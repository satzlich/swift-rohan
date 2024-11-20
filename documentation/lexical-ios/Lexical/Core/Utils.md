#  Utils.swift


- `internallyMarkChildrenAsDirty(...)`:
    Mark children of given element as dirty, recursively.

- `internallyMarkParentElementsAsDirty(...)`:
    Mark given parent as dirty. No cascading mark.

- `internallyMarkNodeAsDirty(node: Node, cause: DirtyStatusCause)`:
    Mark `node` as dirty.

    1. Mark parent.
    2. Mark children, if `node` is an element.
    3. Mark `node`.

- `internallyMarkSiblingsAsDirty(node: Node, status: DirtyStatusCause)`:
    Mark immediate siblings (if any) as dirty.


- `maybeMoveChildrenSelectionToParent(parentNode: Node, offset: Int) -> BaseSelection?`:
    If selection is in one of the children, move it to the parent.


- `removeFromParent(node: Node)`:
    Removes `node` from parent.

    Mark siblings and parent as dirty.