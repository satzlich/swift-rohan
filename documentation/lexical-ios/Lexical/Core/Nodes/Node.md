
# Node

## NodeKey

`NodeKey`: An alias for the `String` type.


## Node

**The four parts of a node.**
In Lexical iOS, a node's content is split into four parts: preamble, children, text, postamble. ``ElementNode`` subclasses can implement preamble/postamble, and TextNode subclasses can implement the text part.



Member fields:

- `key: NodeKey`: Identifier for the node.
- `parent: NodeKey?`: Parent node for the node.
- `version: Int`: ???


Member methods:

- `init(_ key: NodeKey?)`: Natural semantic. `LexicalConstants.uninitializedNodeKey` is a special value for argument `key`.

- `init(from decoder: Decoder)`: Deserializes from JSON. 
Field `key` is generated not deserialized.

- `encode(to encoder: Encoder)`: Serializes the instance. Field `key` is ommitted.

- `didMoveTo(newEditor editor: Editor)`: 
Called whenever the node is moved to a new editor, e.g. when initialising an editor with an existing editor state.

- `getType() -> NodeType`: 
Default semantic --- returns `.unknown`.

- `type: NodeType`: Alias for `getType()`.

- `getPreamble() -> String`: 
Provides the **preamble** part of the node's content. Typically the preamble is used for control characters to represent embedded objects (see ``DecoratorNode``).

- `getPostamble() -> String`:
Provides the **postamble** part of the node's content. Typically the postamble is used for paragraph-trailing newlines.

- `getTextPart() -> String`:
Provides the **text** part of the node's content. The text part of a node represents the text this node is providing (but not including the text of any children).

- `getTextPartSize() -> Int`:
Returns the length of the text part (as UTF 16 codepoints). Note that all string lengths within Lexical work using UTF 16 codepoints, because that is what TextKit uses.

- `isDirty() -> Bool`: Returns true if this node has been marked dirty during this update cycle.

- `getLatest() -> Self`: 
Returns the latest version of the node from the active EditorState. This is used to avoid getting values from stale node references.

- `clone() -> Self`:
Clones this node, creating a new node with a different key and adding it to the EditorState (but not attaching it anywhere!). 
All nodes must implement this method.

- `getAttributedStringAttributes(theme: Theme) -> [NSAttributedString.Key: Any]`:
  Lets the node provide attributes for TextKit to use to render the node's content.

- `getBlockLevelAttributes(theme: Theme) -> BlockLevelAttributes?`: 
    Attributes that apply to an entire block.

    This is conceptually not a thing in TextKit, so we had to build our own solution. Note that a block
    is an element or decorator that is not inline. The values of the block level attributes are applied
    to the relevant paragraph style for the first or last paragraph within the node. (Paragraph is here
    used to refer to a TextKit paragraph, i.e. some text separated by newlines. It's nothing to do with
    Lexical's paragraph nodes!)

- `getWritable() -> Self`: 
    Returns a mutable version of the node. Will throw an error if called outside of a Lexical Editor ``Editor/update(_:)`` callback.

    1. Ensure we are in writable mode.
    2. Ensure we are accessing active editor and active editor state.
    3. If the current node satisfies predicate `cloneNotNeeded`, mark the node dirty and return it.
    4. Otherwise, clone the node to a mutable instance.
    5. Mark the current node as `cloneNotNeeded` (which implies mutable), and dirty. Put the mutable instance in the node map and return it. 

- `getIndexWithinParent() -> Int?`:
    Returns the zero-based index of this node within the parent.

- `getParent() -> ElementNode?`:
    Returns the parent of this node, or nil if none is found.

