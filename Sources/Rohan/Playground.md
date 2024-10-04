
# Elements


- Bibliography
    - semantic: a set of `BibEntry`'s
    - init: 
        - with `FilePath`;
        - with a collection of `BibEntry`s;
    - intrinsic
        - a set of `BibEntry`'s
    - interaction
        - `Citation` **cites** a `BibEntry` by specifying a **citation key**.

- BulletList
    - intrinsic
        - a list of bullet items
    - extrinsic
        - level of indentation

- Citation
    - intrinsic
        - "citation key": String

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
        - url text
    - extrinsic
    
- NumberedList
    - intrinsic
        - a list of numbered items
    - extrinsic
        - level of indentation
        - a list of (number, content) pairs

- Ontline
    - intrinsic
        - category (heading, figures, tables, etc.) indicator

- Reference
    - intrinsic
        - "label name": String
    - extrinsic
        - label: `Label?`
    - interaction
        - "label name" is intended to specify a `Label`.

- Table
    - intrinsic
        - a grid of contents
        
    
## Contents

- An element is a content.
- A list of contents constitues a content.

The content slot of an element generally does not accept an arbitrary content,
but those that satisfy its requirements.

