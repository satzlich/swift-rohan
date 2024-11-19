
# Point.swift


## SelectionType

Different kinds of selections.


## Point


Member fields:

- `key: NodeKey`
- `offset: Int`
- `type: SelectionType`
- `weak selection: BaseSelection?`

Member methods:

- `isBefore(point: Point) -> Bool`: Compares with another point.

- `getNode() -> Node`: Returns the node specified by `key`.

- `getOffset() -> Int`: Returns `offset`.

- `getType() -> Type`: Returns `type`.

- `updatePoint(key: NodeKey, offset: Int, type: SelectionType)`:
Update point. In write-enabled mode, update of point renders `selection` dirty.

- `getCharacterOffset() -> Int`: Returns offset if the selection type is `text`; otherwise returns a default value `0`.

- `isAtNodeEnd() -> Bool`: Returns true if the point is at the end of the selected node.
