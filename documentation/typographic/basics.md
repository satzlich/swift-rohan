
- BulletList
  - intrinsic
    - a list of BulletItem's
  - extrinsic
    - level (of indentation)

- Emphasis
  - intrinsic
    - content

- Figure
  - intrinsic
    - image
    - caption

- Heading
  - intrinsic
    - level (1, 2, ... for heading, sub-heading, etc.)
    - content

- Link
  - intrinsic
    - text: String
    - url: String

- NumberedList
  - intrinsic
    - a list of NumberedItem's
  - extrinsic
    - level (of indentation)

  - NumberedItem
    - intrinsic
      - number action (either sets a value or increments the value of its predecessor)
      - item content
    - extrinsic
      - number value

- Table

## Content

- An element is a content.
- A list of contents constitues a content.

The content slot of an element generally does not accept an arbitrary content,
but those that satisfy its requirements.

