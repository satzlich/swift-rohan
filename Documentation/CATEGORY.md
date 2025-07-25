
# Rules

## General Rules

- A node can be text content, math content, or universal content.
- A node can be non-container or a container.
- If a node is a container, it can be a container for either text content or math content but not both.

- A node can be either inline or block content.
- If a node is a container, it can be a container for inline content, block content, or mixed content.

- Inline content must be contained in a container for inline content or mixed content.
- Block content must be contained in a container for block content or mixed content.

## Particular Rules

### Can only contain

- `itemList` can only contain `paragraph`.

### Must be contained in

- `parList` and `heading` must be contained in `root`.
- `itemList` must be contained in `paragraph` whose parent is not `itemList`.
- Block `equation` and `multiline` must be contained in `paragraph`.

### Must be inserted into

For implementation purpose, we define **must be inserted into** relation instead of 
**must be contained in** relation.


# Design

- obtains node type and node type of its parent;
- obtains content properties from a node;
- obtains container properties from the effective container node for given location;

```swift

struct ContentProperty {
  let contentMode: ContentMode
  let contentType: ContentType
}

struct ContainerProperty {
  let containerMode: ContainerMode
  let containerType: ContainerType // inline, block, mixed
}

enum ContentMode {
  case text
  case math
  case universal // can be either text or math
}

enum ContentType {
  case inline
  case block
}

enum ContainerMode {
  case text
  case math
}

enum ContainerType {
  case inline
  case block
  case mixed // can contain both inline and block content
}

```
