
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

- `getNodes() -> [Node]`: Returns the nodes in the range.

- `clone() -> BaseSelection`: Clones the range selection.

- `setTextNodeRange(...)`: 
    Sets the range using the given arguments and marks the dirty flag.

- `extract() -> [Node]`: 
    Returns nodes within the range, handling partial selections of text nodes appropriately.

- `insertRawText(text: String)`: 
    Inserts `text` at the selection, handling newlines appropriately.

- `getTextContent() -> String`:
    Extracts all text content from the selected range.

    ??? (Details)


- `insertText(_ text: String)`:
    Inserts `text` at the selection.

    Very complicated. Almost 300 lines long.

    1. Normalize selection if necessary.
    2. ??? (Details)

- `insertNodes(nodes: [Node], selectStart: Bool) -> Bool`:
    Inserts `nodes` at the selection.

    Very complicated. More than 200 lines long.

    ??? (Details)

- `getPlaintext() -> String`:
    Extracts the plaintext within the selection from `textStorage`.

- ??? (More methods)

