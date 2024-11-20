
# SelectionUtils


- `moveSelectionPointToSibling(point: Point, node: Node, parent: ElementNode)`:
    Move selection `point` to/into a proper sibling.

    1. If `node` has previous sibling, 
       1. If the previous sibling is text or element, move selection to the end of it.
    2. If `node` has next sibling, 
       1. If the next sibling is text or element, move selection to the beginning of it.
    3. Otherwise, set selection before `node`.


- `updateElementSelectionOnCreateDeleteNode(selection: RangeSelection, parentNode: Node, nodeOffset: Int, times: Int)`:
    Update element selection on creating/deleting a node at `nodeOffset`
    where the node has already been inserted or removed.

    ??? (More details)

