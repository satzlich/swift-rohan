
# Elements


- Bibliography
    - semantic
        - a collection of `BibEntry`'s
    - intrinsic 
        - the collection of literature entries
            - essential part: the "citation keys"
    - interaction
        - Reference "cites" a literature entry by specifying a "citation key"

- BulletList
    - intrinsic
        - a list of contents (called items)
    - extrinsic
        - level of indentation

- Citation
    - intrinsic
        - "citation key": String
    - extrinsic
        - reference text / link to a literature entry

- Emphasis
    - intrinsic
        - content

- Figure
    - intrinsic
        - image
        - caption

- Footnote
    - intrinsic
        - content
    - extrinsic
        - footnote name

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
        - label: Optional\<Label\>
    - interaction
        - "label name" is intended to specify a Label.

- Table
    - intrinsic
        - a grid of contents
        
    
## Contents

- An element is a content.
- A list of contents constitues a content.

The content slot of an element generally does not accept an arbitrary content,
but those that satisfy its requirements.

