# Bibliography mechanism specification

**Interaction.** A `citation` refers to a particuliar `bibliographyEntry` from the
 `bibliography` provided by context through a `citationKey`.

- Bibliography
  - semantic
    - a set of BibliographyEntry's each with a unique identifier called *citationKey*.
  - intrinsic
    - biliographyEntries: `Map<CitationKey, BibliographyEntry>`
  - sources (subject to validation)
    - a BibTeX file, or
    - a list of BibliographyEntry's

- BibliographyEntry
  - intrinsic
    - citationKey: CitationKey
    - (data about an article, a book, or something else)

- CitationKey
  - intrinsic
    - text: String (subject to syntax constraints)

- Citation
  - intrinsic
    - citationKey: CitationKey
  - extrinsic
    - isValid: Bool (dependent on the contextual bibliography)
