# Text

| Node        | Mode      | Content   | Container | LayoutType | Constraint             |
| ----------- | --------- | --------- | --------- | ---------- | ---------------------- |
| counter     | text      | plaintext | x         | inline     |                        |
| linebreak   | text      | plaintext | x         | inline     |                        |
| namedSymbol | text/math | plaintext | x         | inline     |                        |
| text        | text/math | plaintext | x         | inline     |                        |
| unknown     | text/math | -         | x         | inline     |                        |
| content     | text/math | -         | -         | -          |                        |
| expansion   | text/math | -         | -         | -          |                        |
| heading     | text      | block     | inline    | block      |                        |
| itemList    | text      | block     | block     | block      | contained in paragraph |
| paragraph   | text      | block     | inline+   | soft-block |                        |
| parList     | text      | block     | block     | block      | contain paragraphs     |
| root        | text      | x         | block     | block      |                        |
| textStyles  | text      | inline    | inline    | inline     |                        |

# Math

| Node           | Mode         | Content      | Container | LayoutType   | Constraint             |
| -------------- | ------------ | ------------ | --------- | ------------ | ---------------------- |
| accent         | math         | inline       | inline    | inline       |                        |
| attach         | math         | inline       | inline    | inline       |                        |
| equation       | text -> math | inline/block | inline    | inline/block | contained in paragraph |
| fraction       | math         | inline       | inline    | inline       |                        |
| leftRight      | math         | inline       | inline    | inline       |                        |
| mathAttributes | math         | inline       | inline    | inline       |                        |
| mathExpression | math         | inline       | inline    | inline       |                        |
| mathOperator   | math         | inline       | inline    | inline       |                        |
| mathStyles     | math         | inline       | inline    | inline       |                        |
| matrix         | math         | inline       | inline    | inline       |                        |
| multiline      | text -> math | block        | inline    | inline       | contained in paragraph |
| radical        | math         | inline       | inline    | inline       |                        |
| textMode       | math -> text | inline       | plaintext | inline       |                        |
| underOver      | math         | inline       | inline    | inline       |                        |

# Abstraction

| Node     | Mode      | Content | Container | LayoutType | Constraint |
| -------- | --------- | ------- | --------- | ---------- | ---------- |
| apply    | text/math | -       | -         | -          |            |
| variable | (context) | -       | -         | -          |            |
