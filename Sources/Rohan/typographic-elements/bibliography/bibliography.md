# Bibliography mechanism specification

**Interaction.** A `citation` refers to a particuliar `bibliographyEntry` from the
 `bibliography` provided by context through a `citationKey`.

- Bibliography
  - semantic
    - a set of BibliographyEntry's each with a unique identifier called *citationKey*.
  - sources
    - a BibTeX file, or
    - a list of BibliographyEntry's

- BibliographyEntry
  - intrinsic
    - citationKey: CitationKey

- CitationKey
  - intrinsic
    - text: String (subject to syntax constraints)

- Citation
  - intrinsic
    - citationKey: CitationKey
  - extrinsic
    - isValid: Bool (dependent on the contextual bibliography)
