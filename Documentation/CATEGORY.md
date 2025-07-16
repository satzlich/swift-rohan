# Text

| Node        | Mode      | Content   | Container | Constraint      |
| ----------- | --------- | --------- | --------- | --------------- |
| counter     | text      | plaintext | x         |                 |
| linebreak   | text      | plaintext | x         |                 |
| namedSymbol | text/math | plaintext | x         |                 |
| text        | text/math | plaintext | x         |                 |
| unknown     | text/math | -         | x         |                 |
| content     | text/math | -         | -         |                 |
| expansion   | text/math | -         | -         |                 |
| heading     | text      | block     | inline    |                 |
| itemList    | text      | block     | block     | in paragraph    |
| paragraph   | text      | block     | mixed     |                 |
| parList     | text      | block     | block     | only paragraphs |
| root        | text      | x         | block     |                 |
| textStyles  | text      | inline    | inline    |                 |

# Math

| Node           | Mode         | Content      | Container | Constraint   |
| -------------- | ------------ | ------------ | --------- | ------------ |
| accent         | math         | inline       | inline    |              |
| attach         | math         | inline       | inline    |              |
| equation       | text -> math | inline/block | inline    | in paragraph |
| fraction       | math         | inline       | inline    |              |
| leftRight      | math         | inline       | inline    |              |
| mathAttributes | math         | inline       | inline    |              |
| mathExpression | math         | inline       | inline    |              |
| mathOperator   | math         | inline       | inline    |              |
| mathStyles     | math         | inline       | inline    |              |
| matrix         | math         | inline       | inline    |              |
| multiline      | text -> math | block        | inline    | in paragraph |
| radical        | math         | inline       | inline    |              |
| textMode       | math -> text | inline       | plaintext |              |
| underOver      | math         | inline       | inline    |              |

# Abstraction

| Node     | Mode      | Content | Container | Constraint |
| -------- | --------- | ------- | --------- | ---------- |
| apply    | text/math | -       | -         |            |
| variable | (context) | -       | -         |            |

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

### Must be contained in

- `parList` and `heading` must be contained in `root`.
- `itemList` must be contained in `paragraph` whose parent is not `itemList`.
- Block `equation` and `multiline` must be contained in `paragraph`.

### Can only contain

- `itemList` can only contain `paragraph`.

# Design

```swift

struct ContentProperty {
  let contentMode: ContentMode
  let layoutType: LayoutType
}

struct ContainerProperty {
  let containerMode: LayoutMode
  let containerType: ContainerType // inline, block, mixed
}

enum ContentMode {
  case text
  case math
  case universal // can be either text or math
}

enum LayoutType {
  case inline
  case hardBlock
  case softBlock
}

enum LayoutMode {
  case text
  case math
}

enum ContainerType {
  case inline
  case block
  case mixed // can contain both inline and block content
}

```
