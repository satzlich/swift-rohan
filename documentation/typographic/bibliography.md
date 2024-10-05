# Bibliography mechanism specification

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

- BibliographyEntry
  - intrinsic
    - citationKey: CitationKey
    - (data about an article, a book, or other source)

- CitationKey
  - intrinsic
    - text: String (subject to syntax validation)

- Citation
  - intrinsic
    - citationKey: CitationKey
  - extrinsic
    - isValid: Bool (dependent on the contextual bibliography)
