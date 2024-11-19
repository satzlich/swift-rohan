
# RangeSelection

Member fields:

- `anchor: Point`
- `focus: Point`
- `dirty: Bool`
- `format: TextFormat`
- `style: String`

Member methods:

- `isBackward()`: True if `focus` is before `anchor`.

- `isCollapsed()`: True if `anchor` equals `focus`.

- `hasFormat(type: TextFormatType) -> Bool`: True if `format` has given format `type` set.

- `getCharacterOffsets(selection: RangeSelection) -> (Int, Int)`:
    If current selection is a **collapsed** one inside an element, return (0, 0).
    Otherwise, return the character offsets of `anchor` and `focus`.

- `getNodes() -> [Node]`: ???