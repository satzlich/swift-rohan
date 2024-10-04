
# Elements


- Bibliography
    - intrinsic
        - a set of `BibEntry`'s
    - init: 
        - with a collection of `BibEntry`s;
    - utils:
        - init with a `FilePath`
    - interaction
        - `Citation` **cites** a `BibEntry` by specifying a `CitationKey`.

- BulletList
    - intrinsic
        - a list of bullet items
    - extrinsic
        - level of indentation

- Citation
    - intrinsic
        - `citationKey: CitationKey`

- Emphasis
    - intrinsic
        - content

- Figure
    - intrinsic
        - image
        - caption

- Note
    - semantic: an instance of note
    - intrinsic
        - content
    - extrinsic
        - note type: footnote, endnote, margin note, etc.
        - note number

- Heading
    - intrinsic
        - level
        - content
    - extrinsic

- Label
    - intrinsic
        - name: String (subject to syntax checking)

- Link
    - intrinsic
        - text
        - url
    - extrinsic
    
- NumberedList
    - intrinsic
        - a list of numbered items
    - extrinsic
        - level of indentation
        - a list of `NumberedItem`s
    - NumberedItem
      - intrinsic
        - number action
        - content
      - extrinsic
        - (computed) number label
        - content

- Ontline
    - intrinsic
        - category (headings, figures, tables, etc.) indicator

- Reference
    - intrinsic
        - `labelName: String`
    - extrinsic
        - `label: Label?`
    - interaction
        - `labelName` is intended to specify a `Label`, but there may not be a `Label` with that name.

- Table
    - intrinsic
        - a grid of contents
        
    
## Contents

- An element is a content.
- A list of contents constitues a content.

The content slot of an element generally does not accept an arbitrary content,
but those that satisfy its requirements.

