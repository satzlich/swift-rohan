
# BaseSelection

A protocol for all types of selection.

- `dirty: Bool`: True if the selection has had any changes made that need reconciling.

- `clone() -> BaseSelection`: Makes an identical copy of this selection.

- `extract() -> [Node]`: Extracts the nodes in the Selection, splitting 
  nodes if necessary to get offset-level precision.

- `getNodes() -> [Node]`: Returns all the nodes in or partially in the Selection. This function is designed to be more performant than ``extract()``.

- `getTextContent() -> String`: Returns a plain text representation of the content of the selection.

- `insertRawText(_ text: String)`: Attempts to insert the provided text into the EditorState at the current Selection, converting tabs, newlines, and carriage returns into LexicalNodes.

- `isSelection(_ selection: BaseSelection) -> Bool`: Checks for selection equality.

- `insertNodes(nodes: [Node], selectStart: Bool) -> Bool`: 
Attempts to "intelligently" insert an arbitrary list of Lexical nodes into the EditorState at the
current Selection according to a set of heuristics that determine how surrounding nodes
should be changed, replaced, or moved to accomodate the incoming ones.

- `deleteCharacter(isBackwards: Bool)`: Does the equivalent of pressing the backspace key.

- `deleteWord(isBackwards: Bool)`: Handles a delete word event, e.g. option-backspace on Apple platforms

- `deleteLine(isBackwards: Bool)`: Handles a delete line event, e.g. command-backspace on Apple platforms

- `insertParagraph()`: Handles the user pressing carriage-return

- `insertLineBreak(selectStart: Bool)`: Handles inserting a soft line break (which does not split paragraphs)

- `insertText(_ text: String)`: 
Handles user-provided text to insert, applying a series of insertion heuristics based on the selection type and position.

