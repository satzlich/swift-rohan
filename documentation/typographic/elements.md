
# Sketch

## Kernel

### Group 1

- Text
- Emphasis
- Heading
- BulletList
- NumberedList

### Group 2

- Bibliography
- Citation

### Group 3

- Label
- Reference

### Group 4

- Footnote

### Group 5

- Equation
    - Text (math mode)
    - Text (text mode)
    - Attach 
    - Frac
    - Vector
    - Matrix

### Group 6

- Outline

### Group 7

- Figure
- Link
- Table

# Specification

## Group 1

- Text

- Emphasis
  - intrinsic
    - content

- Heading
  - intrinsic
    - level (1, 2, ... for heading, sub-heading, etc.)
    - content

- BulletList
  - intrinsic
    - a list of BulletItem's
  - extrinsic
    - level (of indentation)

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

## Group 2

**Interaction.** A `citation`, through a `citationKey`, refers to a particuliar
 `bibliographyEntry` from the `bibliography` provided by context.

- Bibliography
  - semantic
    - a set of BibliographyEntry's each with a unique identifier called *citationKey*.
  - intrinsic
    - bibliographyEntries: `Map<CitationKey, BibliographyEntry>`
  - sources (subject to validation)
    - a BibTeX file, or
    - a list of BibliographyEntry's

- Citation
  - intrinsic
    - citationKey: CitationKey
  - extrinsic
    - isValid: Bool (dependent on the contextual bibliography)

**Constituents.**

- BibliographyEntry
  - intrinsic
    - citationKey: CitationKey
    - (data about an article, a book, or other source)

- CitationKey
  - intrinsic
    - text: String (subject to syntax validation)

## Group 3

**Interaction**. A `reference` is a mention of a particular `element` 
that is attached to by a `label` through a `name` for `Label`.

- Label
  - intrinsic
    - name: String (subject to syntax check)
  - extrinsic
    - attachedTo: any Element? (dependent on the previous elements when situated in a content)

- Reference
  - intrinsic
    - labelName: String
  - extrinsic
    - label: Label? (depedent on the whole document)


## Group 4

- Footnote
  - intrinsic
    - content
  - extrinsic
    - superiorFigure: ??
      - **Note.** Consecutively numbered througout a chapter or an article. Or, restart a series of numbers by pages.

**Similar elements.** End note, and margin note.

## Group 5

- Equation
  
## Group 6

- Outline

