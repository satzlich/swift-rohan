
# Node

## NodeKey

`NodeKey`: An alias for the `String` type, used as the unique identifier 
for each node.


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

- `getParentKeys() -> [NodeKey]`:
    Returns a list of the keys of every ancestor of this node, all the way up to the RootNode.

- `getTopLevelElement() -> ElementNode?`:
    Returns the highest (in the ``EditorState`` tree) non-root ancestor of this node, or null if none is found.

- `getTopLevelElementOrThrow() -> ElementNode`:
Returns the highest (in the EditorState tree) non-root ancestor of this node, or throws if none is found.

- `getParents() -> [ElementNode]`:
Returns a list of the every ancestor of this node, all the way up to the RootNode.

- `getCommonAncestor(node: Node) -> ElementNode?`:
Returns the closest common ancestor of this node and the provided one or nil if one cannot be found.

- `getPreviousSibling() -> Node?`:
Returns the "previous" siblings - that is, the node that comes before this one in the same parent.

- `getNextSibling() -> Node?`:
Returns the "next" sibling - that is, the node that comes after this one in the same parent

- `getPreviousSiblings() -> [Node]`:
Returns the "previous" siblings - that is, the nodes that come between this one and the first child of it's parent, inclusive.

- `getNextSiblings() -> [Node]`:
Returns all "next" siblings - that is, the nodes that come between this one and the last child of its parent, inclusive.

- `getNodesBetween(targetNode: Node) -> [Node]`:
    Returns a list of nodes that are between this node and the target node in the EditorState.

    ??? (More details on algorithm)

- `isSameKey(_ object: Node?) -> Bool`: Checks equality on `key`.

- `getKey() -> NodeKey`: Returns `key`.

- `isBefore(_ targetNode: Node) -> Bool`: Natural semantic. 
Note the value for parent-child relation.

- `getChildIndex(commonAncestor: ElementNode?, node: Node) -> Int`: 
Natural semantic. 

- `isParentOf(_ targetNode: Node) -> Bool`: Natural semantic. Better named
`isAncesstorOf(_ targetNode: Node)`.

- `getParentOrThrow() -> ElementNode`: 
Returns the parent of this node, or throws if none is found.

- `getTextContent(includeInert: Bool, includeDirectionless: Bool) -> String`:
    Returns the text content of the node, typically including its children.
    This is different from ``getTextPart()``, which just returns the text provided by this node.

- `getTextContentSize(includeInert: Bool, includeDirectionless: Bool) -> Int`:
    Returns the length of the string produced by calling getTextContent on this node.

- `remove()`:
    Removes this LexicalNode from the EditorState. If the node isn't re-inserted somewhere, the Lexical garbage collector will eventually clean it up.

- `static removeNode(nodeToRemove: Node, restoreSelection: Bool)`:
    Removes `nodeToRemove`.

    1. If `nodeToRemove` has no parent, return.
    2. If the selection is in one of the `nodeToRemove`'s children, move it into `nodeToRemove`.
    3. If the (current) selection is a `RangeSelection`, update its `anchor` and `focus` to avoid `nodeToRemove`.
    4. Mark `nodeToRemove` as dirty and remove it from parent.
    5. 