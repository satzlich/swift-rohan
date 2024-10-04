# Bibliography mechanism specification

**Interaction.** A `citation` is an intention to cite a particuliar `bibEntry` 
from the `bibliography` provided by context through a `text` for `CitationKey`

- Bibliography
  - a set of BibEntry's

- BibEntry
  - intrinsic
    - citationKey: CitationKey

- CitationKey
  - intrinsic
    - text: String (subject to syntax check)
  - contextual
    - bibEntry: BibEntry?

- Citation
  - semantic
    - An intention to cite a BibEntry
  - intrinsic
    - text: String
  - extrinsic
    - citationKey: CitationKey?
